import Foundation

// Модель данных пациента и осмотра
struct PatientAppointment: Identifiable, Codable {
    var id: UUID = UUID()
    
    // Шапка / Основное
    var patientName: String
    var patientNumber: String
    var birthDate: String
    var inspectionDate: Date = Date()
    var inspectionType: String = "Взрослая"
    var doctorName: String = ""
    var nurseName: String = ""
    
    // Анамнез и жалобы
    var complaints: String = ""
    var allergicAnamnesis: String = ""
    var diseaseAnamnesis: String = ""
    var lifeAnamnesis: String = ""
    var externalExamination: String = ""
    var objectively: String = ""
    var bite: String = ""
    var xRayResults: String = ""
    
    // Статусы и диагноз
    var mucousMembrane: String = "Норма"
    var isSanationCompleted: Bool = false
    var requiresProsthetics: Bool = false
    var icd10Diagnosis: String = ""
    
    // Лечение
    var treatmentPlan: String = ""
    var anesthesia: String = ""
    var treatment: String = ""
    var prescriptions: String = ""
    var generalRecommendations: String = ""
    
    // Листок нетрудоспособности (ЛН)
    var isSickLeaveIssued: Bool = false
    var sickLeaveStartDate: Date = Date()
    var sickLeaveEndDate: Date = Date()
    var sickLeaveClosedDate: Date? = nil
    var sickLeaveNumber: String = ""
    
    var extendedProlongations: [SickLeaveExtension] = []
}

struct SickLeaveExtension: Identifiable, Codable {
    var id: UUID = UUID()
    var startDate: Date
    var endDate: Date
}
