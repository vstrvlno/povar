import SwiftUI

/// Пошаговый режим готовки: большой текст, сила огня, таймеры. Экран не гаснет.
struct CookingModeView: View {
    let recipe: Recipe
    let servings: Int
    @Environment(\.dismiss) private var dismiss
    @Environment(PantryStore.self) private var pantry
    @Environment(TimerManager.self) private var timers
    @State private var page = 0

    private var factor: Double { Double(servings) / Double(recipe.baseServings) }
    private var lastPage: Int { recipe.steps.count }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ProgressView(value: Double(page), total: Double(max(1, lastPage)))
                    .padding(.horizontal)
                    .padding(.top, 8)

                TabView(selection: $page) {
                    preparationPage.tag(0)
                    ForEach(Array(recipe.steps.enumerated()), id: \.element.id) { index, step in
                        stepPage(index: index, step: step).tag(index + 1)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                ActiveTimersStrip()

                HStack {
                    Button {
                        withAnimation { page = max(0, page - 1) }
                    } label: {
                        Label("Назад", systemImage: "chevron.left")
                    }
                    .disabled(page == 0)

                    Spacer()

                    if page < lastPage {
                        Button {
                            withAnimation { page += 1 }
                        } label: {
                            Label(page == 0 ? "Начать" : "Далее", systemImage: "chevron.right")
                                .labelStyle(TrailingIconLabelStyle())
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button("Готово! Приятного аппетита 🎉") { dismiss() }
                            .buttonStyle(.borderedProminent)
                    }
                }
                .controlSize(.large)
                .padding()
            }
            .navigationTitle(recipe.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") { dismiss() }
                }
            }
        }
        .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
    }

    // Подготовка: продукты и посуда
    private var preparationPage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Подготовьте на \(servings) \(plural(servings, "персону", "персоны", "персон"))")
                    .font(.title2.bold())

                VStack(alignment: .leading, spacing: 10) {
                    Text("Продукты").font(.headline)
                    ForEach(recipe.ingredients, id: \.self) { item in
                        IngredientLine(item: item, factor: factor, have: pantry.has(item.id))
                        Divider()
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Посуда").font(.headline)
                    ForEach(recipe.cookware, id: \.self) { item in
                        Text("\(item.emoji)  \(item.title)")
                    }
                }
            }
            .padding()
        }
    }

    private func stepPage(index: Int, step: CookingStep) -> some View {
        let title = "\(recipe.name) — шаг \(index + 1)"
        return ScrollView {
            VStack(spacing: 22) {
                Text("Шаг \(index + 1) из \(recipe.steps.count)")
                    .font(.headline)
                    .foregroundStyle(.orange)

                Text(step.text)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                if step.heat != .off {
                    VStack(spacing: 6) {
                        HeatBadge(heat: step.heat, temperature: step.temperature, large: true)
                        Text(step.heat.dialHint)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                if let minutes = step.minutes {
                    StepTimerCard(title: title, minutes: minutes)
                }
            }
            .padding()
            .padding(.top, 20)
        }
    }
}

private struct StepTimerCard: View {
    let title: String
    let minutes: Int
    @Environment(TimerManager.self) private var timers

    var body: some View {
        VStack(spacing: 12) {
            if let timer = timers.timer(titled: title) {
                Text(timer.isFinished ? "Готово!" : formatTime(timer.remaining(at: timers.now)))
                    .font(.system(size: 56, weight: .bold, design: .rounded).monospacedDigit())
                    .foregroundStyle(timer.isFinished ? .green : .primary)
                HStack(spacing: 12) {
                    if timer.isFinished {
                        Button("Ещё раз") { timers.restart(timer.id) }
                    } else if timer.isRunning {
                        Button("Пауза") { timers.pause(timer.id) }
                    } else {
                        Button("Продолжить") { timers.resume(timer.id) }
                    }
                    Button("+1 мин") { timers.addMinute(timer.id) }
                }
                .buttonStyle(.bordered)
            } else {
                Text(formatMinutes(minutes))
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                Button {
                    timers.start(title: title, minutes: minutes)
                } label: {
                    Label("Запустить таймер", systemImage: "timer")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20))
    }
}

/// Полоса с запущенными таймерами внизу экрана готовки
struct ActiveTimersStrip: View {
    @Environment(TimerManager.self) private var timers

    var body: some View {
        if !timers.timers.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(timers.timers) { timer in
                        HStack(spacing: 6) {
                            Image(systemName: timer.isFinished ? "bell.fill" : "timer")
                            Text(timer.title).lineLimit(1)
                            Text(timer.isFinished ? "готово" : formatTime(timer.remaining(at: timers.now)))
                                .monospacedDigit()
                                .fontWeight(.bold)
                        }
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(timer.isFinished ? Color.green.opacity(0.2) : Color.orange.opacity(0.15), in: Capsule())
                        .onTapGesture {
                            if timer.isFinished { timers.remove(timer.id) }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 6)
        }
    }
}

struct TrailingIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.title
            configuration.icon
        }
    }
}
