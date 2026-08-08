import SwiftUI
import SwiftData

struct DoctorsView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Doctor.sortOrder) private var doctors: [Doctor]

    @State private var showingAdd = false
    @State private var editingDoctor: Doctor?

    var body: some View {
        NavigationStack {
            List {
                ForEach(doctors) { doctor in
                    Button {
                        editingDoctor = doctor
                    } label: {
                        HStack {
                            Circle()
                                .fill(Color(hex: doctor.colorHex))
                                .frame(width: 14, height: 14)
                            VStack(alignment: .leading) {
                                Text(doctor.name).foregroundStyle(.primary)
                                Text(doctor.room.isEmpty ? "кабинет не задан" : doctor.room)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteDoctors)
                .onMove(perform: moveDoctors)
            }
            .navigationTitle("Врачи")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingAdd) {
                DoctorEditView(doctor: nil, nextOrder: doctors.count)
            }
            .sheet(item: $editingDoctor) { doc in
                DoctorEditView(doctor: doc, nextOrder: doc.sortOrder)
            }
        }
    }

    private func deleteDoctors(at offsets: IndexSet) {
        for index in offsets {
            context.delete(doctors[index])
        }
        try? context.save()
    }

    private func moveDoctors(from source: IndexSet, to destination: Int) {
        var reordered = doctors
        reordered.move(fromOffsets: source, toOffset: destination)
        for (index, doctor) in reordered.enumerated() {
            doctor.sortOrder = index
        }
        try? context.save()
    }
}

struct DoctorEditView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let doctor: Doctor?
    let nextOrder: Int

    @State private var name: String
    @State private var room: String
    @State private var colorHex: String

    init(doctor: Doctor?, nextOrder: Int) {
        self.doctor = doctor
        self.nextOrder = nextOrder
        _name = State(initialValue: doctor?.name ?? "")
        _room = State(initialValue: doctor?.room ?? "")
        _colorHex = State(initialValue: doctor?.colorHex ?? Palette.color(for: nextOrder))
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Имя врача", text: $name)
                TextField("Кабинет", text: $room)

                Picker("Цвет", selection: $colorHex) {
                    ForEach(Palette.hexes, id: \.self) { hex in
                        HStack {
                            Circle().fill(Color(hex: hex)).frame(width: 16, height: 16)
                            Text("#\(hex)")
                        }
                        .tag(hex)
                    }
                }
            }
            .navigationTitle(doctor == nil ? "Новый врач" : "Редактирование")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        if let doctor = doctor {
            doctor.name = name
            doctor.room = room
            doctor.colorHex = colorHex
        } else {
            let newDoctor = Doctor(name: name, room: room, colorHex: colorHex, sortOrder: nextOrder)
            context.insert(newDoctor)
        }
        try? context.save()
        dismiss()
    }
}
