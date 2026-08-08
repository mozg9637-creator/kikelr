import SwiftUI
import UserNotifications

struct NotificationDiagnosticsView: View {
    @State private var status: NotificationManager.AuthStatus = .notDetermined
    @State private var pendingCount: Int = 0
    @State private var testMessage: String?
    @State private var testSucceeded = false
    @State private var isSendingTest = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Статус разрешения") {
                    HStack {
                        Image(systemName: statusIcon)
                            .foregroundStyle(statusColor)
                        Text(statusText)
                    }

                    if status == .denied {
                        Button("Открыть настройки уведомлений") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }

                    if status == .notDetermined {
                        Button("Запросить разрешение") {
                            Task {
                                _ = await NotificationManager.shared.requestAuthorization()
                                await refresh()
                            }
                        }
                    }
                }

                Section("Запланировано напоминаний") {
                    Text("\(pendingCount)")
                        .font(.title2).bold()
                    Text("Столько напоминаний о записях сейчас реально стоит в очереди у iOS.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Проверка") {
                    Button {
                        sendTest()
                    } label: {
                        if isSendingTest {
                            ProgressView()
                        } else {
                            Text("Отправить тестовое уведомление (через 10 сек)")
                        }
                    }
                    .disabled(isSendingTest || status == .denied)

                    if let testMessage {
                        Label(testMessage, systemImage: testSucceeded ? "checkmark.circle" : "exclamationmark.triangle")
                            .font(.footnote)
                            .foregroundStyle(testSucceeded ? .green : .orange)
                    }

                    Text("После нажатия сверните приложение (кнопка домой или смахните вверх) и подождите 10 секунд — баннер должен появиться, даже когда приложение свёрнуто.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Если не приходит") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("• Проверьте Настройки → Уведомления → PatientPlanner → «Разрешить уведомления» включено")
                        Text("• Проверьте, не включён ли на телефоне режим «Не беспокоить» / Фокусирование")
                        Text("• Проверьте Настройки → Уведомления → PatientPlanner → «Экран блокировки» и «Баннеры» включены")
                    }
                    .font(.caption)
                }
            }
            .navigationTitle("Диагностика уведомлений")
            .task { await refresh() }
        }
    }

    private func sendTest() {
        isSendingTest = true
        testMessage = nil
        NotificationManager.shared.scheduleTest { success, message in
            isSendingTest = false
            testSucceeded = success
            testMessage = message
            Task { await refresh() }
        }
    }

    private func refresh() async {
        status = await NotificationManager.shared.currentAuthStatus()
        pendingCount = await NotificationManager.shared.pendingCount()
    }

    private var statusText: String {
        switch status {
        case .authorized: return "Разрешено"
        case .denied: return "Запрещено пользователем"
        case .notDetermined: return "Ещё не запрашивалось"
        }
    }

    private var statusIcon: String {
        switch status {
        case .authorized: return "checkmark.circle.fill"
        case .denied: return "xmark.circle.fill"
        case .notDetermined: return "questionmark.circle.fill"
        }
    }

    private var statusColor: Color {
        switch status {
        case .authorized: return .green
        case .denied: return .red
        case .notDetermined: return .orange
        }
    }
}
