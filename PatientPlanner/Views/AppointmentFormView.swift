import SwiftUI

struct AppointmentFormView: View {
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
        }
    }
    
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
            if appointment?.stomatologyDetails == nil { appointment?.stomatologyDetails = StomatologyDetails() }
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
