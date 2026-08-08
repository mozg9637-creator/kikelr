import SwiftUI

struct AppointmentFormView: View {
    @Binding var appointment: Appointment
    @State private var enableStomatology: Bool = false

    var body: some View {
        Form {
            // Старый функционал
            Section(header: Text("Основные данные")) {
                TextField("Имя пациента", text: $appointment.patientName)
                TextField("Врач", text: $appointment.doctorName)
                DatePicker("Дата приема", selection: $appointment.date, displayedComponents: [.date, .hourAndMinute])
                
                Toggle("Стоматологический осмотр (расширенный)", isOn: $enableStomatology)
            }

            // Новый функционал (отображается при включении тумблера)
            if enableStomatology {
                Section(header: Text("Анамнез и жалобы")) {
                    TextField("Жалобы", text: Binding(
                        get: { appointment.stomatologyDetails?.complaints ?? "" },
                        set: { if appointment.stomatologyDetails == nil { appointment.stomatologyDetails = StomatologyDetails() }; appointment.stomatologyDetails?.complaints = $0 }
                    ), axis: .vertical)
                    
                    TextField("Аллергологический анамнез", text: Binding(
                        get: { appointment.stomatologyDetails?.allergicAnamnesis ?? "" },
                        set: { if appointment.stomatologyDetails == nil { appointment.stomatologyDetails = StomatologyDetails() }; appointment.stomatologyDetails?.allergicAnamnesis = $0 }
                    ), axis: .vertical)
                    
                    TextField("Анамнез заболевания", text: Binding(
                        get: { appointment.stomatologyDetails?.diseaseAnamnesis ?? "" },
                        set: { if appointment.stomatologyDetails == nil { appointment.stomatologyDetails = StomatologyDetails() }; appointment.stomatologyDetails?.diseaseAnamnesis = $0 }
                    ), axis: .vertical)
                    
                    TextField("Анамнез жизни", text: Binding(
                        get: { appointment.stomatologyDetails?.lifeAnamnesis ?? "" },
                        set: { if appointment.stomatologyDetails == nil { appointment.stomatologyDetails = StomatologyDetails() }; appointment.stomatologyDetails?.lifeAnamnesis = $0 }
                    ), axis: .vertical)
                    
                    TextField("Внешний осмотр", text: Binding(
                        get: { appointment.stomatologyDetails?.externalExamination ?? "" },
                        set: { if appointment.stomatologyDetails == nil { appointment.stomatologyDetails = StomatologyDetails() }; appointment.stomatologyDetails?.externalExamination = $0 }
                    ), axis: .vertical)
                    
                    TextField("Объективно", text: Binding(
                        get: { appointment.stomatologyDetails?.objectively ?? "" },
                        set: { if appointment.stomatologyDetails == nil { appointment.stomatologyDetails = StomatologyDetails() }; appointment.stomatologyDetails?.objectively = $0 }
                    ), axis: .vertical)
                    
                    TextField("Прикус", text: Binding(
                        get: { appointment.stomatologyDetails?.bite ?? "" },
                        set: { if appointment.stomatologyDetails == nil { appointment.stomatologyDetails = StomatologyDetails() }; appointment.stomatologyDetails?.bite = $0 }
                    ), axis: .vertical)
                }
                
                Section(header: Text("Диагностика и статус")) {
                    TextField("Результаты рентгеновских исследований", text: Binding(
                        get: { appointment.stomatologyDetails?.xRayResults ?? "" },
                        set: { if appointment.stomatologyDetails == nil { appointment.stomatologyDetails = StomatologyDetails() }; appointment.stomatologyDetails?.xRayResults = $0 }
                    ), axis: .vertical)
                    
                    Picker("Слизистые", selection: Binding(
                        get: { appointment.stomatologyDetails?.mucousMembrane ?? "Норма" },
                        set: { if appointment.stomatologyDetails == nil { appointment.stomatologyDetails = StomatologyDetails() }; appointment.stomatologyDetails?.mucousMembrane = $0 }
                    )) {
                        Text("Норма").tag("Норма")
                        Text("Гиперемия").tag("Гиперемия")
                        Text("Бледная").tag("Бледная")
                    }
                    
                    Toggle("Санация полости рта", isOn: Binding(
                        get: { appointment.stomatologyDetails?.isSanationCompleted ?? false },
                        set: { if appointment.stomatologyDetails == nil { appointment.stomatologyDetails = StomatologyDetails() }; appointment.stomatologyDetails?.isSanationCompleted = $0 }
                    ))
                    
                    Toggle("Требуется протезирование", isOn: Binding(
                        get: { appointment.stomatologyDetails?.requiresProsthetics ?? false },
                        set: { if appointment.stomatologyDetails == nil { appointment.stomatologyDetails = StomatologyDetails() }; appointment.stomatologyDetails?.requiresProsthetics = $0 }
                    ))
                    
                    TextField("Общий диагноз по МКБ-10", text: Binding(
                        get: { appointment.stomatologyDetails?.icd10Diagnosis ?? "" },
                        set: { if appointment.stomatologyDetails == nil { appointment.stomatologyDetails = StomatologyDetails() }; appointment.stomatologyDetails?.icd10Diagnosis = $0 }
                    ))
                }
                
                Section(header: Text("Лечение")) {
                    TextField("План лечения", text: Binding(
                        get: { appointment.stomatologyDetails?.treatmentPlan ?? "" },
                        set: { if appointment.stomatologyDetails == nil { appointment.stomatologyDetails = StomatologyDetails() }; appointment.stomatologyDetails?.treatmentPlan = $0 }
                    ), axis: .vertical)
                    
                    TextField("Анестезия", text: Binding(
                        get: { appointment.stomatologyDetails?.anesthesia ?? "" },
                        set: { if appointment.stomatologyDetails == nil { appointment.stomatologyDetails = StomatologyDetails() }; appointment.stomatologyDetails?.anesthesia = $0 }
                    ), axis: .vertical)
                    
                    TextField("Лечение", text: Binding(
                        get: { appointment.stomatologyDetails?.treatment ?? "" },
                        set: { if appointment.stomatologyDetails == nil { appointment.stomatologyDetails = StomatologyDetails() }; appointment.stomatologyDetails?.treatment = $0 }
                    ), axis: .vertical)
                    
                    TextField("Назначения", text: Binding(
                        get: { appointment.stomatologyDetails?.prescriptions ?? "" },
                        set: { if appointment.stomatologyDetails == nil { appointment.stomatologyDetails = StomatologyDetails() }; appointment.stomatologyDetails?.prescriptions = $0 }
                    ), axis: .vertical)
                }
                
                Section(header: Text("Листок нетрудоспособности")) {
                    Toggle("Оформить ЛН", isOn: Binding(
                        get: { appointment.stomatologyDetails?.isSickLeaveIssued ?? false },
                        set: { if appointment.stomatologyDetails == nil { appointment.stomatologyDetails = StomatologyDetails() }; appointment.stomatologyDetails?.isSickLeaveIssued = $0 }
                    ))
                    
                    if appointment.stomatologyDetails?.isSickLeaveIssued == true {
                        DatePicker("Выдан с", selection: Binding(
                            get: { appointment.stomatologyDetails?.sickLeaveStartDate ?? Date() },
                            set: { appointment.stomatologyDetails?.sickLeaveStartDate = $0 }
                        ), displayedComponents: .date)
                        
                        DatePicker("по", selection: Binding(
                            get: { appointment.stomatologyDetails?.sickLeaveEndDate ?? Date() },
                            set: { appointment.stomatologyDetails?.sickLeaveEndDate = $0 }
                        ), displayedComponents: .date)
                        
                        TextField("№ ЛН", text: Binding(
                            get: { appointment.stomatologyDetails?.sickLeaveNumber ?? "" },
                            set: { appointment.stomatologyDetails?.sickLeaveNumber = $0 }
                        ))
                    }
                }
                
                Section(header: Text("Итог")) {
                    TextField("Общие рекомендации", text: Binding(
                        get: { appointment.stomatologyDetails?.generalRecommendations ?? "" },
                        set: { if appointment.stomatologyDetails == nil { appointment.stomatologyDetails = StomatologyDetails() }; appointment.stomatologyDetails?.generalRecommendations = $0 }
                    ), axis: .vertical)
                }
            }
        }
        .navigationTitle("Карта приема")
        .onAppear {
            if appointment.stomatologyDetails != nil {
                enableStomatology = true
            }
        }
    }
}
