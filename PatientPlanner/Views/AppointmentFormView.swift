import SwiftUI
import SwiftData

struct AppointmentFormView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let doctors: [Doctor]
    let appointment: Appointment?
    @Query(sort: \Patient.fullName) private var allPatients: [Patient]

    @State private var selectedDoctorID: UUID
    @State private var date: Date
    @State private var patientName: String
    @State private var patientPhone: String
    @State private var notes: String
    @State private var isBlocked: Bool
    @State private var isPreliminary: Bool
    @State private var reminderMinutes: Int
    @State private var showDeleteConfirm = false
    @State private var openPatientCard: Patient?

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
        let defaultReminder = UserDefaults.standard.object(forKey: "defaultReminderMinutes") as? Int ?? 30
        _reminderMinutes = State(initialValue: appointment?.reminderMinutesBefore ?? defaultReminder)
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
                        if let appt = appointment, let patientID = appt.patientID {
                            Button {
                                openExistingPatientCard(patientID: patientID)
                            } label: {
                                Label("Открыть карточку пациента", systemImage: "person.text.rectangle")
                            }
                        }
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
            .sheet(item: $openPatientCard) { patient in
                NavigationStack {
                    PatientCardView(patient: patient)
                }
            }
        }
    }

    private func openExistingPatientCard(patientID: UUID) {
        openPatientCard = allPatients.first(where: { $0.id == patientID })
    }

    /// Находит существующего пациента по номеру телефона/имени или создаёт нового,
    /// чтобы у каждой записи была связанная карточка с картой осмотров.
    private func resolvePatient(name: String, phone: String) -> Patient {
        let trimmedPhone = phone.trimmingCharacters(in: .whitespaces)
        if !trimmedPhone.isEmpty, let existing = allPatients.first(where: { $0.phone == trimmedPhone }) {
            if existing.fullName != name { existing.fullName = name }
            return existing
        }
        if let existing = allPatients.first(where: { $0.fullName.caseInsensitiveCompare(name) == .orderedSame }) {
            if !trimmedPhone.isEmpty { existing.phone = trimmedPhone }
            return existing
        }
        let newPatient = Patient(number: Patient.nextNumber(), fullName: name, phone: trimmedPhone)
        context.insert(newPatient)
        return newPatient
    }

    private var selectedDoctor: Doctor? {
        doctors.first(where: { $0.id == selectedDoctorID })
    }

    private func save() {
        guard let doctor = selectedDoctor else { return }

        let trimmedName = patientName.trimmingCharacters(in: .whitespaces)

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
            if !isBlocked && !trimmedName.isEmpty {
                appt.patientID = resolvePatient(name: patientName, phone: patientPhone).id
            } else if isBlocked {
                appt.patientID = nil
            }

            try? context.save()
            if isBlocked || reminderMinutes < 0 {
                NotificationManager.shared.cancelReminder(for: appt)
            } else {
                NotificationManager.shared.scheduleReminder(for: appt, minutesBefore: reminderMinutes)
            }
        } else {
            let linkedPatientID: UUID? = (!isBlocked && !trimmedName.isEmpty)
                ? resolvePatient(name: patientName, phone: patientPhone).id
                : nil
            let newAppt = Appointment(
                doctorID: doctor.id,
                doctorName: doctor.name,
                date: date,
                patientID: linkedPatientID,
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
