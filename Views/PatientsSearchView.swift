import SwiftUI
import SwiftData

struct PatientsSearchView: View {
    @Query(sort: \Appointment.date, order: .reverse) private var allAppointments: [Appointment]
    @State private var searchText = ""
    @State private var editingAppointment: Appointment?
    @Query(sort: \Doctor.sortOrder) private var doctors: [Doctor]

    private var filtered: [Appointment] {
        let nonBlocked = allAppointments.filter { !$0.isBlocked && !$0.patientName.isEmpty }
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return nonBlocked }
        return nonBlocked.filter {
            $0.patientName.localizedCaseInsensitiveContains(searchText) ||
            $0.patientPhone.contains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if filtered.isEmpty {
                    ContentUnavailableView("Пациенты не найдены", systemImage: "person.crop.circle.badge.questionmark")
                } else {
                    ForEach(filtered) { appt in
                        Button {
                            editingAppointment = appt
                        } label: {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(appt.patientName)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text(appt.patientPhone)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text("\(appt.doctorName) · \(formatted(appt.date))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Пациенты")
            .searchable(text: $searchText, prompt: "Имя или телефон")
            .sheet(item: $editingAppointment) { appt in
                AppointmentFormView(
                    doctors: doctors,
                    initialDoctor: doctors.first(where: { $0.id == appt.doctorID }),
                    initialDate: appt.date,
                    appointment: appt
                )
            }
        }
    }

    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        return formatter.string(from: date)
    }
}
