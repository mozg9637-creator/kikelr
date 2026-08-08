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
            self.center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    AppLogger.shared.log("Ошибка запроса разрешения: \(error.localizedDescription)", category: "notifications")
                }
                AppLogger.shared.log("Разрешение на уведомления: \(granted ? "получено" : "отклонено")", category: "notifications")
            }
        }
    }

    enum AuthStatus {
        case authorized, denied, notDetermined
    }

    func currentAuthStatus() async -> AuthStatus {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return .authorized
        case .denied:
            return .denied
        default:
            return .notDetermined
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
        center.add(request) { error in
            if let error = error {
                AppLogger.shared.log("Ошибка планирования для \(appointment.patientName): \(error.localizedDescription)", category: "notifications")
            } else {
                AppLogger.shared.log("Запланировано напоминание для \(appointment.patientName.isEmpty ? "записи" : appointment.patientName) на \(fireDate)", category: "notifications")
            }
        }
    }

    /// Тестовое уведомление через 10 секунд — чтобы сразу проверить,
    /// реально ли уведомления доходят на этом устройстве.
    func scheduleTest(completion: @escaping (Bool, String) -> Void) {
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
                DispatchQueue.main.async {
                    completion(false, "Уведомления не разрешены в Настройках iOS для этого приложения.")
                }
                return
            }
            let content = UNMutableNotificationContent()
            content.title = "Тест уведомлений"
            content.body = "Если вы это видите — уведомления работают ✅"
            content.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
            let request = UNNotificationRequest(identifier: "test-notification", content: content, trigger: trigger)
            self.center.add(request) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(false, "Ошибка: \(error.localizedDescription)")
                    } else {
                        completion(true, "Запланировано. Заверните телефон на 10 секунд и подождите — должен прийти баннер.")
                    }
                }
            }
        }
    }

    /// Для отладки: сколько уведомлений сейчас реально стоит в очереди у iOS.
    func pendingCount() async -> Int {
        await center.pendingNotificationRequests().count
    }

    func cancelReminder(for appointment: Appointment) {
        center.removePendingNotificationRequests(withIdentifiers: [notificationID(for: appointment)])
        AppLogger.shared.log("Напоминание отменено для \(appointment.patientName.isEmpty ? "записи" : appointment.patientName)", category: "notifications")
    }

    private func notificationID(for appointment: Appointment) -> String {
        "appointment-\(appointment.id.uuidString)"
    }
}
