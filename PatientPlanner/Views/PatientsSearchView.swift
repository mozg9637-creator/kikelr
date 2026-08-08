import SwiftUI
import SwiftData

struct PatientsSearchView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Patient.fullName) private var allPatients: [Patient]
    @State private var searchText = ""
    @State private var showNewPatient = false

    private var filtered: [Patient] {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return allPatients }
        return allPatients.filter {
            $0.fullName.localizedCaseInsensitiveContains(searchText) ||
            $0.phone.contains(searchText) ||
            String($0.number).contains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if filtered.isEmpty {
                    ContentUnavailableView("Пациенты не найдены", systemImage: "person.crop.circle.badge.questionmark")
                } else {
                    ForEach(filtered) { patient in
                        NavigationLink {
                            PatientCardView(patient: patient)
                        } label: {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(patient.fullName)
                                    .font(.headline)
                                HStack(spacing: 10) {
                                    Text("№\(patient.number)")
                                    if let birthDate = patient.birthDate {
                                        Text("д.р. \(formatted(birthDate))")
                                    }
                                    if !patient.phone.isEmpty {
                                        Text(patient.phone)
                                    }
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Пациенты")
            .searchable(text: $searchText, prompt: "Имя, телефон или номер карты")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showNewPatient = true
                    } label: {
                        Image(systemName: "person.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $showNewPatient) {
                NewPatientView()
            }
        }
    }

    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
}

/// Создание новой карточки пациента вручную (не из записи на приём).
struct NewPatientView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var fullName = ""
    @State private var phone = ""
    @State private var hasBirthDate = false
    @State private var birthDate = Date()

    var body: some View {
        NavigationStack {
            Form {
                Section("Данные пациента") {
                    TextField("ФИО", text: $fullName)
                    TextField("Телефон", text: $phone)
                        .keyboardType(.phonePad)
                    Toggle("Указать дату рождения", isOn: $hasBirthDate)
                    if hasBirthDate {
                        DatePicker("Дата рождения", selection: $birthDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("Новый пациент")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Создать") { save() }
                        .disabled(fullName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let patient = Patient(
            number: Patient.nextNumber(),
            fullName: fullName,
            birthDate: hasBirthDate ? birthDate : nil,
            phone: phone
        )
        context.insert(patient)
        try? context.save()
        dismiss()
    }
}
