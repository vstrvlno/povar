import Foundation
import UIKit
import Vision
import ImageIO

struct DetectedIngredient: Identifiable, Hashable {
    let id: String
    /// Уверенность 0…1 (для распознавания на устройстве)
    let confidence: Double?

    var info: IngredientInfo? { IngredientCatalog.byId[id] }
}

enum RecognitionMode: String, CaseIterable, Identifiable {
    case onDevice, claude
    var id: String { rawValue }
    var title: String {
        switch self {
        case .onDevice: return "На устройстве (Vision)"
        case .claude: return "Claude AI (точнее)"
        }
    }
    var details: String {
        switch self {
        case .onDevice:
            return "Бесплатно и без интернета, работает на iPhone. Хорошо узнаёт отдельные крупные продукты (яйца, помидоры, яблоки), хуже — продукты в упаковках."
        case .claude:
            return "Фото отправляется в Claude API. Узнаёт продукты в холодильнике, в пакетах и упаковках. Нужен интернет и API‑ключ."
        }
    }
}

enum RecognitionError: LocalizedError {
    case badImage, noApiKey, api(String), parse

    var errorDescription: String? {
        switch self {
        case .badImage: return "Не удалось прочитать изображение."
        case .noApiKey: return "Укажите API‑ключ Claude в настройках (шестерёнка на вкладке «Продукты»)."
        case .api(let message): return "Ошибка Claude API: \(message)"
        case .parse: return "Не удалось разобрать ответ модели. Попробуйте ещё раз."
        }
    }
}

enum IngredientRecognizer {
    static let claudeKeychainKey = "claudeApiKey"
    static let defaultClaudeModel = "claude-opus-5-5"

    static func recognize(_ image: UIImage, mode: RecognitionMode, model: String) async throws -> [DetectedIngredient] {
        switch mode {
        case .onDevice:
            return try await recognizeOnDevice(image)
        case .claude:
            return try await recognizeWithClaude(image, apiKey: Keychain.get(claudeKeychainKey), model: model)
        }
    }

    // MARK: - Vision (на устройстве)

    static func recognizeOnDevice(_ image: UIImage) async throws -> [DetectedIngredient] {
        let normalized = image.resized(maxSide: 1600)
        guard let cgImage = normalized.cgImage else { throw RecognitionError.badImage }
        let orientation = CGImagePropertyOrientation(normalized.imageOrientation)

        return try await Task.detached(priority: .userInitiated) { () throws -> [DetectedIngredient] in
            let request = VNClassifyImageRequest()
            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
            try handler.perform([request])
            let observations = request.results ?? []

            var best: [String: Double] = [:]
            for observation in observations where observation.confidence > 0.05 {
                let label = observation.identifier.lowercased()
                for info in IngredientCatalog.all where !info.isStaple && info.matches(visionLabel: label) {
                    best[info.id] = max(best[info.id] ?? 0, Double(observation.confidence))
                }
            }
            return best
                .map { DetectedIngredient(id: $0.key, confidence: $0.value) }
                .sorted { ($0.confidence ?? 0) > ($1.confidence ?? 0) }
        }.value
    }

    // MARK: - Claude API

    static func recognizeWithClaude(_ image: UIImage, apiKey: String, model: String) async throws -> [DetectedIngredient] {
        let key = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty else { throw RecognitionError.noApiKey }
        guard let jpeg = image.resized(maxSide: 1280).jpegData(compressionQuality: 0.7) else {
            throw RecognitionError.badImage
        }

        let catalog = IngredientCatalog.all
            .filter { !$0.isStaple }
            .map { "\($0.id) — \($0.name)" }
            .joined(separator: "\n")

        let prompt = """
        На фото — продукты (холодильник, стол, пакет с покупками и т.п.). \
        Определи, какие продукты из списка ниже видны на фото, включая продукты в упаковках с читаемыми этикетками.
        Ответь ТОЛЬКО JSON-массивом идентификаторов из списка, без пояснений. Пример: ["egg","tomato"]. \
        Если ничего не найдено — ответь [].

        Список (id — название):
        \(catalog)
        """

        let body: [String: Any] = [
            "model": model.isEmpty ? defaultClaudeModel : model,
            "max_tokens": 512,
            "messages": [[
                "role": "user",
                "content": [
                    ["type": "image",
                     "source": ["type": "base64", "media_type": "image/jpeg", "data": jpeg.base64EncodedString()]],
                    ["type": "text", "text": prompt],
                ],
            ]],
        ]

        var request = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.setValue(key, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]

        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            let message = ((json?["error"] as? [String: Any])?["message"] as? String) ?? "HTTP \(http.statusCode)"
            throw RecognitionError.api(message)
        }

        let blocks = json?["content"] as? [[String: Any]] ?? []
        let text = blocks.compactMap { $0["text"] as? String }.joined()

        guard let start = text.firstIndex(of: "["),
              let end = text.lastIndex(of: "]"),
              start < end,
              let arrayData = String(text[start...end]).data(using: .utf8),
              let ids = (try? JSONSerialization.jsonObject(with: arrayData)) as? [String]
        else { throw RecognitionError.parse }

        var seen = Set<String>()
        return ids
            .filter { IngredientCatalog.byId[$0] != nil && seen.insert($0).inserted }
            .map { DetectedIngredient(id: $0, confidence: nil) }
    }
}

// MARK: - Helpers

extension UIImage {
    /// Уменьшает изображение и «выпрямляет» ориентацию
    func resized(maxSide: CGFloat) -> UIImage {
        let longest = max(size.width, size.height)
        let scale = longest > maxSide ? maxSide / longest : 1
        let newSize = CGSize(width: (size.width * scale).rounded(), height: (size.height * scale).rounded())
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        return UIGraphicsImageRenderer(size: newSize, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

extension CGImagePropertyOrientation {
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}
