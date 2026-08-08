import SwiftUI
import SwiftData

struct AppointmentFormView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let doctors: [Doctor]
    let appointment: Appointment?

    @State private var selectedDoctorID: UUID
    @State private var date: Date
    @State private var patientName: String
    @State private var patientPhone: String
    @State private var notes: String
    @State private var isBlocked: Bool
    @State private var isPreliminary: Bool
    @State private var reminderMinutes: Int
    @State private var showDeleteConfirm = false

    private static let reminderOptions: [(label: String, value: Int)] = [
        ("Без напоминания", -1),
        ("В момент приёма", 0),
        ("За 15 минут", 15),
        ("За 30 минут", 30),
        ("За 1 час", 60),
        ("За 2 часа", 120),
        ("За день", 1440)
    ]

    init(doctors: [Doctor], initialDoctor: Doctor?, initialDate: Date, appointment: Appointment?) {
        self.doctors = doctors
        self.appointment = appointment

        _selectedDoctorID = State(initialValue: appointment?.doctorID ?? initialDoctor?.id ?? doctors.first?.id ?? UUID())
        _date = State(initialValue: appointment?.date ?? initialDate)
        _patientName = State(initialValue: appointment?.patientName ?? "")
        _patientPhone = State(initialValue: appointment?.patientPhone ?? "")
        _notes = State(initialValue: appointment?.notes ?? "")
        _isBlocked = State(initialValue: appointment?.isBlocked ?? false)
        _isPreliminary = State(initialValue: appointment?.isPreliminary ?? true)
        _reminderMinutes = State(initialValue: appointment?.reminderMinutesBefore ?? 30)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Врач и время") {
                    Picker("Врач", selection: $selectedDoctorID) {
                        ForEach(doctors) { doctor in
                            Text(doctor.name).tag(doctor.id)
                        }
                    }
                    DatePicker("Дата", selection: $date, displayedComponents: .date)
                    DatePicker("Время", selection: $date, displayedComponents: .hourAndMinute)
                }

                Section {
                    Toggle("Слот заблокирован", isOn: $isBlocked)
                }

                if !isBlocked {
                    Section("Пациент") {
                        TextField("ФИО пациента", text: $patientName)
                        TextField("Телефон", text: $patientPhone)
                            .keyboardType(.phonePad)
                        Toggle("Предварительная запись", isOn: $isPreliminary)
                    }

                    Section("Заметки") {
                        TextField("Комментарий", text: $notes, axis: .vertical)
                            .lineLimit(3...6)
                    }

                    Section("Напоминание") {
                        Picker("Напомнить", selection: $reminderMinutes) {
                            ForEach(Self.reminderOptions, id: \.value) { option in
                                Text(option.label).tag(option.value)
                            }
                        }
                        Text("Локальное уведомление на этом устройстве, интернет не нужен.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                if appointment != nil {
                    Section {
                        Button("Удалить запись", role: .destructive) {
                            showDeleteConfirm = true
                        }
                    }
                }
            }
            .navigationTitle(appointment == nil ? "Новая запись" : "Редактирование")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") { save() }
                        .disabled(!isBlocked && patientName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .confirmationDialog("Удалить эту запись?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                Button("Удалить", role: .destructive) { delete() }
                Button("Отмена", role: .cancel) {}
            }
        }
    }

    private var selectedDoctor: Doctor? {
        doctors.first(where: { $0.id == selectedDoctorID })
    }

    private func save() {
        guard let doctor = selectedDoctor else { return }

        if let appt = appointment {
            appt.doctorID = doctor.id
            appt.doctorName = doctor.name
            appt.date = date
            appt.patientName = isBlocked ? "" : patientName
            appt.patientPhone = isBlocked ? "" : patientPhone
            appt.notes = isBlocked ? "" : notes
            appt.isBlocked = isBlocked
            appt.isPreliminary = isPreliminary
            appt.reminderMinutesBefore = reminderMinutes

            try? context.save()
            if isBlocked || reminderMinutes < 0 {
                NotificationManager.shared.cancelReminder(for: appt)
            } else {
                NotificationManager.shared.scheduleReminder(for: appt, minutesBefore: reminderMinutes)
            }
        } else {
            let newAppt = Appointment(
                doctorID: doctor.id,
                doctorName: doctor.name,
                date: date,
                patientName: isBlocked ? "" : patientName,
                patientPhone: isBlocked ? "" : patientPhone,
                notes: isBlocked ? "" : notes,
                isBlocked: isBlocked,
                isPreliminary: isPreliminary,
                reminderMinutesBefore: reminderMinutes
            )
            context.insert(newAppt)
            try? context.save()
            if !isBlocked && reminderMinutes >= 0 {
                NotificationManager.shared.scheduleReminder(for: newAppt, minutesBefore: reminderMinutes)
            }
        }

        dismiss()
    }

    private func delete() {
        if let appt = appointment {
            NotificationManager.shared.cancelReminder(for: appt)
            context.delete(appt)
            try? context.save()
        }
        dismiss()
    }
}
