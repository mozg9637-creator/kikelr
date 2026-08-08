import Foundation

// Детали стоматологического осмотра (новые поля с фото)
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
    
    // Листок нетрудоспособности
    var isSickLeaveIssued: Bool = false
    var sickLeaveStartDate: Date = Date()
    var sickLeaveEndDate: Date = Date()
    var sickLeaveNumber: String = ""
}

// Основная модель встречи/осмотра (сохраняет старый функционал + новые данные)
struct Appointment: Identifiable, Codable {
    var id: UUID = UUID()
    var patientName: String
    var doctorName: String
    var doctorID: String = "" // Совместимость с PatientsSearchView
    var date: Date
    
    // Новые расширенные данные осмотра
    var stomatologyDetails: StomatologyDetails?
}
