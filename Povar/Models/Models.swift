import Foundation
import SwiftUI

// MARK: - Огонь

enum HeatLevel: String, Codable, CaseIterable {
    case off, low, medium, mediumHigh, high, oven

    var title: String {
        switch self {
        case .off: return "Без огня"
        case .low: return "Слабый огонь"
        case .medium: return "Средний огонь"
        case .mediumHigh: return "Выше среднего"
        case .high: return "Сильный огонь"
        case .oven: return "Духовка"
        }
    }

    /// Подсказка для конфорки с шкалой 1–9
    var dialHint: String {
        switch self {
        case .off: return "Плита не нужна"
        case .low: return "Конфорка на 2–3 из 9"
        case .medium: return "Конфорка на 4–5 из 9"
        case .mediumHigh: return "Конфорка на 6–7 из 9"
        case .high: return "Конфорка на 8–9 из 9"
        case .oven: return "Разогретая духовка"
        }
    }

    var flames: Int {
        switch self {
        case .off, .oven: return 0
        case .low: return 1
        case .medium: return 2
        case .mediumHigh: return 3
        case .high: return 4
        }
    }

    var color: Color {
        switch self {
        case .off: return .gray
        case .low: return .yellow
        case .medium: return .orange
        case .mediumHigh: return Color(red: 0.95, green: 0.35, blue: 0.1)
        case .high: return .red
        case .oven: return .purple
        }
    }
}

// MARK: - Единицы измерения

enum MeasureUnit: String, Codable {
    case g = "г"
    case ml = "мл"
    case pcs = "шт"
    case tbsp = "ст. л."
    case tsp = "ч. л."
    case pinch = "щеп."
    case toTaste = "по вкусу"
}

// MARK: - Посуда

enum Cookware: String, CaseIterable, Hashable {
    case pan, deepPan, pot, bigPot, cauldron, bowl, whisk, mixer, knife, board, grater,
         spatula, ladle, colander, bakingDish, foil, oven, lid, fork

    var title: String {
        switch self {
        case .pan: return "Сковорода (24–26 см)"
        case .deepPan: return "Глубокая сковорода или сотейник"
        case .pot: return "Кастрюля 2–3 л"
        case .bigPot: return "Кастрюля 4–5 л"
        case .cauldron: return "Казан или толстостенная кастрюля"
        case .bowl: return "Миска"
        case .whisk: return "Венчик"
        case .mixer: return "Миксер"
        case .knife: return "Нож"
        case .board: return "Разделочная доска"
        case .grater: return "Тёрка"
        case .spatula: return "Лопатка"
        case .ladle: return "Половник"
        case .colander: return "Дуршлаг"
        case .bakingDish: return "Форма для запекания"
        case .foil: return "Фольга"
        case .oven: return "Духовка"
        case .lid: return "Крышка"
        case .fork: return "Вилка"
        }
    }

    var emoji: String {
        switch self {
        case .pan, .deepPan: return "🍳"
        case .pot, .bigPot, .cauldron: return "🍲"
        case .bowl: return "🥣"
        case .whisk, .mixer: return "🌀"
        case .knife: return "🔪"
        case .board: return "🪵"
        case .grater: return "🧀"
        case .spatula: return "🥄"
        case .ladle: return "🥄"
        case .colander: return "🫗"
        case .bakingDish: return "🫕"
        case .foil: return "🪩"
        case .oven: return "🔥"
        case .lid: return "⭕️"
        case .fork: return "🍴"
        }
    }
}

// MARK: - Ингредиенты

enum IngredientCategory: String, CaseIterable, Identifiable {
    case vegetables, meat, dairy, grocery, basics

    var id: String { rawValue }

    var title: String {
        switch self {
        case .vegetables: return "Овощи, фрукты, зелень"
        case .meat: return "Мясо и рыба"
        case .dairy: return "Молочное и яйца"
        case .grocery: return "Бакалея"
        case .basics: return "Базовое (считается, что есть всегда)"
        }
    }
}

struct IngredientInfo: Identifiable, Hashable {
    let id: String
    let name: String
    let emoji: String
    let category: IngredientCategory
    /// Метки, которые возвращает Vision (английские идентификаторы классификатора)
    let visionKeywords: [String]
    /// Примерный вес одной штуки, г
    var gramsPerPiece: Double? = nil
    /// Соль, перец, вода и т.п. — не учитываются при подборе рецептов
    var isStaple: Bool = false

