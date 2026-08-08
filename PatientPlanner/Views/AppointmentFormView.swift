import SwiftUI

struct AppointmentFormView: View {
    @State var appointment: PatientAppointment

    var body: some View {
        Form {
            // MARK: - Шапка и основные параметры
            Section(header: Text("Параметры осмотра")) {
                DatePicker("Дата", selection: $appointment.inspectionDate, displayedComponents: [.date, .hourAndMinute])
                
                Picker("Тип формы", selection: $appointment.inspectionType) {
                    Text("Взрослая").tag("Взрослая")
                    Text("Детская").tag("Детская")
                }
                
                TextField("Врач", text: $appointment.doctorName)
                TextField("Медсестра", text: $appointment.nurseName)
            }
            
            // MARK: - Анамнез и осмотр
            Section(header: Text("Анамнез и статус")) {
                TextField("Жалобы", text: $appointment.complaints, axis: .vertical)
                TextField("Аллергологический анамнез", text: $appointment.allergicAnamnesis, axis: .vertical)
                TextField("Анамнез заболевания", text: $appointment.diseaseAnamnesis, axis: .vertical)
                TextField("Анамнез жизни", text: $appointment.lifeAnamnesis, axis: .vertical)
                TextField("Внешний осмотр", text: $appointment.externalExamination, axis: .vertical)
                TextField("Объективно", text: $appointment.objectively, axis: .vertical)
                TextField("Прикус", text: $appointment.bite, axis: .vertical)
                TextField("Результаты рентгеновских исследований", text: $appointment.xRayResults, axis: .vertical)
            }
            
            // MARK: - Диагностика
            Section(header: Text("Диагноз и слизистые")) {
                Picker("Слизистые", selection: $appointment.mucousMembrane) {
                    Text("Норма").tag("Норма")
                    Text("Гиперемия").tag("Гиперемия")
                    Text("Бледная").tag("Бледная")
                }
                
                Toggle("Санация полости рта", isOn: $appointment.isSanationCompleted)
                Toggle("Требуется протезирование", isOn: $appointment.requiresProsthetics)
                
                TextField("Общий диагноз по МКБ-10", text: $appointment.icd10Diagnosis)
            }
            
            // MARK: - Лечение
            Section(header: Text("План и лечение")) {
                TextField("План лечения", text: $appointment.treatmentPlan, axis: .vertical)
                TextField("Анестезия", text: $appointment.anesthesia, axis: .vertical)
                TextField("Лечение", text: $appointment.treatment, axis: .vertical)
                TextField("Назначения", text: $appointment.prescriptions, axis: .vertical)
            }
            
            // MARK: - Листок нетрудоспособности
            Section(header: Text("Листок нетрудоспособности")) {
                Toggle("Оформить ЛН", isOn: $appointment.isSickLeaveIssued)
                
                if appointment.isSickLeaveIssued {
                    DatePicker("Выдан с", selection: $appointment.sickLeaveStartDate, displayedComponents: .date)
                    DatePicker("по", selection: $appointment.sickLeaveEndDate, displayedComponents: .date)
                    TextField("№ ЛН", text: $appointment.sickLeaveNumber)
                }
            }
            
            // MARK: - Рекомендации
            Section(header: Text("Итог")) {
                TextField("Общие рекомендации", text: $appointment.generalRecommendations, axis: .vertical)
            }
        }
        .navigationTitle("Осмотр стоматолога")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}
