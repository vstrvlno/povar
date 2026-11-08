import Foundation

struct RecipeMatch: Identifiable {
    let recipe: Recipe
    let have: [String]
    let missing: [String]

    var id: String { recipe.id }
    var ratio: Double {
        let total = have.count + missing.count
        return total == 0 ? 1 : Double(have.count) / Double(total)
    }
}

/// Подбор рецептов по имеющимся продуктам и советы.
enum SuggestionEngine {
    static let substitutes: [String: String] = [
        "sourCream": "можно заменить греческим йогуртом",
        "butter": "можно заменить растительным маслом",
        "milk": "можно заменить водой или кефиром",
        "chicken": "подойдёт индейка или свинина",
        "beef": "подойдёт свинина",
        "mince": "подойдёт мелко нарезанное мясо или тушёнка",
        "cheese": "можно не добавлять",
        "greens": "можно пропустить",
        "tomato": "замените томатной пастой: 1 ст. л. на помидор",
        "tomatoPaste": "замените 2 свежими помидорами",
        "pasta": "подойдёт рис или гречка",
        "buckwheat": "подойдёт рис",
        "rice": "подойдёт булгур или перловка",
        "bellPepper": "можно пропустить",
        "lemon": "замените ложкой уксуса",
        "mushrooms": "подойдёт кабачок или баклажан",
        "cottageCheese": "подойдёт рикотта",
        "fish": "подойдёт куриное филе — время то же",
        "apple": "подойдут груши или ягоды",
        "garlic": "можно заменить сушёным чесноком",
        "cabbage": "в супе можно пропустить",
    ]

    /// Скоропортящиеся продукты — советуем использовать первыми
    static let perishable: Set<String> = ["fish", "mince", "chicken", "beef", "greens", "milk", "sourCream", "cottageCheese", "mushrooms", "tomato", "cucumber"]

    static func matches(pantry: PantryStore) -> [RecipeMatch] {
        RecipeBook.all.map { recipe in
            let keys = recipe.keyIngredients.map(\.id)
            return RecipeMatch(recipe: recipe,
                               have: keys.filter { pantry.has($0) },
                               missing: keys.filter { !pantry.has($0) })
        }
        .sorted {
            if $0.missing.count != $1.missing.count { return $0.missing.count < $1.missing.count }
            if $0.ratio != $1.ratio { return $0.ratio > $1.ratio }
            return $0.recipe.totalMinutes < $1.recipe.totalMinutes
        }
    }

    static func advice(for matches: [RecipeMatch], pantry: PantryStore) -> [String] {
        var lines: [String] = []
        let ready = matches.filter { $0.missing.isEmpty }
        let almost = matches.filter { $0.missing.count == 1 }

        if let fastest = ready.min(by: { $0.recipe.totalMinutes < $1.recipe.totalMinutes }) {
            lines.append("У вас есть всё для \(ready.count) \(plural(ready.count, "блюда", "блюд", "блюд")). Быстрее всего — «\(fastest.recipe.name)» (\(formatMinutes(fastest.recipe.totalMinutes))).")
        } else if let best = almost.first ?? matches.first(where: { !$0.have.isEmpty }) {
            let names = best.missing.map { IngredientCatalog.name(for: $0).lowercased() }.joined(separator: ", ")
            lines.append("Докупите: \(names) — и сможете приготовить «\(best.recipe.name)».")
        } else {
            lines.append("Пока маловато продуктов. Самые универсальные покупки: яйца, лук, картофель, морковь и макароны — из них получается больше всего блюд.")
        }

        let fresh = pantry.items.filter { perishable.contains($0) }
        if !fresh.isEmpty {
            let names = fresh.sorted().map { IngredientCatalog.name(for: $0).lowercased() }.joined(separator: ", ")
            if let useFresh = matches.first(where: { m in m.missing.count <= 1 && m.have.contains(where: { fresh.contains($0) }) }) {
                lines.append("Сначала используйте скоропортящиеся продукты (\(names)) — например, в «\(useFresh.recipe.name)».")
            } else {
                lines.append("Сначала используйте скоропортящиеся продукты: \(names).")
            }
        }

        // Самый «востребованный» недостающий продукт
        var counter: [String: Int] = [:]
        for m in matches where m.missing.count <= 2 {
            for id in m.missing { counter[id, default: 0] += 1 }
        }
        if let top = counter.max(by: { $0.value < $1.value }), top.value >= 2 {
            lines.append("Если купить «\(IngredientCatalog.name(for: top.key).lowercased())», откроется ещё \(top.value) \(plural(top.value, "рецепт", "рецепта", "рецептов")).")
        }
        return lines
    }
}
