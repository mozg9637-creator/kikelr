import SwiftUI
import SwiftData

struct DeveloperSettingsView: View {
    @Environment(\.modelContext) private var context
    @Query private var doctors: [Doctor]
    @Query private var appointments: [Appointment]

    @StateObject private var logger = AppLogger.shared
    @State private var pendingNotifications: Int = 0
    @State private var showResetConfirm = false
    @State private var logFilter: String = ""

    var body: some View {
        Form {
            Section("Информация о приложении") {
                infoRow("Версия", appVersion)
                infoRow("Сборка", buildNumber)
                infoRow("Bundle ID", Bundle.main.bundleIdentifier ?? "—")
                infoRow("iOS", UIDevice.current.systemVersion)
                infoRow("Устройство", UIDevice.current.model)
            }

            Section("База данных") {
                infoRow("Врачей", "\(doctors.count)")
                infoRow("Записей всего", "\(appointments.count)")
                infoRow("Запланировано напоминаний", "\(pendingNotifications)")
            }

            Section("Действия") {
                Button {
                    Task { pendingNotifications = await NotificationManager.shared.pendingCount() }
                } label: {
                    Label("Обновить счётчики", systemImage: "arrow.clockwise")
                }

                Button(role: .destructive) {
                    showResetConfirm = true
                } label: {
                    Label("Удалить все данные (врачи + записи)", systemImage: "trash")
                }
            }

            Section {
                TextField("Фильтр по тексту лога", text: $logFilter)
                    .textInputAutocapitalization(.never)

                if filteredLogs.isEmpty {
                    Text("Логов пока нет")
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                } else {
                    ForEach(filteredLogs.reversed()) { entry in
                        Text(entry.formatted)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(colorFor(entry.category))
                    }
                }
            } header: {
                HStack {
                    Text("Логи (\(filteredLogs.count))")
                    Spacer()
                    Button("Очистить") { logger.clear() }
                        .font(.caption)
                }
            }
        }
        .navigationTitle("Для разработчика")
        .task {
            pendingNotifications = await NotificationManager.shared.pendingCount()
        }
        .confirmationDialog(
            "Удалить всех врачей и все записи без возможности восстановления?",
            isPresented: $showResetConfirm,
            titleVisibility: .visible
        ) {
            Button("Удалить всё", role: .destructive) { resetAllData() }
            Button("Отмена", role: .cancel) {}
        }
    }

    private var filteredLogs: [LogEntry] {
        guard !logFilter.trimmingCharacters(in: .whitespaces).isEmpty else { return logger.entries }
        return logger.entries.filter {
            $0.message.localizedCaseInsensitiveContains(logFilter) ||
            $0.category.localizedCaseInsensitiveContains(logFilter)
        }
    }

    private func colorFor(_ category: String) -> Color {
        switch category {
        case "notifications": return .orange
        case "error": return .red
        default: return .primary
        }
    }

    private func resetAllData() {
        for appt in appointments { context.delete(appt) }
        for doc in doctors { context.delete(doc) }
        try? context.save()
        AppLogger.shared.log("Все данные удалены вручную из настроек разработчика", category: "app")
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).foregroundStyle(.secondary)
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }
}
