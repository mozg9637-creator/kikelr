import Foundation
import SwiftData

// MARK: - Врач / кабинет

@Model
final class Doctor {
    var id: UUID
    var name: String
    var room: String
    var colorHex: String
    var sortOrder: Int

    init(name: String, room: String = "", colorHex: String = "8A6FD8", sortOrder: Int = 0) {
        self.id = UUID()
        self.name = name
        self.room = room
        self.colorHex = colorHex
        self.sortOrder = sortOrder
    }
}

// MARK: - Запись на приём

@Model
final class Appointment {
    var id: UUID
    var doctorID: UUID
    var doctorName: String       // дублируем имя врача на момент записи, чтобы история не терялась при удалении врача
    var date: Date                // конкретная дата и время приёма
    var patientName: String
    var patientPhone: String
    var notes: String
    var isBlocked: Bool           // слот заблокирован (недоступен для записи)
    var isPreliminary: Bool       // "Предв. запись"
    var createdAt: Date
    var reminderMinutesBefore: Int   // -1 = без напоминания, иначе минут до приёма

    init(doctorID: UUID,
         doctorName: String,
         date: Date,
         patientName: String = "",
         patientPhone: String = "",
         notes: String = "",
         isBlocked: Bool = false,
         isPreliminary: Bool = true,
         reminderMinutesBefore: Int = 30) {
        self.id = UUID()
        self.doctorID = doctorID
        self.doctorName = doctorName
        self.date = date
        self.patientName = patientName
        self.patientPhone = patientPhone
        self.notes = notes
        self.isBlocked = isBlocked
        self.isPreliminary = isPreliminary
        self.createdAt = Date()
        self.reminderMinutesBefore = reminderMinutesBefore
    }

    var isFree: Bool {
        !isBlocked && patientName.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
