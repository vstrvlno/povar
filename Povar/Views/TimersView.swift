import SwiftUI

struct TimersView: View {
    @Environment(TimerManager.self) private var timers
    @State private var customTitle = ""
    @State private var customMinutes = 5
    @State private var customSeconds = 0

    private let presets = [1, 3, 5, 7, 10, 15, 20, 30]

    private let cheatSheet: [CheatItem] = [
        CheatItem(title: "🥚 Яйца всмятку", minutes: 3),
        CheatItem(title: "🥚 Яйца в мешочек", minutes: 6),
        CheatItem(title: "🥚 Яйца вкрутую", minutes: 9),
        CheatItem(title: "🍝 Макароны", minutes: 9),
        CheatItem(title: "🌾 Гречка", minutes: 15),
        CheatItem(title: "🍚 Рис", minutes: 18),
        CheatItem(title: "🥔 Картофель в мундире", minutes: 25),
        CheatItem(title: "🍗 Куриное филе (варка)", minutes: 20),
        CheatItem(title: "🥦 Брокколи на пару", minutes: 6),
    ]

    var body: some View {
        NavigationStack {
            List {
                Section("Активные таймеры") {
                    if timers.timers.isEmpty {
                        Text("Нет запущенных таймеров. Запустите таймер здесь или кнопкой «Таймер» в шаге рецепта.")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    } else {
                        ForEach(timers.timers) { timer in
                            TimerRow(timer: timer)
                        }
                        .onDelete { offsets in
                            offsets.map { timers.timers[$0].id }.forEach(timers.remove)
                        }
                    }
                }

                Section("Быстрый старт") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                        ForEach(presets, id: \.self) { minutes in
                            Button {
                                timers.start(title: "Таймер \(minutes) мин", minutes: minutes)
                            } label: {
                                Text("\(minutes) мин")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.orange.opacity(0.15), in: RoundedRectangle(cornerRadius: 10))
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Свой таймер") {
                    TextField("Название, например «Курица в духовке»", text: $customTitle)
                    Stepper("Минуты: \(customMinutes)", value: $customMinutes, in: 0...300)
                    Stepper("Секунды: \(customSeconds)", value: $customSeconds, in: 0...55, step: 5)
                    Button {
                        let title = customTitle.trimmingCharacters(in: .whitespaces)
                        timers.start(title: title.isEmpty ? "Таймер" : title,
                                     seconds: TimeInterval(customMinutes * 60 + customSeconds))
                        customTitle = ""
                    } label: {
                        Label("Запустить", systemImage: "play.fill")
                    }
                    .disabled(customMinutes == 0 && customSeconds == 0)
                }

                Section("Шпаргалка по времени") {
                    ForEach(cheatSheet) { item in
                        HStack {
                            Text(item.title)
                            Spacer()
                            Text("\(item.minutes) мин").foregroundStyle(.secondary)
                            Button {
                                timers.start(title: item.title, minutes: item.minutes)
                            } label: {
                                Image(systemName: "play.circle.fill").font(.title2)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
            .navigationTitle("Таймеры")
            .toolbar {
                if timers.timers.contains(where: \.isFinished) {
                    Button("Убрать готовые") { timers.removeFinished() }
                }
            }
        }
    }
}

private struct CheatItem: Identifiable {
    let title: String
    let minutes: Int
    var id: String { title }
}

struct TimerRow: View {
    let timer: CookingTimer
    @Environment(TimerManager.self) private var manager

    var body: some View {
        let remaining = timer.remaining(at: manager.now)
        HStack(spacing: 14) {
            ZStack {
                Circle().stroke(Color.secondary.opacity(0.2), lineWidth: 6)
                Circle()
                    .trim(from: 0, to: timer.progress(at: manager.now))
                    .stroke(timer.isFinished ? Color.green : Color.orange,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 46, height: 46)

            VStack(alignment: .leading, spacing: 2) {
                Text(timer.title)
                    .font(.subheadline)
                    .lineLimit(2)
                Text(timer.isFinished ? "Готово!" : formatTime(remaining))
                    .font(.title2.monospacedDigit().weight(.bold))
                    .foregroundStyle(timer.isFinished ? Color.green : (timer.isRunning ? Color.primary : Color.secondary))
            }

            Spacer()

            if timer.isFinished {
                Button { manager.restart(timer.id) } label: {
                    Image(systemName: "arrow.clockwise.circle.fill").font(.title)
                }
            } else {
                Button {
                    if timer.isRunning { manager.pause(timer.id) } else { manager.resume(timer.id) }
                } label: {
                    Image(systemName: timer.isRunning ? "pause.circle.fill" : "play.circle.fill").font(.title)
                }
            }
            Button { manager.addMinute(timer.id) } label: {
                Text("+1")
                    .font(.subheadline.weight(.bold))
                    .padding(8)
                    .background(Color.orange.opacity(0.15), in: Circle())
            }
        }
        .buttonStyle(.borderless)
        .padding(.vertical, 4)
    }
}
