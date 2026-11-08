import Foundation

private func i(_ id: String, _ amount: Double, _ unit: MeasureUnit, _ note: String? = nil, optional: Bool = false) -> RecipeIngredient {
    RecipeIngredient(id: id, amount: amount, unit: unit, note: note, optional: optional)
}

private func s(_ text: String, _ heat: HeatLevel = .off, _ minutes: Int? = nil, temp: Int? = nil, parallel: Bool = false) -> CookingStep {
    CookingStep(text: text, heat: heat, minutes: minutes, temperature: temp, parallel: parallel)
}

enum RecipeBook {
    static let all: [Recipe] = [
        Recipe(
            id: "omelet", name: "Пышный омлет", emoji: "🍳", category: .breakfast,
            summary: "Нежный омлет на молоке под крышкой — за 10 минут.",
            baseServings: 2, difficulty: .easy, prepMinutes: 3,
            ingredients: [
                i("egg", 4, .pcs), i("milk", 80, .ml), i("butter", 15, .g),
                i("salt", 1, .pinch), i("greens", 10, .g, optional: true),
            ],
            cookware: [.bowl, .whisk, .pan, .lid, .spatula],
            steps: [
                s("Взбейте яйца с молоком и щепоткой соли венчиком до однородности — не до пены."),
                s("Разогрейте сковороду и растопите на ней сливочное масло.", .medium, 2),
                s("Вылейте яичную смесь, сразу накройте крышкой и убавьте огонь.", .low, 6),
                s("Когда омлет схватится сверху, посыпьте рубленой зеленью и подавайте сразу."),
            ],
            tips: ["Не поднимайте крышку первые 4 минуты — омлет не опадёт.",
                   "Пропорция: на 1 яйцо — 20 мл молока."]
        ),
        Recipe(
            id: "pancakes", name: "Тонкие блины", emoji: "🥞", category: .breakfast,
            summary: "Классические блины на молоке, около 12–14 штук.",
            baseServings: 4, difficulty: .medium, prepMinutes: 10,
            ingredients: [
                i("milk", 500, .ml), i("egg", 2, .pcs), i("flour", 200, .g),
                i("sugar", 1, .tbsp), i("salt", 1, .pinch), i("vegOil", 2, .tbsp, "в тесто"),
                i("butter", 30, .g, "для смазывания", optional: true),
            ],
            cookware: [.bowl, .whisk, .pan, .ladle, .spatula],
            steps: [
                s("Взбейте яйца с сахаром и солью."),
                s("Влейте половину молока, затем постепенно всыпьте муку и вымешайте без комков."),
                s("Добавьте оставшееся молоко и растительное масло. Дайте тесту постоять.", .off, 15),
                s("Сильно разогрейте сковороду, смажьте её маслом один раз.", .high, 2),
                s("Наливайте тесто тонким слоем, вращая сковороду. Жарьте до золотистых краёв, переверните — около 1 минуты на сторону.", .mediumHigh, 1),
                s("Повторяйте, пока не закончится тесто. Готовые блины смазывайте сливочным маслом.", .mediumHigh, 20),
            ],
            tips: ["Если блины рвутся — добавьте 1 ст. л. муки; если толстые — немного молока.",
                   "Первый блин часто «комом» — это прогрев сковороды, не расстраивайтесь."]
        ),
        Recipe(
            id: "syrniki", name: "Сырники", emoji: "🧀", category: .breakfast,
            summary: "Румяные сырники из творога со сметаной.",
            baseServings: 3, difficulty: .easy, prepMinutes: 10,
            ingredients: [
                i("cottageCheese", 400, .g, "9%, не водянистый"), i("egg", 1, .pcs), i("flour", 60, .g, "+ для обваливания"),
                i("sugar", 2, .tbsp), i("salt", 1, .pinch), i("vegOil", 3, .tbsp),
                i("sourCream", 100, .g, "для подачи", optional: true),
            ],
            cookware: [.bowl, .fork, .pan, .lid, .spatula],
            steps: [
                s("Разомните творог вилкой, смешайте с яйцом, сахаром и солью."),
                s("Добавьте муку и замесите мягкое, слегка липкое тесто."),
                s("Мокрыми руками сформируйте шайбы толщиной 1,5 см и обваляйте в муке."),
                s("Разогрейте масло на сковороде.", .medium, 2),
                s("Обжарьте сырники с одной стороны до румяной корочки.", .medium, 4),
                s("Переверните, накройте крышкой и доведите до готовности.", .low, 4),
            ],
            tips: ["Слишком влажный творог отожмите через марлю — меньше муки, нежнее сырники."]
        ),
        Recipe(
            id: "borscht", name: "Борщ", emoji: "🍲", category: .soup,
            summary: "Наваристый борщ на говяжьем бульоне.",
            baseServings: 6, difficulty: .medium, prepMinutes: 20,
            ingredients: [
                i("beef", 500, .g, "на кости"), i("water", 2500, .ml), i("beet", 1, .pcs),
                i("cabbage", 300, .g), i("potato", 3, .pcs), i("carrot", 1, .pcs), i("onion", 1, .pcs),
                i("tomatoPaste", 2, .tbsp), i("garlic", 2, .pcs), i("vegOil", 2, .tbsp),
                i("lemon", 0.25, .pcs, "или 1 ч. л. уксуса", optional: true),
                i("bayLeaf", 2, .pcs), i("salt", 1, .toTaste), i("pepper", 1, .toTaste),
                i("sourCream", 100, .g, "для подачи", optional: true), i("greens", 15, .g, optional: true),
            ],
            cookware: [.bigPot, .deepPan, .board, .knife, .grater, .ladle],
            steps: [
                s("Залейте говядину холодной водой и доведите до кипения.", .high, 10),
                s("Снимите пену, убавьте огонь и варите бульон под приоткрытой крышкой.", .low, 80),
                s("Достаньте мясо, нарежьте и верните. Добавьте картофель кубиками и нашинкованную капусту.", .medium, 15),
                s("Тем временем обжарьте лук и тёртую морковь на масле.", .medium, 5, parallel: true),
                s("Добавьте к зажарке тёртую свёклу, томатную пасту и лимонный сок, тушите.", .low, 10, parallel: true),
                s("Переложите зажарку в кастрюлю, добавьте лавровый лист, соль и перец.", .medium, 5),
                s("Добавьте измельчённый чеснок, выключите огонь и дайте настояться под крышкой.", .off, 15),
            ],
            tips: ["Кислота (лимон или уксус) при тушении сохраняет яркий цвет свёклы.",
                   "На следующий день борщ ещё вкуснее."]
        ),
        Recipe(
            id: "chickenSoup", name: "Куриный суп с лапшой", emoji: "🍜", category: .soup,
            summary: "Лёгкий домашний суп — согревает и лечит.",
            baseServings: 4, difficulty: .easy, prepMinutes: 10,
            ingredients: [
                i("chicken", 300, .g), i("water", 2000, .ml), i("potato", 2, .pcs),
                i("carrot", 1, .pcs), i("onion", 1, .pcs), i("pasta", 80, .g, "вермишель"),
                i("bayLeaf", 1, .pcs), i("salt", 1, .toTaste), i("pepper", 1, .toTaste),
                i("greens", 10, .g, optional: true),
            ],
            cookware: [.pot, .board, .knife, .ladle],
            steps: [
                s("Залейте курицу холодной водой, доведите до кипения и снимите пену.", .high, 8),
                s("Варите бульон на слабом огне.", .low, 25),
                s("Добавьте картофель кубиками.", .medium, 10),
                s("Добавьте нарезанные морковь и лук.", .medium, 5),
                s("Всыпьте вермишель, положите лавровый лист, посолите.", .medium, 5),
                s("Посыпьте зеленью и дайте постоять под крышкой.", .off, 5),
            ],
            tips: ["Вермишель кладите в самом конце — иначе разбухнет."]
        ),
        Recipe(
            id: "friedPotato", name: "Жареная картошка с луком", emoji: "🥔", category: .main,
            summary: "Хрустящая картошка с золотистым луком.",
            baseServings: 3, difficulty: .easy, prepMinutes: 10,
            ingredients: [
                i("potato", 800, .g), i("onion", 1, .pcs), i("vegOil", 4, .tbsp),
                i("salt", 1, .toTaste), i("pepper", 1, .toTaste), i("greens", 10, .g, optional: true),
            ],
            cookware: [.board, .knife, .pan, .spatula],
            steps: [
                s("Очистите картофель, нарежьте брусочками 1 см. Промойте и обсушите полотенцем."),
                s("Хорошо разогрейте масло на сковороде.", .high, 2),
                s("Выложите картофель одним слоем и не мешайте, пока не появится корочка.", .mediumHigh, 7),
                s("Переверните, добавьте лук полукольцами.", .medium, 8),
                s("Посолите, поперчите, перемешайте и доведите до готовности.", .medium, 4),
            ],
            tips: ["Солите в самом конце — иначе картошка пустит сок и не будет хрустящей.",
                   "Не накрывайте крышкой, если нужна корочка."]
        ),
        Recipe(
            id: "pastaTomato", name: "Паста с томатным соусом", emoji: "🍝", category: .main,
            summary: "Простая паста с соусом из свежих помидоров и чеснока.",
            baseServings: 2, difficulty: .easy, prepMinutes: 5,
            ingredients: [
                i("pasta", 200, .g), i("water", 2000, .ml), i("tomato", 3, .pcs), i("garlic", 2, .pcs),
                i("vegOil", 2, .tbsp), i("sugar", 0.5, .tsp, optional: true), i("salt", 1, .toTaste),
                i("cheese", 40, .g, optional: true), i("greens", 5, .g, "базилик", optional: true),
            ],
            cookware: [.pot, .pan, .colander, .board, .knife, .grater],
            steps: [
                s("Вскипятите воду в кастрюле и посолите (10 г соли на литр).", .high, 10),
                s("Варите макароны, помешивая, — время смотрите на пачке.", .medium, 9),
                s("Тем временем обжарьте измельчённый чеснок на масле до аромата.", .low, 1, parallel: true),
                s("Добавьте помидоры кубиками, соль и сахар, тушите до соуса.", .medium, 8, parallel: true),
                s("Откиньте пасту на дуршлаг, оставив 50 мл воды. Смешайте с соусом.", .low, 1),
                s("Посыпьте тёртым сыром и подавайте."),
            ],
            tips: ["Немного воды от варки делает соус шелковистым и помогает ему «прилипнуть»."]
        ),
        Recipe(
            id: "navyPasta", name: "Макароны по-флотски", emoji: "🍖", category: .main,
            summary: "Сытное блюдо из макарон и обжаренного фарша.",
            baseServings: 4, difficulty: .easy, prepMinutes: 5,
            ingredients: [
                i("pasta", 300, .g), i("water", 3000, .ml), i("mince", 400, .g), i("onion", 1, .pcs),
                i("tomatoPaste", 1, .tbsp, optional: true), i("vegOil", 1, .tbsp),
                i("salt", 1, .toTaste), i("pepper", 1, .toTaste),
            ],
            cookware: [.bigPot, .deepPan, .colander, .board, .knife, .spatula],
            steps: [
                s("Вскипятите и посолите воду.", .high, 10),
                s("Отварите макароны до готовности.", .medium, 9),
                s("Тем временем обжарьте мелко нарезанный лук.", .medium, 4, parallel: true),
                s("Добавьте фарш и жарьте, разбивая комочки лопаткой. Добавьте томатную пасту, соль, перец.", .mediumHigh, 10, parallel: true),
                s("Смешайте макароны с фаршем и прогрейте вместе.", .low, 2),
            ]
        ),
        Recipe(
            id: "buckwheatMushrooms", name: "Гречка с грибами и луком", emoji: "🍄", category: .main,
            summary: "Рассыпчатая гречка с ароматными жареными грибами.",
            baseServings: 3, difficulty: .easy, prepMinutes: 10,
            ingredients: [
                i("buckwheat", 200, .g), i("water", 400, .ml), i("mushrooms", 300, .g),
                i("onion", 1, .pcs), i("butter", 20, .g), i("vegOil", 2, .tbsp), i("salt", 1, .toTaste),
            ],
            cookware: [.pot, .lid, .pan, .board, .knife, .spatula],
            steps: [
                s("Промойте гречку. Залейте водой 1:2, посолите и доведите до кипения.", .high, 3),
                s("Убавьте огонь и варите под крышкой, не открывая.", .low, 15),
                s("Тем временем обжарьте лук на растительном масле.", .medium, 5, parallel: true),
                s("Добавьте нарезанные грибы и жарьте, пока не испарится жидкость.", .mediumHigh, 10, parallel: true),
                s("Смешайте гречку с грибами и сливочным маслом, дайте постоять под крышкой.", .off, 10),
            ]
        ),
        Recipe(
            id: "chickenFillet", name: "Сочное куриное филе", emoji: "🍗", category: .main,
            summary: "Филе на сковороде с чесноком и сливочным маслом.",
            baseServings: 2, difficulty: .easy, prepMinutes: 10,
            ingredients: [
                i("chicken", 400, .g, "филе"), i("vegOil", 1, .tbsp), i("butter", 15, .g),
                i("garlic", 2, .pcs), i("lemon", 0.5, .pcs, optional: true),
                i("salt", 1, .toTaste), i("pepper", 1, .toTaste),
            ],
            cookware: [.board, .knife, .pan, .lid, .spatula],
            steps: [
                s("Слегка отбейте филе до толщины 1,5 см, посолите и поперчите."),
                s("Разогрейте сковороду с растительным маслом.", .high, 2),
                s("Обжарьте филе с одной стороны, не сдвигая.", .mediumHigh, 4),
                s("Переверните, добавьте сливочное масло и раздавленный чеснок, поливайте мясо маслом.", .medium, 4),
                s("Накройте крышкой и доведите до готовности.", .low, 3),
                s("Переложите на доску и дайте отдохнуть, сбрызните лимоном.", .off, 5),
            ],
            tips: ["Готово, когда сок при проколе прозрачный (74 °C внутри).",
                   "«Отдых» удерживает сок внутри — не режьте сразу."]
        ),
        Recipe(
            id: "pilaf", name: "Плов с курицей", emoji: "🍛", category: .main,
            summary: "Рассыпчатый плов в казане.",
            baseServings: 4, difficulty: .medium, prepMinutes: 20,
            ingredients: [
                i("rice", 300, .g, "длиннозёрный"), i("chicken", 500, .g, "бёдра"), i("carrot", 2, .pcs),
                i("onion", 2, .pcs), i("garlic", 6, .pcs, "1 головка"), i("vegOil", 80, .ml),
                i("water", 600, .ml), i("salt", 1, .toTaste), i("pepper", 1, .toTaste),
            ],
            cookware: [.cauldron, .lid, .board, .knife, .spatula],
            steps: [
                s("Промойте рис до прозрачной воды и замочите в тёплой воде.", .off, 20, parallel: true),
                s("Разогрейте масло в казане, обжарьте курицу кусочками.", .high, 7),
                s("Добавьте лук полукольцами.", .mediumHigh, 5),
                s("Добавьте морковь соломкой и обжарьте.", .medium, 7),
                s("Залейте горячей водой, посолите, поперчите и тушите (зирвак).", .low, 15),
                s("Выложите рис ровным слоем, долейте воду на 1,5 см выше риса. Варите до выкипания воды с поверхности.", .high, 8),
                s("Воткните чеснок, сделайте палочкой проколы, накройте и томите.", .low, 20),
                s("Выключите огонь, дайте настояться и перемешайте.", .off, 10),
            ],
            tips: ["После закладки риса не мешайте плов до самого конца."]
        ),
        Recipe(
            id: "bakedFish", name: "Рыба, запечённая с овощами", emoji: "🐟", category: .main,
            summary: "Рыба с картофелем и помидорами под сырной корочкой.",
            baseServings: 2, difficulty: .easy, prepMinutes: 15,
            ingredients: [
                i("fish", 400, .g), i("potato", 3, .pcs), i("tomato", 1, .pcs), i("onion", 1, .pcs),
                i("lemon", 0.5, .pcs), i("vegOil", 2, .tbsp), i("cheese", 50, .g, optional: true),
                i("salt", 1, .toTaste), i("pepper", 1, .toTaste), i("greens", 10, .g, optional: true),
            ],
            cookware: [.oven, .bakingDish, .foil, .board, .knife, .grater],
            steps: [
                s("Разогрейте духовку.", .oven, 10, temp: 200),
                s("Нарежьте картофель тонкими кружками, смешайте с маслом и солью, выложите в форму."),
                s("Запекайте картофель.", .oven, 15, temp: 200),
                s("Выложите сверху рыбу, сбрызните лимоном, посолите. Накройте кольцами лука и помидоров."),
                s("Запекайте под фольгой.", .oven, 15, temp: 200),
                s("Снимите фольгу, посыпьте сыром и запекайте до румяности.", .oven, 7, temp: 200),
            ]
        ),
        Recipe(
            id: "vegSalad", name: "Салат из свежих овощей", emoji: "🥗", category: .salad,
            summary: "Летний салат из огурцов и помидоров со сметаной.",
            baseServings: 3, difficulty: .easy, prepMinutes: 10,
            ingredients: [
                i("tomato", 2, .pcs), i("cucumber", 2, .pcs), i("onion", 0.5, .pcs, "или зелёный лук"),
                i("bellPepper", 1, .pcs, optional: true), i("greens", 15, .g),
                i("sourCream", 3, .tbsp, "или 2 ст. л. масла"), i("salt", 1, .toTaste), i("pepper", 1, .toTaste),
            ],
            cookware: [.board, .knife, .bowl],
            steps: [
                s("Вымойте и обсушите овощи и зелень."),
                s("Нарежьте помидоры дольками, огурцы — полукружьями, перец — соломкой."),
                s("Лук нарежьте тонко и ошпарьте кипятком, чтобы убрать горечь."),
                s("Перемешайте, заправьте сметаной и посолите прямо перед подачей."),
            ],
            tips: ["Солите перед самой подачей — иначе овощи пустят сок."]
        ),
        Recipe(
            id: "charlotte", name: "Шарлотка с яблоками", emoji: "🍎", category: .dessert,
            summary: "Самый простой яблочный пирог — всего 4 продукта.",
            baseServings: 8, difficulty: .easy, prepMinutes: 15,
            ingredients: [
                i("egg", 4, .pcs), i("sugar", 200, .g), i("flour", 200, .g), i("apple", 4, .pcs, "кислые"),
                i("butter", 10, .g, "для формы"), i("salt", 1, .pinch),
            ],
            cookware: [.oven, .bakingDish, .mixer, .bowl, .board, .knife, .spatula],
            steps: [
                s("Разогрейте духовку.", .oven, 10, temp: 180),
                s("Взбейте яйца с сахаром и солью миксером до пышной светлой массы.", .off, 7, parallel: true),
                s("Аккуратно вмешайте просеянную муку лопаткой движениями снизу вверх."),
                s("Смажьте форму маслом, выложите нарезанные яблоки и залейте тестом."),
                s("Выпекайте, не открывая духовку первые 25 минут.", .oven, 40, temp: 180),
                s("Проверьте сухой шпажкой. Остудите в форме.", .off, 10),
            ],
            tips: ["Форма 22–24 см. При увеличении порций берите форму побольше или пеките в два захода — время выпечки увеличится."]
        ),
    ]

    static let byId: [String: Recipe] = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })
}
