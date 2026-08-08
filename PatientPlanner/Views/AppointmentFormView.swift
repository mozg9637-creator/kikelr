import SwiftUI

struct AppointmentFormView: View {
<<<<<<< HEAD
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
=======
    @Binding var appointment: Appointment?   // Опционально для поддержки создания/редактирования
    @State private var tempAppointment: Appointment = Appointment(patientName: "", doctorName: "", doctorID: "", date: Date())
    @State private var enableStomatology: Bool = false
    
    var isNew: Bool
    var onSave: (Appointment) -> Void
    
    // Конструктор для редактирования существующей записи
    init(appointment: Binding<Appointment?>, onSave: @escaping (Appointment) -> Void) {
        self._appointment = appointment
        self.isNew = false
        self.onSave = onSave
    }
    
    // Конструктор для создания новой записи (совместимость со старым вызовом в ScheduleView)
    init(doctorID: String, doctorName: String, date: Date, onSave: @escaping (Appointment) -> Void) {
        self._appointment = .constant(nil)
        self.isNew = true
        self.onSave = onSave
        _tempAppointment = State(initialValue: Appointment(patientName: "", doctorName: doctorName, doctorID: doctorID, date: date))
>>>>>>> fb62e05b1b001a8119bde77d6bcd9541aa4c6a2c
    }

    var body: some View {
        Form {
            Section(header: Text("Основные данные")) {
                TextField("Имя пациента", text: bindingFor(\.patientName))
                TextField("Врач", text: bindingFor(\.doctorName))
                DatePicker("Дата приема", selection: bindingFor(\.date), displayedComponents: [.date, .hourAndMinute])
                
                Toggle("Стоматологический осмотр (расширенный)", isOn: $enableStomatology)
            }

            if enableStomatology {
                Section(header: Text("Анамнез и жалобы")) {
                    TextField("Жалобы", text: stomatologyBinding(\.complaints), axis: .vertical)
                    TextField("Аллергологический анамнез", text: stomatologyBinding(\.allergicAnamnesis), axis: .vertical)
                    TextField("Анамнез заболевания", text: stomatologyBinding(\.diseaseAnamnesis), axis: .vertical)
                    TextField("Анамнез жизни", text: stomatologyBinding(\.lifeAnamnesis), axis: .vertical)
                    TextField("Внешний осмотр", text: stomatologyBinding(\.externalExamination), axis: .vertical)
                    TextField("Объективно", text: stomatologyBinding(\.objectively), axis: .vertical)
                    TextField("Прикус", text: stomatologyBinding(\.bite), axis: .vertical)
                }
                
                Section(header: Text("Диагностика и статус")) {
                    TextField("Результаты рентгеновских исследований", text: stomatologyBinding(\.xRayResults), axis: .vertical)
                    
                    Picker("Слизистые", selection: stomatologyBinding(\.mucousMembrane)) {
                        Text("Норма").tag("Норма")
                        Text("Гиперемия").tag("Гиперемия")
                        Text("Бледная").tag("Бледная")
                    }
                    
                    Toggle("Санация полости рта", isOn: stomatologyBoolBinding(\.isSanationCompleted))
                    Toggle("Требуется протезирование", isOn: stomatologyBoolBinding(\.requiresProsthetics))
                    
                    TextField("Общий диагноз по МКБ-10", text: stomatologyBinding(\.icd10Diagnosis))
                }
<<<<<<< HEAD

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
=======
                
                Section(header: Text("Лечение")) {
                    TextField("План лечения", text: stomatologyBinding(\.treatmentPlan), axis: .vertical)
                    TextField("Анестезия", text: stomatologyBinding(\.anesthesia), axis: .vertical)
                    TextField("Лечение", text: stomatologyBinding(\.treatment), axis: .vertical)
                    TextField("Назначения", text: stomatologyBinding(\.prescriptions), axis: .vertical)
                }
                
                Section(header: Text("Листок нетрудоспособности")) {
                    Toggle("Оформить ЛН", isOn: stomatologyBoolBinding(\.isSickLeaveIssued))
                    
                    if let details = currentStomatologyDetails(), details.isSickLeaveIssued {
                        DatePicker("Выдан с", selection: stomatologyDateBinding(\.sickLeaveStartDate), displayedComponents: .date)
                        DatePicker("по", selection: stomatologyDateBinding(\.sickLeaveEndDate), displayedComponents: .date)
                        TextField("№ ЛН", text: stomatologyBinding(\.sickLeaveNumber))
>>>>>>> fb62e05b1b001a8119bde77d6bcd9541aa4c6a2c
                    }
                }
                
                Section(header: Text("Итог")) {
                    TextField("Общие рекомендации", text: stomatologyBinding(\.generalRecommendations), axis: .vertical)
                }
            }
            
            Section {
                Button("Сохранить") {
                    onSave(isNew ? tempAppointment : (appointment ?? tempAppointment))
                }
            }
        }
        .navigationTitle("Карта приема")
        .onAppear {
            if let appt = appointment, appt.stomatologyDetails != nil {
                enableStomatology = true
            }
            .sheet(item: $openPatientCard) { patient in
                NavigationStack {
                    PatientCardView(patient: patient)
                }
            }
        }
    }
<<<<<<< HEAD

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
=======
    
