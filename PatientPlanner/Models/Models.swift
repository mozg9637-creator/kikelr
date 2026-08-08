import Foundation

// Дополнительные данные стоматолога
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
    
    // ЛН
    var isSickLeaveIssued: Bool = false
    var sickLeaveStartDate: Date = Date()
    var sickLeaveEndDate: Date = Date()
    var sickLeaveNumber: String = ""
}

// Дополняем существующую структуру Appointment (или аналогичную из вашего проекта)
struct Appointment: Identifiable, Codable {
    var id: UUID = UUID()
    // СТАРЫЙ ФУНКЦИОНАЛ (сохраняем)
    var patientName: String
    var doctorName: String
    var date: Date
    
    // НОВЫЙ ФУНКЦИОНАЛ (добавляем)
    var stomatologyDetails: StomatologyDetails? 
}
