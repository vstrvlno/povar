import SwiftUI

/// Результат распознавания продуктов на фото
struct ScanResultView: View {
    let image: UIImage
    @Environment(PantryStore.self) private var pantry
    @Environment(\.dismiss) private var dismiss
    @AppStorage("recognitionMode") private var modeRaw = RecognitionMode.onDevice.rawValue
    @AppStorage("claudeModel") private var model = IngredientRecognizer.defaultClaudeModel

    private enum Phase { case loading, done, failed(String) }

    @State private var phase: Phase = .loading
    @State private var detected: [DetectedIngredient] = []
    @State private var selected: Set<String> = []

    private var mode: RecognitionMode { RecognitionMode(rawValue: modeRaw) ?? .onDevice }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 260)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }

                switch phase {
                case .loading:
                    Section {
                        HStack(spacing: 12) {
                            ProgressView()
                            Text("Определяю продукты…")
                        }
                    } footer: {
                        Text("Способ: \(mode.title)")
                    }
                case .failed(let message):
                    Section {
                        Label(message, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                        Button("Повторить") { Task { await run() } }
                    }
                case .done:
                    if detected.isEmpty {
                        Section {
                            Text("Не удалось узнать продукты. Сфотографируйте ближе и при хорошем свете, переключите распознавание на Claude в настройках или отметьте продукты вручную.")
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Section {
                            ForEach(detected) { item in
                                Button {
                                    if selected.contains(item.id) { selected.remove(item.id) } else { selected.insert(item.id) }
                                } label: {
                                    HStack(spacing: 12) {
                                        Text(item.info?.emoji ?? "•")
                                        Text(item.info?.name ?? item.id).foregroundStyle(Color.primary)
                                        Spacer()
                                        if let confidence = item.confidence {
                                            Text("\(Int(confidence * 100))%")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        Image(systemName: selected.contains(item.id) ? "checkmark.circle.fill" : "circle")
                                            .foregroundStyle(selected.contains(item.id) ? Color.green : Color.secondary.opacity(0.4))
                                            .font(.title3)
                                    }
                                }
                            }
                        } header: {
                            Text("Найдено — снимите отметку с лишнего")
                        } footer: {
                            Text("Недостающие продукты можно отметить вручную на вкладке «Продукты».")
                        }
                    }
                }
            }
            .navigationTitle("Распознавание")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Добавить (\(selected.count))") {
                        pantry.add(selected)
                        dismiss()
                    }
                    .disabled(selected.isEmpty)
                }
            }
            .task { await run() }
        }
    }

    private func run() async {
        phase = .loading
        do {
            let result = try await IngredientRecognizer.recognize(image, mode: mode, model: model)
            detected = result
            selected = Set(result.filter { ($0.confidence ?? 1) >= 0.15 }.map(\.id))
            phase = .done
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }
}