    func matches(visionLabel label: String) -> Bool {
        let parts = Set(label.split(whereSeparator: { $0 == "_" || $0 == " " || $0 == "-" }).map(String.init))
        return visionKeywords.contains { keyword in
            keyword == label || (!keyword.contains("_") && parts.contains(keyword))
        }
    }
}

struct RecipeIngredient: Hashable {
    let id: String
    let amount: Double
    let unit: MeasureUnit
    var note: String? = nil
    var optional: Bool = false

    var info: IngredientInfo? { IngredientCatalog.byId[id] }

    func displayAmount(factor: Double) -> String {
        let value = amount * factor
        switch unit {
        case .toTaste:
            return "по вкусу"
        case .pcs, .tbsp, .tsp:
            let rounded = max(0.5, (value * 2).rounded() / 2)
            return "\(AmountFormatter.string(rounded)) \(unit.rawValue)"
        case .g, .ml:
            let rounded = value >= 100 ? (value / 5).rounded() * 5 : value.rounded()
            return "\(AmountFormatter.string(max(1, rounded))) \(unit.rawValue)"
        case .pinch:
            return "\(AmountFormatter.string(max(1, value.rounded()))) \(unit.rawValue)"
        }
    }

    /// Примерная граммовка для штучных и ложечных единиц
    func approxGrams(factor: Double) -> Int? {
        let value = amount * factor
        switch unit {
        case .pcs:
            guard let g = info?.gramsPerPiece else { return nil }
            return Int((value * g).rounded())
        case .tbsp:
            return Int((value * 15).rounded())
        case .tsp:
            return Int((value * 5).rounded())
        default:
            return nil
        }
    }
}

// MARK: - Рецепт

enum RecipeCategory: String, CaseIterable, Identifiable {
    case breakfast, soup, main, salad, dessert
    var id: String { rawValue }
    var title: String {
        switch self {
        case .breakfast: return "Завтраки"
        case .soup: return "Супы"
        case .main: return "Основные"
        case .salad: return "Салаты"
        case .dessert: return "Выпечка"
        }
    }
}

enum Difficulty: String {
    case easy = "Легко"
    case medium = "Средне"
    case hard = "Сложно"
}

struct CookingStep: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let heat: HeatLevel
    /// Длительность шага в минутах (для таймера)
    let minutes: Int?
    /// Температура духовки, °C
    var temperature: Int? = nil
    /// Шаг выполняется параллельно с предыдущим — не прибавляется к общему времени
    var parallel: Bool = false
}

struct Recipe: Identifiable, Hashable {
    let id: String
    let name: String
    let emoji: String
    let category: RecipeCategory
    let summary: String
    let baseServings: Int
    let difficulty: Difficulty
    let prepMinutes: Int
    let ingredients: [RecipeIngredient]
    let cookware: [Cookware]
    let steps: [CookingStep]
    var tips: [String] = []

    var totalMinutes: Int {
        prepMinutes + steps.filter { !$0.parallel }.compactMap(\.minutes).reduce(0, +)
    }

    /// Обязательные ингредиенты без базовых (соль, вода…)
    var keyIngredients: [RecipeIngredient] {
        ingredients.filter { !$0.optional && !($0.info?.isStaple ?? false) }
    }

    static func == (lhs: Recipe, rhs: Recipe) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Форматирование

enum AmountFormatter {
    static func string(_ value: Double) -> String {
        if abs(value.rounded() - value) < 0.01 {
            return String(Int(value.rounded()))
        }
        return String(format: "%.1f", value).replacingOccurrences(of: ".", with: ",")
    }
}

func formatTime(_ interval: TimeInterval) -> String {
    let total = max(0, Int(interval.rounded(.up)))
    let h = total / 3600
    let m = (total % 3600) / 60
    let s = total % 60
    if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
    return String(format: "%02d:%02d", m, s)
}

func formatMinutes(_ minutes: Int) -> String {
    if minutes < 60 { return "\(minutes) мин" }
    let h = minutes / 60, m = minutes % 60
    return m == 0 ? "\(h) ч" : "\(h) ч \(m) мин"
}

/// Русское склонение: 1 порция, 2 порции, 5 порций
func plural(_ n: Int, _ one: String, _ few: String, _ many: String) -> String {
    let n10 = n % 10, n100 = n % 100
    if n10 == 1 && n100 != 11 { return one }
    if (2...4).contains(n10) && !(12...14).contains(n100) { return few }
    return many
}
