import SwiftUI
import SwiftData

struct SettingsView: View {
    // Общие пользовательские настройки — хранятся в UserDefaults через @AppStorage,
    // применяются сразу, без перезапуска приложения.
    @AppStorage("defaultReminderMinutes") private var defaultReminderMinutes: Int = 30
    @AppStorage("workDayStartHour") private var workDayStartHour: Int = 8
    @AppStorage("workDayEndHour") private var workDayEndHour: Int = 18
    @AppStorage("accentColorHex") private var accentColorHex: String = "8A6FD8"
    @AppStorage("showDeveloperSettings") private var showDeveloperSettings: Bool = false

    private let reminderOptions: [(String, Int)] = [
        ("Без напоминания", -1),
        ("В момент приёма", 0),
        ("За 15 минут", 15),
        ("За 30 минут", 30),
        ("За 1 час", 60),
        ("За 2 часа", 120),
        ("За день", 1440)
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Напоминания по умолчанию") {
                    Picker("Для новых записей", selection: $defaultReminderMinutes) {
                        ForEach(reminderOptions, id: \.1) { option in
                            Text(option.0).tag(option.1)
                        }
                    }
                    Text("Применяется при создании новой записи — потом можно менять индивидуально.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Рабочий день") {
                    Stepper("Начало: \(workDayStartHour):00", value: $workDayStartHour, in: 0...23)
                    Stepper("Конец: \(workDayEndHour):00", value: $workDayEndHour, in: 1...23)
                }

                Section("Внешний вид") {
                    Picker("Акцентный цвет", selection: $accentColorHex) {
                        ForEach(Palette.hexes, id: \.self) { hex in
                            HStack {
                                Circle().fill(Color(hex: hex)).frame(width: 16, height: 16)
                                Text("#\(hex)")
                            }.tag(hex)
                        }
                    }
                }

                NavigationLink {
                    NotificationDiagnosticsView()
                } label: {
                    Label("Диагностика уведомлений", systemImage: "bell.badge")
                }

                Section {
                    Toggle("Показывать настройки разработчика", isOn: $showDeveloperSettings)
                    if showDeveloperSettings {
                        NavigationLink {
                            DeveloperSettingsView()
                        } label: {
                            Label("Для разработчика", systemImage: "hammer")
                        }
                    }
                } footer: {
                    Text("Доступ к логам приложения, статистике базы данных и служебным действиям.")
                }
            }
            .navigationTitle("Настройки")
        }
    }
}
