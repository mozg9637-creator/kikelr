import SwiftUI
import SwiftData
import UserNotifications

final class NotificationPresenter: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationPresenter()

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .list])
    }
}

@main
struct PatientPlannerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Doctor.self, Appointment.self, Patient.self, ExamRecord.self])
        // Данные хранятся полностью локально на устройстве (SQLite через SwiftData),
        // никакой отправки данных куда-либо не происходит.
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Не удалось создать локальное хранилище: \(error)")
        }
    }()

    init() {
        UNUserNotificationCenter.current().delegate = NotificationPresenter.shared
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
}
