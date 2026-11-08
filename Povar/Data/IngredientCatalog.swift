import Foundation

enum IngredientCatalog {
    static let all: [IngredientInfo] = [
        // Овощи, фрукты, зелень
        IngredientInfo(id: "potato", name: "Картофель", emoji: "🥔", category: .vegetables, visionKeywords: ["potato", "potatoes"], gramsPerPiece: 120),
        IngredientInfo(id: "onion", name: "Лук репчатый", emoji: "🧅", category: .vegetables, visionKeywords: ["onion", "onions", "shallot"], gramsPerPiece: 100),
        IngredientInfo(id: "garlic", name: "Чеснок (зубчики)", emoji: "🧄", category: .vegetables, visionKeywords: ["garlic"], gramsPerPiece: 5),
        IngredientInfo(id: "carrot", name: "Морковь", emoji: "🥕", category: .vegetables, visionKeywords: ["carrot", "carrots"], gramsPerPiece: 100),
        IngredientInfo(id: "tomato", name: "Помидоры", emoji: "🍅", category: .vegetables, visionKeywords: ["tomato", "tomatoes"], gramsPerPiece: 120),
        IngredientInfo(id: "cucumber", name: "Огурцы", emoji: "🥒", category: .vegetables, visionKeywords: ["cucumber", "pickle", "zucchini"], gramsPerPiece: 110),
        IngredientInfo(id: "beet", name: "Свёкла", emoji: "🟣", category: .vegetables, visionKeywords: ["beet", "beetroot"], gramsPerPiece: 250),
        IngredientInfo(id: "cabbage", name: "Капуста белокочанная", emoji: "🥬", category: .vegetables, visionKeywords: ["cabbage", "lettuce", "leafy_green"]),
        IngredientInfo(id: "bellPepper", name: "Болгарский перец", emoji: "🫑", category: .vegetables, visionKeywords: ["bell_pepper", "capsicum", "pepper_veggie", "paprika"], gramsPerPiece: 150),
        IngredientInfo(id: "mushrooms", name: "Шампиньоны", emoji: "🍄", category: .vegetables, visionKeywords: ["mushroom", "mushrooms", "fungus"]),
        IngredientInfo(id: "greens", name: "Зелень (укроп, петрушка)", emoji: "🌿", category: .vegetables, visionKeywords: ["herb", "herbs", "parsley", "dill", "basil", "cilantro"]),
        IngredientInfo(id: "lemon", name: "Лимон", emoji: "🍋", category: .vegetables, visionKeywords: ["lemon", "lime", "citrus_fruit"], gramsPerPiece: 120),
        IngredientInfo(id: "apple", name: "Яблоки", emoji: "🍎", category: .vegetables, visionKeywords: ["apple", "apples"], gramsPerPiece: 180),

        // Мясо и рыба
        IngredientInfo(id: "chicken", name: "Курица (филе или бёдра)", emoji: "🍗", category: .meat, visionKeywords: ["chicken", "poultry", "drumstick", "chicken_breast"]),
        IngredientInfo(id: "beef", name: "Говядина", emoji: "🥩", category: .meat, visionKeywords: ["beef", "steak", "meat", "red_meat"]),
        IngredientInfo(id: "mince", name: "Фарш", emoji: "🍖", category: .meat, visionKeywords: ["ground_meat", "mince", "minced_meat", "meat"]),
        IngredientInfo(id: "fish", name: "Рыба (филе)", emoji: "🐟", category: .meat, visionKeywords: ["fish", "salmon", "seafood", "trout", "cod"]),

        // Молочное и яйца
        IngredientInfo(id: "egg", name: "Яйца", emoji: "🥚", category: .dairy, visionKeywords: ["egg", "eggs"], gramsPerPiece: 55),
        IngredientInfo(id: "milk", name: "Молоко", emoji: "🥛", category: .dairy, visionKeywords: ["milk", "dairy"]),
        IngredientInfo(id: "butter", name: "Сливочное масло", emoji: "🧈", category: .dairy, visionKeywords: ["butter"]),
        IngredientInfo(id: "cheese", name: "Сыр твёрдый", emoji: "🧀", category: .dairy, visionKeywords: ["cheese"]),
        IngredientInfo(id: "sourCream", name: "Сметана", emoji: "🥣", category: .dairy, visionKeywords: ["sour_cream", "cream", "yogurt"]),
        IngredientInfo(id: "cottageCheese", name: "Творог", emoji: "⚪️", category: .dairy, visionKeywords: ["cottage_cheese", "curd", "ricotta"]),

        // Бакалея
        IngredientInfo(id: "pasta", name: "Макароны / вермишель", emoji: "🍝", category: .grocery, visionKeywords: ["pasta", "spaghetti", "noodle", "noodles", "macaroni"]),
        IngredientInfo(id: "rice", name: "Рис", emoji: "🍚", category: .grocery, visionKeywords: ["rice"]),
        IngredientInfo(id: "buckwheat", name: "Гречка", emoji: "🌾", category: .grocery, visionKeywords: ["buckwheat", "grain", "cereal"]),
        IngredientInfo(id: "flour", name: "Мука пшеничная", emoji: "🌾", category: .grocery, visionKeywords: ["flour"]),
        IngredientInfo(id: "sugar", name: "Сахар", emoji: "🍬", category: .grocery, visionKeywords: ["sugar"]),
        IngredientInfo(id: "bread", name: "Хлеб", emoji: "🍞", category: .grocery, visionKeywords: ["bread", "toast", "baguette", "loaf"]),
        IngredientInfo(id: "tomatoPaste", name: "Томатная паста", emoji: "🥫", category: .grocery, visionKeywords: ["ketchup", "tomato_sauce", "tomato_paste"]),

        // Базовое
        IngredientInfo(id: "vegOil", name: "Растительное масло", emoji: "🫒", category: .basics, visionKeywords: ["olive_oil", "cooking_oil"], isStaple: true),
        IngredientInfo(id: "salt", name: "Соль", emoji: "🧂", category: .basics, visionKeywords: [], isStaple: true),
        IngredientInfo(id: "pepper", name: "Чёрный перец", emoji: "⚫️", category: .basics, visionKeywords: [], isStaple: true),
        IngredientInfo(id: "bayLeaf", name: "Лавровый лист", emoji: "🍃", category: .basics, visionKeywords: [], isStaple: true),
        IngredientInfo(id: "water", name: "Вода", emoji: "💧", category: .basics, visionKeywords: [], isStaple: true),
    ]

    static let byId: [String: IngredientInfo] = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })

    static func name(for id: String) -> String { byId[id]?.name ?? id }

    static var staples: [IngredientInfo] { all.filter(\.isStaple) }
}
