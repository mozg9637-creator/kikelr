import Foundation
import UserNotifications

/// Отвечает за локальные уведомления-напоминания о записях.
/// Никаких серверов и push-сертификатов не требуется — всё планируется
/// прямо на устройстве через стандартный UNUserNotificationCenter.
final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    private let center = UNUserNotificationCenter.current()

    /// Запрашивает разрешение на уведомления. Вызывать один раз при старте приложения.
    func requestAuthorizationIfNeeded() {
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .notDetermined else { return }
            self.center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
        }
    }

    var isAuthorized: Bool {
        get async {
            let settings = await center.notificationSettings()
            return settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
        }
    }

    func requestAuthorization() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    /// Планирует напоминание за `minutesBefore` минут до записи.
    /// Если время уже прошло — уведомление просто не будет запланировано.
    func scheduleReminder(for appointment: Appointment, minutesBefore: Int) {
        // сначала убираем старое уведомление для этой записи, если было
        cancelReminder(for: appointment)

        guard !appointment.isBlocked, minutesBefore >= 0 else { return }

        let fireDate = appointment.date.addingTimeInterval(-Double(minutesBefore) * 60)
        guard fireDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Скоро приём: \(appointment.doctorName)"
        let timeString: String = {
            let f = DateFormatter()
            f.dateFormat = "HH:mm"
            return f.string(from: appointment.date)
        }()
        let who = appointment.patientName.isEmpty ? "Пациент" : appointment.patientName
        content.body = minutesBefore == 0
            ? "\(who) — приём в \(timeString)"
            : "\(who) — приём в \(timeString) (через \(minutesBefore) мин.)"
        content.sound = .default

        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)

        let request = UNNotificationRequest(
            identifier: notificationID(for: appointment),
            content: content,
            trigger: trigger
        )
        center.add(request)
    }

    func cancelReminder(for appointment: Appointment) {
        center.removePendingNotificationRequests(withIdentifiers: [notificationID(for: appointment)])
    }

    private func notificationID(for appointment: Appointment) -> String {
        "appointment-\(appointment.id.uuidString)"
    }
}