    // Вспомогательные хелперы для безопасного биндинга
    private func bindingFor<T>(_ keyPath: ReferenceWritableKeyPath<Appointment, T>) -> Binding<T> {
        Binding(
            get: { isNew ? tempAppointment[keyPath: keyPath] : (appointment?[keyPath: keyPath] ?? tempAppointment[keyPath: keyPath]) },
            set: { val in
                if isNew {
                    tempAppointment[keyPath: keyPath] = val
                } else {
                    appointment?[keyPath: keyPath] = val
                }
>>>>>>> fb62e05b1b001a8119bde77d6bcd9541aa4c6a2c
            }
        )
    }
    
    private func currentStomatologyDetails() -> StomatologyDetails? {
        return isNew ? tempAppointment.stomatologyDetails : appointment?.stomatologyDetails
    }
    
    private func ensureStomatology() {
        if isNew {
            if tempAppointment.stomatologyDetails == nil { tempAppointment.stomatologyDetails = StomatologyDetails() }
        } else {
<<<<<<< HEAD
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
=======
            if appointment?.stomatologyDetails == nil { appointment?.stomatologyDetails = StomatologyDetails() }
>>>>>>> fb62e05b1b001a8119bde77d6bcd9541aa4c6a2c
        }
    }
    
    private func stomatologyBinding(_ keyPath: WritableKeyPath<StomatologyDetails, String>) -> Binding<String> {
        Binding(
            get: {
                let details = isNew ? tempAppointment.stomatologyDetails : appointment?.stomatologyDetails
                return details?[keyPath: keyPath] ?? ""
            },
            set: { val in
                ensureStomatology()
                if isNew {
                    tempAppointment.stomatologyDetails?[keyPath: keyPath] = val
                } else {
                    appointment?.stomatologyDetails?[keyPath: keyPath] = val
                }
            }
        )
    }
    
    private func stomatologyBoolBinding(_ keyPath: WritableKeyPath<StomatologyDetails, Bool>) -> Binding<Bool> {
        Binding(
            get: {
                let details = isNew ? tempAppointment.stomatologyDetails : appointment?.stomatologyDetails
                return details?[keyPath: keyPath] ?? false
            },
            set: { val in
                ensureStomatology()
                if isNew {
                    tempAppointment.stomatologyDetails?[keyPath: keyPath] = val
                } else {
                    appointment?.stomatologyDetails?[keyPath: keyPath] = val
                }
            }
        )
    }
    
    private func stomatologyDateBinding(_ keyPath: WritableKeyPath<StomatologyDetails, Date>) -> Binding<Date> {
        Binding(
            get: {
                let details = isNew ? tempAppointment.stomatologyDetails : appointment?.stomatologyDetails
                return details?[keyPath: keyPath] ?? Date()
            },
            set: { val in
                ensureStomatology()
                if isNew {
                    tempAppointment.stomatologyDetails?[keyPath: keyPath] = val
                } else {
                    appointment?.stomatologyDetails?[keyPath: keyPath] = val
                }
            }
        )
    }
}
