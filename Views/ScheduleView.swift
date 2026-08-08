import SwiftUI
import SwiftData

struct ScheduleView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Doctor.sortOrder) private var doctors: [Doctor]
    @Query private var allAppointments: [Appointment]

    @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    @State private var showingAddSheet = false
    @State private var prefillDoctor: Doctor?
    @State private var editingAppointment: Appointment?

    private var calendar: Calendar { Calendar.current }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                dateBar

                if doctors.isEmpty {
                    ContentUnavailableView("Нет врачей", systemImage: "stethoscope",
                                            description: Text("Добавьте врача на вкладке «Врачи»"))
                } else {
                    ScrollView(.horizontal) {
                        HStack(alignment: .top, spacing: 12) {
                            ForEach(doctors) { doctor in
                                doctorColumn(doctor)
                                    .frame(width: 240)
                            }
                        }
                        .padding(12)
                    }
                }
            }
            .navigationTitle("Расписание")
            .sheet(isPresented: $showingAddSheet) {
                AppointmentFormView(
                    doctors: doctors,
                    initialDoctor: prefillDoctor,
                    initialDate: selectedDate,
                    appointment: nil
                )
            }
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

    private var dateBar: some View {
        HStack {
            Button {
                selectedDate = calendar.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
            } label: {
                Image(systemName: "chevron.left")
            }

            Spacer()

            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()

            Spacer()

            Button {
                selectedDate = calendar.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
            } label: {
                Image(systemName: "chevron.right")
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private func doctorColumn(_ doctor: Doctor) -> some View {
        let dayAppts = appointments(for: doctor)

        return VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(doctor.name)
                    .font(.headline)
                Text(doctor.room.isEmpty ? "кабинет не задан" : doctor.room)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: doctor.colorHex).opacity(0.25))
            .cornerRadius(8)

            if dayAppts.isEmpty {
                Text("Нет записей")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
            } else {
                ForEach(dayAppts) { appt in
                    appointmentCell(appt, doctor: doctor)
                        .onTapGesture { editingAppointment = appt }
                }
            }

            Button {
                prefillDoctor = doctor
                showingAddSheet = true
            } label: {
                Label("Добавить запись", systemImage: "plus.circle.fill")
                    .font(.footnote)
            }
            .padding(.top, 4)
        }
    }

    private func appointmentCell(_ appt: Appointment, doctor: Doctor) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 4) {
                Text(timeString(appt.date))
                    .font(.caption).bold()
                if !appt.isBlocked && appt.reminderMinutesBefore >= 0 {
                    Image(systemName: "bell.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }

            if appt.isBlocked {
                Text("Заблокировано")
                    .font(.caption)
            } else {
                Text(appt.patientName.isEmpty ? "Без имени" : appt.patientName)
                    .font(.subheadline).bold()
                    .lineLimit(1)
                if !appt.patientPhone.isEmpty {
                    Text(appt.patientPhone)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                if appt.isPreliminary {
                    Text("Предв. запись")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                if !appt.notes.isEmpty {
                    Text(appt.notes)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(appt.isBlocked ? Color.gray.opacity(0.2) : Color(hex: doctor.colorHex).opacity(0.15))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: doctor.colorHex).opacity(0.5), lineWidth: 1)
        )
        .cornerRadius(8)
    }

    private func appointments(for doctor: Doctor) -> [Appointment] {
        allAppointments
            .filter { $0.doctorID == doctor.id && calendar.isDate($0.date, inSameDayAs: selectedDate) }
            .sorted { $0.date < $1.date }
    }

    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
