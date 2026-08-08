import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Doctor.sortOrder) private var doctors: [Doctor]

    var body: some View {
        TabView {
            ScheduleView()
                .tabItem { Label("Расписание", systemImage: "calendar") }

            PatientsSearchView()
                .tabItem { Label("Пациенты", systemImage: "person.text.rectangle") }

            DoctorsView()
                .tabItem { Label("Врачи", systemImage: "stethoscope") }
        }
        .task {
            seedDoctorsIfNeeded()
            NotificationManager.shared.requestAuthorizationIfNeeded()
        }
    }

    /// При самом первом запуске создаём стартовый список врачей,
    /// чтобы приложением можно было сразу пользоваться.
    private func seedDoctorsIfNeeded() {
        guard doctors.isEmpty else { return }
        let starter = [
            "Терапевт 1",
            "Терапевт 2",
            "Терапевт 3"
        ]
        for (index, name) in starter.enumerated() {
            let doctor = Doctor(name: name, room: "", colorHex: Palette.color(for: index), sortOrder: index)
            context.insert(doctor)
        }
        try? context.save()
    }
}

enum Palette {
    static let hexes = ["8A6FD8", "5FA8D3", "E08E45", "5CAE7A", "D06B9E", "C96A5A"]
    static func color(for index: Int) -> String {
        hexes[index % hexes.count]
    }
}
