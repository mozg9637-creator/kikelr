import SwiftUI
import SwiftData

/// Карточка пациента: шапка с ФИО/номером/д.р., редактирование данных,
/// список осмотров (карта) и история записей на приём.
struct PatientCardView: View {
    @Environment(\.modelContext) private var context
    @Bindable var patient: Patient

    @Query private var allExamRecords: [ExamRecord]
    @Query(sort: \Appointment.date, order: .reverse) private var allAppointments: [Appointment]

    @State private var editingRecord: ExamRecord?
    @State private var showNewRecordSheet = false
    @State private var showEditPatient = false
    @State private var showDeleteConfirm = false
    @Environment(\.dismiss) private var dismiss

    private var records: [ExamRecord] {
        allExamRecords
            .filter { $0.patientID == patient.id }
            .sorted { $0.date > $1.date }
    }

    private var appointments: [Appointment] {
        allAppointments.filter { $0.patientID == patient.id }
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text(patient.fullName)
                        .font(.title3.bold())
                    HStack(spacing: 12) {
                        Text("№\(patient.number)")
                        if let birthDate = patient.birthDate {
                            Text("д.р. \(formattedDate(birthDate))")
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    if !patient.phone.isEmpty {
                        Label(patient.phone, systemImage: "phone")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    if !patient.generalNotes.isEmpty {
                        Text(patient.generalNotes)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.top, 2)
                    }
                }
                .padding(.vertical, 4)

                Button {
                    showEditPatient = true
                } label: {
                    Label("Редактировать данные пациента", systemImage: "pencil")
                }
            }

            Section("Карта — осмотры") {
                if records.isEmpty {
                    Text("Осмотров пока нет")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(records) { record in
                        Button {
                            editingRecord = record
                        } label: {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Осмотр стоматолога от \(formattedDateTime(record.date))")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.primary)
                                if !record.doctorName.isEmpty {
                                    Text("Врач: \(record.doctorName)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                if !record.diagnosisICD10.isEmpty {
                                    Text("Диагноз: \(record.diagnosisICD10)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                }

                Button {
                    showNewRecordSheet = true
                } label: {
                    Label("Новый осмотр", systemImage: "plus.circle")
                }
            }

            if !appointments.isEmpty {
                Section("История записей") {
                    ForEach(appointments) { appt in
                        VStack(alignment: .leading, spacing: 3) {
                            Text("\(appt.doctorName) · \(formattedDateTime(appt.date))")
                                .font(.subheadline)
                            if !appt.notes.isEmpty {
                                Text(appt.notes)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }

            Section {
                Button("Удалить пациента", role: .destructive) {
                    showDeleteConfirm = true
                }
            }
        }
        .navigationTitle("Карточка пациента")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showNewRecordSheet) {
            ExamRecordFormView(patientID: patient.id, record: nil)
        }
        .sheet(item: $editingRecord) { record in
            ExamRecordFormView(patientID: patient.id, record: record)
        }
        .sheet(isPresented: $showEditPatient) {
            PatientEditView(patient: patient)
        }
        .confirmationDialog("Удалить пациента и все его осмотры?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Удалить", role: .destructive) { deletePatient() }
            Button("Отмена", role: .cancel) {}
        }
    }

    private func deletePatient() {
        for record in records {
            context.delete(record)
        }
        context.delete(patient)
        try? context.save()
        dismiss()
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }

    private func formattedDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        return formatter.string(from: date)
    }
}

/// Редактирование основных данных пациента: ФИО, дата рождения, телефон, заметки.
struct PatientEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Bindable var patient: Patient

    @State private var hasBirthDate: Bool
    @State private var birthDate: Date

    init(patient: Patient) {
        self.patient = patient
        _hasBirthDate = State(initialValue: patient.birthDate != nil)
        _birthDate = State(initialValue: patient.birthDate ?? Date())
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Данные пациента") {
                    TextField("ФИО", text: $patient.fullName)
                    TextField("Телефон", text: $patient.phone)
                        .keyboardType(.phonePad)
                    Toggle("Указать дату рождения", isOn: $hasBirthDate)
                    if hasBirthDate {
                        DatePicker("Дата рождения", selection: $birthDate, displayedComponents: .date)
                    }
                }
                Section("Заметки") {
                    TextField("Общие заметки (аллергии, хронические заболевания и т.д.)", text: $patient.generalNotes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Данные пациента")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") {
                        patient.birthDate = hasBirthDate ? birthDate : nil
                        try? context.save()
                        dismiss()
                    }
                }
            }
        }
    }
}
