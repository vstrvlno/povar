import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @Environment(PantryStore.self) private var pantry
    @Environment(TimerManager.self) private var timers
    @State private var servings: Int
    @State private var cooking = false

    init(recipe: Recipe) {
        self.recipe = recipe
        _servings = State(initialValue: recipe.baseServings)
    }

    private var factor: Double { Double(servings) / Double(recipe.baseServings) }

    var body: some View {
        List {
            // Заголовок
            Section {
                VStack(spacing: 10) {
                    Text(recipe.emoji).font(.system(size: 72))
                    Text(recipe.summary)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 16) {
                        Label(formatMinutes(recipe.totalMinutes), systemImage: "clock")
                        Label(recipe.difficulty.rawValue, systemImage: "chart.bar")
                        Label("\(recipe.steps.count) \(plural(recipe.steps.count, "шаг", "шага", "шагов"))", systemImage: "list.number")
                    }
                    .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
            }

            // Персоны
            Section {
                Stepper(value: $servings, in: 1...20) {
                    Label("\(servings) \(plural(servings, "персона", "персоны", "персон"))", systemImage: "person.2.fill")
                        .font(.headline)
                }
            } header: {
                Text("Сколько персон")
            } footer: {
                if servings != recipe.baseServings {
                    Text("Граммовка пересчитана с \(recipe.baseServings) на \(servings) \(plural(servings, "персону", "персоны", "персон")). Время на шагах почти не меняется, но может понадобиться посуда побольше.")
                }
            }

            // Ингредиенты
            Section {
                ForEach(recipe.ingredients, id: \.self) { item in
                    IngredientLine(item: item, factor: factor, have: pantry.has(item.id))
                }
            } header: {
                Text("Ингредиенты и граммовка")
            } footer: {
                Text("✅ — есть в ваших продуктах. Соль, перец, вода и растительное масло считаются имеющимися.")
            }

            // Посуда
            Section("Посуда") {
                ForEach(recipe.cookware, id: \.self) { item in
                    HStack(spacing: 12) {
                        Text(item.emoji)
                        Text(item.title)
                    }
                }
            }

            // Шаги
            Section("Приготовление") {
                ForEach(Array(recipe.steps.enumerated()), id: \.element.id) { index, step in
                    StepRow(index: index + 1, step: step, timerTitle: timerTitle(index))
                }
            }

            if !recipe.tips.isEmpty {
                Section("Советы") {
                    ForEach(recipe.tips, id: \.self) { tip in
                        Label(tip, systemImage: "lightbulb.fill")
                            .symbolRenderingMode(.multicolor)
                    }
                }
            }
        }
        .navigationTitle(recipe.name)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            Button {
                cooking = true
            } label: {
                Label("Начать готовку", systemImage: "play.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.bar)
        }
        .fullScreenCover(isPresented: $cooking) {
            CookingModeView(recipe: recipe, servings: servings)
                .environment(pantry)
                .environment(timers)
        }
    }

    private func timerTitle(_ index: Int) -> String {
        "\(recipe.name) — шаг \(index + 1)"
    }
}

struct IngredientLine: View {
    let item: RecipeIngredient
    let factor: Double
    let have: Bool

    var body: some View {
        HStack(spacing: 12) {
            Text(item.info?.emoji ?? "•")
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(item.info?.name ?? item.id)
                    if item.optional {
                        Text("по желанию").font(.caption2).foregroundStyle(.secondary)
                    }
                }
                if let note = item.note {
                    Text(note).font(.caption).foregroundStyle(.secondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(item.displayAmount(factor: factor))
                    .font(.body.monospacedDigit().weight(.semibold))
                if let grams = item.approxGrams(factor: factor) {
                    Text("≈ \(grams) г").font(.caption).foregroundStyle(.secondary)
                }
            }
            Image(systemName: have ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(have ? Color.green : Color.secondary.opacity(0.4))
        }
    }
}

struct StepRow: View {
    let index: Int
    let step: CookingStep
    let timerTitle: String
    @Environment(TimerManager.self) private var timers

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Шаг \(index)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.orange)
                if step.parallel {
                    Text("параллельно").font(.caption2).foregroundStyle(.secondary)
                }
                Spacer()
                if step.heat != .off {
                    HeatBadge(heat: step.heat, temperature: step.temperature)
                }
            }
            Text(step.text)
            if let minutes = step.minutes {
                HStack {
                    Label(formatMinutes(minutes), systemImage: "clock")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    if let running = timers.timer(titled: timerTitle), !running.isFinished {
                        Text(formatTime(running.remaining(at: timers.now)))
                            .font(.subheadline.monospacedDigit().weight(.semibold))
                            .foregroundStyle(.orange)
                    } else {
                        Button {
                            timers.start(title: timerTitle, minutes: minutes)
                        } label: {
                            Label("Таймер", systemImage: "timer")
                                .font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.orange.opacity(0.15), in: Capsule())
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}
