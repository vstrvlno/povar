import Foundation
import Observation
import UserNotifications
import AudioToolbox
import UIKit

struct CookingTimer: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var duration: TimeInterval
    /// Время окончания, если таймер запущен
    var endDate: Date?
    /// Остаток, если таймер на паузе
    var pausedRemaining: TimeInterval
    var isFinished = false

    var isRunning: Bool { endDate != nil && !isFinished }

    func remaining(at now: Date) -> TimeInterval {
        if isFinished { return 0 }
        if let endDate { return max(0, endDate.timeIntervalSince(now)) }
        return pausedRemaining
    }

    func progress(at now: Date) -> Double {
        guard duration > 0 else { return 1 }
        return min(1, max(0, 1 - remaining(at: now) / duration))
    }
}

/// Несколько параллельных кухонных таймеров с уведомлениями.
@Observable
final class TimerManager {
    var timers: [CookingTimer] = []
    var now = Date()
    /// Последний сработавший таймер — для всплывающего окна
    var lastFinished: CookingTimer?

    @ObservationIgnored private var ticker: Timer?

    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    var activeCount: Int { timers.filter { !$0.isFinished }.count }

    func timer(titled title: String) -> CookingTimer? {
        timers.first { $0.title == title }
    }

    func start(title: String, minutes: Int) {
        start(title: title, seconds: TimeInterval(minutes * 60))
    }

    func start(title: String, seconds: TimeInterval) {
        guard seconds > 0 else { return }
        let timer = CookingTimer(title: title, duration: seconds,
                                 endDate: Date().addingTimeInterval(seconds),
                                 pausedRemaining: seconds)
        timers.insert(timer, at: 0)
        scheduleNotification(for: timer)
        ensureTicker()
    }

    func pause(_ id: UUID) {
        guard let idx = index(id), timers[idx].isRunning else { return }
        timers[idx].pausedRemaining = timers[idx].remaining(at: Date())
        timers[idx].endDate = nil
        cancelNotification(id)
    }

    func resume(_ id: UUID) {
        guard let idx = index(id), !timers[idx].isRunning, !timers[idx].isFinished else { return }
        timers[idx].endDate = Date().addingTimeInterval(timers[idx].pausedRemaining)
        scheduleNotification(for: timers[idx])
        ensureTicker()
    }

    func addMinute(_ id: UUID) {
        guard let idx = index(id) else { return }
        if timers[idx].isFinished {
            timers[idx].isFinished = false
            timers[idx].duration = 60
            timers[idx].endDate = Date().addingTimeInterval(60)
        } else if let end = timers[idx].endDate {
            timers[idx].endDate = end.addingTimeInterval(60)
            timers[idx].duration += 60
        } else {
            timers[idx].pausedRemaining += 60
            timers[idx].duration += 60
        }
        if timers[idx].isRunning {
            scheduleNotification(for: timers[idx])
            ensureTicker()
        }
    }

    func restart(_ id: UUID) {
        guard let idx = index(id) else { return }
        timers[idx].isFinished = false
        timers[idx].endDate = Date().addingTimeInterval(timers[idx].duration)
        timers[idx].pausedRemaining = timers[idx].duration
        scheduleNotification(for: timers[idx])
        ensureTicker()
    }

    func remove(_ id: UUID) {
        cancelNotification(id)
        timers.removeAll { $0.id == id }
    }

    func removeFinished() {
        timers.removeAll { $0.isFinished }
    }

    // MARK: - Private

    private func index(_ id: UUID) -> Int? { timers.firstIndex { $0.id == id } }

    private func ensureTicker() {
        guard ticker == nil else { return }
        let t = Timer(timeInterval: 0.25, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(t, forMode: .common)
        ticker = t
    }

    private func tick() {
        let current = Date()
        now = current
        for idx in timers.indices where timers[idx].isRunning {
            if let end = timers[idx].endDate, end <= current {
                timers[idx].isFinished = true
                timers[idx].endDate = nil
                timers[idx].pausedRemaining = 0
                lastFinished = timers[idx]
                alertUser()
            }
        }
        if !timers.contains(where: \.isRunning) {
            ticker?.invalidate()
            ticker = nil
        }
    }

    private func alertUser() {
        AudioServicesPlayAlertSound(SystemSoundID(1005))
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    private func scheduleNotification(for timer: CookingTimer) {
        cancelNotification(timer.id)
        let remaining = timer.remaining(at: Date())
        guard remaining > 0 else { return }
        let content = UNMutableNotificationContent()
        content.title = "⏰ Таймер готов"
        content.body = timer.title
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, remaining), repeats: false)
        let request = UNNotificationRequest(identifier: timer.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func cancelNotification(_ id: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
    }
}
