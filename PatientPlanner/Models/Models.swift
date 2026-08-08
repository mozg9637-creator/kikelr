import Foundation
import SwiftData

// Детали стоматологического осмотра
struct StomatologyDetails: Codable {
    var complaints: String = ""
    var allergicAnamnesis: String = ""
    var diseaseAnamnesis: String = ""
    var lifeAnamnesis: String = ""
    var externalExamination: String = ""
    var objectively: String = ""
    var bite: String = ""
    var xRayResults: String = ""
    var mucousMembrane: String = "Норма"
    var isSanationCompleted: Bool = false
    var requiresProsthetics: Bool = false
    var icd10Diagnosis: String = ""
    var treatmentPlan: String = ""
    var anesthesia: String = ""
    var treatment: String = ""
    var prescriptions: String = ""
    var generalRecommendations: String = ""
    
    var isSickLeaveIssued: Bool = false
    var sickLeaveStartDate: Date = Date()
    var sickLeaveEndDate: Date = Date()
    var sickLeaveNumber: String = ""
}

@Model
final class Doctor {
    var id: UUID = UUID()
    var name: String
    var room: String
    var colorHex: String
    var sortOrder: Int
    
    init(name: String, room: String, colorHex: String, sortOrder: Int) {
        self.id = UUID()
        self.name = name
        self.room = room
        self.colorHex = colorHex
        self.sortOrder = sortOrder
    }
}

@Model
final class Appointment {
    var id: UUID = UUID()
    var patientName: String
    var doctorName: String
    var doctorID: String = ""
    var date: Date
    
    // Старый функционал (блокировка и напоминания)
    var isBlocked: Bool = false
    var reminderMinutesBefore: Int = 15
    
    // Новые данные стоматологического осмотра
    var stomatologyDetails: StomatologyDetails?
    
    init(patientName: String, doctorName: String, doctorID: String, date: Date, isBlocked: Bool = false, reminderMinutesBefore: Int = 15, stomatologyDetails: StomatologyDetails? = nil) {
        self.id = UUID()
        self.patientName = patientName
        self.doctorName = doctorName
        self.doctorID = doctorID
        self.date = date
        self.isBlocked = isBlocked
        self.reminderMinutesBefore = reminderMinutesBefore
        self.stomatologyDetails = stomatologyDetails
    }
}
