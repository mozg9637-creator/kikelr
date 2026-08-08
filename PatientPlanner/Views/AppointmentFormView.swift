import SwiftUI

struct AppointmentFormView: View {
    @Binding var appointment: Appointment
    @State private var isStomatologyView: Bool = false

    var body: some View {
        Form {
            // --- СТАРЫЙ ФУНКЦИОНАЛ ---
            Section(header: Text("Основные данные")) {
                TextField("Имя пациента", text: $appointment.patientName)
                TextField("Врач", text: $appointment.doctorName)
                DatePicker("Дата приема", selection: $appointment.date)
                Toggle("Это стоматологический осмотр", isOn: $isStomatologyView)
            }

            // --- НОВЫЙ ФУНКЦИОНАЛ (отображается только при выборе) ---
            if isStomatologyView {
                Section(header: Text("Осмотр стоматолога")) {
                    TextField("Жалобы", text: Binding(
                        get: { appointment.stomatologyDetails?.complaints ?? "" },
                        set: { appointment.stomatologyDetails?.complaints = $0 }
                    ))
                    // ... добавьте остальные поля из списка ниже по аналогии
                    TextField("Общий диагноз по МКБ-10", text: Binding(
                        get: { appointment.stomatologyDetails?.icd10Diagnosis ?? "" },
                        set: { appointment.stomatologyDetails?.icd10Diagnosis = $0 }
                    ))
                }
                
                Section(header: Text("Листок нетрудоспособности")) {
                    Toggle("Оформить ЛН", isOn: Binding(
                        get: { appointment.stomatologyDetails?.isSickLeaveIssued ?? false },
                        set: { appointment.stomatologyDetails?.isSickLeaveIssued = $0 }
                    ))
                }
            }
        }
    }
}
