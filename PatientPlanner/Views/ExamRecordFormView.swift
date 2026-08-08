import SwiftUI
import SwiftData

/// Форма осмотра — повторяет структуру карты, показанной на образце:
/// Жалобы, анамнезы, объективные данные, диагноз, лечение, ЛН, рекомендации.
struct ExamRecordFormView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let patientID: UUID
    let record: ExamRecord?
    @Query(sort: \Doctor.sortOrder) private var doctors: [Doctor]
    @Query(sort: \ExamRecord.date, order: .reverse) private var allExamRecords: [ExamRecord]

    @State private var date: Date
    @State private var examType: String
    @State private var doctorName: String
    @State private var nurseName: String

    @State private var complaints: String
    @State private var allergyHistory: String
    @State private var diseaseHistory: String
    @State private var lifeHistory: String
    @State private var externalExam: String
    @State private var objectively: String
    @State private var bite: String
    @State private var xrayResults: String
    @State private var mucous: String
    @State private var sanitationDone: Bool
    @State private var prostheticsNeeded: Bool
    @State private var diagnosisICD10: String

    @State private var treatmentPlan: String
    @State private var anesthesia: String
    @State private var treatment: String
    @State private var prescriptions: String

    @State private var showSickLeave: Bool
    @State private var sickLeaveNumber: String
    @State private var sickLeaveIssuedFrom: Date
    @State private var sickLeaveIssuedTo: Date
    @State private var sickLeaveExtended1From: Date
    @State private var sickLeaveExtended1To: Date
    @State private var sickLeaveExtended2From: Date
    @State private var sickLeaveExtended2To: Date
    @State private var sickLeaveClosedFrom: Date

    @State private var generalRecommendations: String
    @State private var specialNotes: String
    @State private var toothFormula: [Int: String]

    @State private var showDeleteConfirm = false

    static let examTypes = ["Взрослая", "Детская"]
    static let mucousOptions = ["Без особенностей", "Бледно-розовые", "Гиперемия", "Отёчность", "Бледные"]

    init(patientID: UUID, record: ExamRecord?) {
        self.patientID = patientID
        self.record = record

        _date = State(initialValue: record?.date ?? Date())
        _examType = State(initialValue: record?.examType ?? "Взрослая")
        _doctorName = State(initialValue: record?.doctorName ?? "")
        _nurseName = State(initialValue: record?.nurseName ?? "")

        _complaints = State(initialValue: record?.complaints ?? "")
        _allergyHistory = State(initialValue: record?.allergyHistory ?? "")
        _diseaseHistory = State(initialValue: record?.diseaseHistory ?? "")
        _lifeHistory = State(initialValue: record?.lifeHistory ?? "")
        _externalExam = State(initialValue: record?.externalExam ?? "")
        _objectively = State(initialValue: record?.objectively ?? "")
        _bite = State(initialValue: record?.bite ?? "")
        _xrayResults = State(initialValue: record?.xrayResults ?? "")
        _mucous = State(initialValue: record?.mucous ?? "")
        _sanitationDone = State(initialValue: record?.sanitationDone ?? false)
        _prostheticsNeeded = State(initialValue: record?.prostheticsNeeded ?? false)
        _diagnosisICD10 = State(initialValue: record?.diagnosisICD10 ?? "")

        _treatmentPlan = State(initialValue: record?.treatmentPlan ?? "")
        _anesthesia = State(initialValue: record?.anesthesia ?? "")
        _treatment = State(initialValue: record?.treatment ?? "")
        _prescriptions = State(initialValue: record?.prescriptions ?? "")

        let hasSickLeave = record?.sickLeaveIssuedFrom != nil || !(record?.sickLeaveNumber.isEmpty ?? true)
        _showSickLeave = State(initialValue: hasSickLeave)
        _sickLeaveNumber = State(initialValue: record?.sickLeaveNumber ?? "")
        _sickLeaveIssuedFrom = State(initialValue: record?.sickLeaveIssuedFrom ?? Date())
        _sickLeaveIssuedTo = State(initialValue: record?.sickLeaveIssuedTo ?? Date())
        _sickLeaveExtended1From = State(initialValue: record?.sickLeaveExtended1From ?? Date())
        _sickLeaveExtended1To = State(initialValue: record?.sickLeaveExtended1To ?? Date())
        _sickLeaveExtended2From = State(initialValue: record?.sickLeaveExtended2From ?? Date())
        _sickLeaveExtended2To = State(initialValue: record?.sickLeaveExtended2To ?? Date())
        _sickLeaveClosedFrom = State(initialValue: record?.sickLeaveClosedFrom ?? Date())

        _generalRecommendations = State(initialValue: record?.generalRecommendations ?? "")
        _specialNotes = State(initialValue: record?.specialNotes ?? "")
        if let existingFormula = record?.toothFormula {
            _toothFormula = State(initialValue: existingFormula)
        } else {
            // Новый осмотр — по умолчанию все зубы отмечены как "Норма", как в образце карты.
            let defaults = Dictionary(uniqueKeysWithValues: ToothChart.allTeeth.map { ($0, ToothStatusCode.norm.rawValue) })
            _toothFormula = State(initialValue: defaults)
        }
    }

    /// Предыдущие осмотры этого же пациента (кроме текущего), для копирования зубной формулы.
    private var previousRecords: [ExamRecord] {
        allExamRecords.filter { $0.patientID == patientID && $0.id != record?.id }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Осмотр") {
                    DatePicker("Дата", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    Picker("Тип формы осмотра", selection: $examType) {
                        ForEach(Self.examTypes, id: \.self) { Text($0).tag($0) }
                    }
                    if doctors.isEmpty {
                        TextField("Врач", text: $doctorName)
                    } else {
                        Picker("Врач", selection: $doctorName) {
                            Text("—").tag("")
                            ForEach(doctors) { doctor in
                                Text(doctor.name).tag(doctor.name)
                            }
                        }
                    }
                    TextField("Медсестра", text: $nurseName)
                }

                Section("Жалобы и анамнез") {
                    labeledEditor("Жалобы", text: $complaints)
                    labeledEditor("Аллергологический анамнез", text: $allergyHistory)
                    labeledEditor("Анамнез заболевания", text: $diseaseHistory)
                    labeledEditor("Анамнез жизни", text: $lifeHistory)
                }

                Section("Объективные данные") {
                    labeledEditor("Внешний осмотр", text: $externalExam)
                    labeledEditor("Объективно", text: $objectively)
                    labeledEditor("Прикус", text: $bite)
                    labeledEditor("Результаты рентгеновских исследований", text: $xrayResults)
                    Picker("Слизистые", selection: $mucous) {
                        Text("—").tag("")
                        ForEach(Self.mucousOptions, id: \.self) { Text($0).tag($0) }
                    }
                    Toggle("Санация полости рта", isOn: $sanitationDone)
                    Toggle("Требуется протезирование", isOn: $prostheticsNeeded)
                    labeledEditor("Общий диагноз по МКБ10", text: $diagnosisICD10)
                }

                Section("Лечение") {
                    labeledEditor("План лечения", text: $treatmentPlan)
                    labeledEditor("Анестезия", text: $anesthesia)
                    labeledEditor("Лечение", text: $treatment)
                    labeledEditor("Назначения", text: $prescriptions)
                }

                Section("Листок нетрудоспособности") {
                    Toggle("Оформить ЛН", isOn: $showSickLeave.animation())
                    if showSickLeave {
                        TextField("№ ЛН", text: $sickLeaveNumber)
                        DatePicker("Выдан с", selection: $sickLeaveIssuedFrom, displayedComponents: .date)
                        DatePicker("Выдан по", selection: $sickLeaveIssuedTo, displayedComponents: .date)
                        DatePicker("Продлен с", selection: $sickLeaveExtended1From, displayedComponents: .date)
                        DatePicker("Продлен по", selection: $sickLeaveExtended1To, displayedComponents: .date)
                        DatePicker("Продлен с", selection: $sickLeaveExtended2From, displayedComponents: .date)
                        DatePicker("Продлен по", selection: $sickLeaveExtended2To, displayedComponents: .date)
                        DatePicker("Закрыт с", selection: $sickLeaveClosedFrom, displayedComponents: .date)
                    }
                }

                Section("Общие рекомендации") {
                    TextField("Рекомендации", text: $generalRecommendations, axis: .vertical)
                        .lineLimit(3...8)
                }

                Section("Особые отметки") {
                    TextField("Особые отметки", text: $specialNotes, axis: .vertical)
                        .lineLimit(2...5)
                }

                Section {
                    if !previousRecords.isEmpty {
                        Button {
                            copyFormulaFromPrevious()
                        } label: {
                            Label("Копировать формулу из предыдущего осмотра", systemImage: "doc.on.doc")
                        }
                        .font(.caption)
                    }
                    ToothChartView(toothFormula: $toothFormula)
                        .padding(.vertical, 6)
                    legendView
                } header: {
                    Text("Зубная формула")
                }

                if record != nil {
                    Section {
                        Button("Удалить осмотр", role: .destructive) {
                            showDeleteConfirm = true
                        }
                    }
                }
            }
            .navigationTitle(record == nil ? "Осмотр стоматолога" : "Редактирование осмотра")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") { save() }
                }
            }
            .confirmationDialog("Удалить эту запись осмотра?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                Button("Удалить", role: .destructive) { delete() }
                Button("Отмена", role: .cancel) {}
            }
        }
    }

    @ViewBuilder
    private func labeledEditor(_ label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField(label, text: text, axis: .vertical)
                .lineLimit(1...5)
                .labelsHidden()
        }
    }

    private var legendView: some View {
        Text(ToothStatusCode.allCases.map { "\($0.rawValue) — \($0.fullDescription)" }.joined(separator: "; "))
            .font(.caption2)
            .foregroundStyle(.secondary)
    }

    private func copyFormulaFromPrevious() {
        guard let latest = previousRecords.first else { return }
        toothFormula = latest.toothFormula
    }

    private func save() {
        let sickFrom = showSickLeave ? sickLeaveIssuedFrom : nil
        let sickTo = showSickLeave ? sickLeaveIssuedTo : nil
        let sick1From = showSickLeave ? sickLeaveExtended1From : nil
        let sick1To = showSickLeave ? sickLeaveExtended1To : nil
        let sick2From = showSickLeave ? sickLeaveExtended2From : nil
        let sick2To = showSickLeave ? sickLeaveExtended2To : nil
        let sickClosed = showSickLeave ? sickLeaveClosedFrom : nil
        let sickNumber = showSickLeave ? sickLeaveNumber : ""

        if let record {
            record.date = date
            record.examType = examType
            record.doctorName = doctorName
            record.nurseName = nurseName
            record.complaints = complaints
            record.allergyHistory = allergyHistory
            record.diseaseHistory = diseaseHistory
            record.lifeHistory = lifeHistory
            record.externalExam = externalExam
            record.objectively = objectively
            record.bite = bite
            record.xrayResults = xrayResults
            record.mucous = mucous
            record.sanitationDone = sanitationDone
            record.prostheticsNeeded = prostheticsNeeded
            record.diagnosisICD10 = diagnosisICD10
            record.treatmentPlan = treatmentPlan
            record.anesthesia = anesthesia
            record.treatment = treatment
            record.prescriptions = prescriptions
            record.sickLeaveNumber = sickNumber
            record.sickLeaveIssuedFrom = sickFrom
            record.sickLeaveIssuedTo = sickTo
            record.sickLeaveExtended1From = sick1From
            record.sickLeaveExtended1To = sick1To
            record.sickLeaveExtended2From = sick2From
            record.sickLeaveExtended2To = sick2To
            record.sickLeaveClosedFrom = sickClosed
            record.generalRecommendations = generalRecommendations
            record.specialNotes = specialNotes
            record.toothFormula = toothFormula
        } else {
            let newRecord = ExamRecord(
                patientID: patientID,
                date: date,
                examType: examType,
                doctorName: doctorName,
                nurseName: nurseName,
                complaints: complaints,
                allergyHistory: allergyHistory,
                diseaseHistory: diseaseHistory,
                lifeHistory: lifeHistory,
                externalExam: externalExam,
                objectively: objectively,
                bite: bite,
                xrayResults: xrayResults,
                mucous: mucous,
                sanitationDone: sanitationDone,
                prostheticsNeeded: prostheticsNeeded,
                diagnosisICD10: diagnosisICD10,
                treatmentPlan: treatmentPlan,
                anesthesia: anesthesia,
                treatment: treatment,
                prescriptions: prescriptions,
                sickLeaveNumber: sickNumber,
                sickLeaveIssuedFrom: sickFrom,
                sickLeaveIssuedTo: sickTo,
                sickLeaveExtended1From: sick1From,
                sickLeaveExtended1To: sick1To,
                sickLeaveExtended2From: sick2From,
                sickLeaveExtended2To: sick2To,
                sickLeaveClosedFrom: sickClosed,
                generalRecommendations: generalRecommendations,
                specialNotes: specialNotes
            )
            newRecord.toothFormula = toothFormula
            context.insert(newRecord)
        }
        try? context.save()
        dismiss()
    }

    private func delete() {
        if let record {
            context.delete(record)
            try? context.save()
        }
        dismiss()
    }
}
