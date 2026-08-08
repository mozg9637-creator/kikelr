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
    var patientID: UUID?          // связь с карточкой пациента (может отсутствовать у старых записей)
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
         patientID: UUID? = nil,
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
        self.patientID = patientID
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

// MARK: - Пациент (карточка)

@Model
final class Patient {
    var id: UUID
    var number: Int                // номер карты пациента, как "№17553"
    var fullName: String
    var birthDate: Date?
    var phone: String
    var generalNotes: String       // общие заметки / хронические заболевания и т.п.
    var createdAt: Date

    init(number: Int,
         fullName: String,
         birthDate: Date? = nil,
         phone: String = "",
         generalNotes: String = "") {
        self.id = UUID()
        self.number = number
        self.fullName = fullName
        self.birthDate = birthDate
        self.phone = phone
        self.generalNotes = generalNotes
        self.createdAt = Date()
    }

    static func nextNumber() -> Int {
        let key = "nextPatientNumber"
        let defaults = UserDefaults.standard
        let current = defaults.object(forKey: key) as? Int ?? 10001
        defaults.set(current + 1, forKey: key)
        return current
    }
}

// MARK: - Зубная формула (одонтограмма, двухцифровая система FDI)

enum ToothStatusCode: String, CaseIterable, Identifiable {
    case norm = "Н"
    case milk = "М"
    case missing = "О"
    case artificial = "И"
    case filling = "П"
    case removed = "У"
    case caries = "С"
    case pulpitis = "Р"
    case periodontitis = "Pt"
    case parodontitis = "А"
    case root = "R"
    case fluorosis = "Ф"
    case hypoplasia = "Г"
    case wedgeDefect = "Кл"
    case crown = "К"
    case retention = "Re"
    case dystopia = "D"
    case implant = "Имп"
    case implantCrown = "ИМПк"
    case pathologicalAbrasion = "Пст"

    var id: String { rawValue }

    /// Расшифровка кода, как принято в российских стоматологических картах.
    var fullDescription: String {
        switch self {
        case .norm: return "Норма"
        case .milk: return "Молочный зуб"
        case .missing: return "Отсутствующий зуб"
        case .artificial: return "Искусственный зуб"
        case .filling: return "Пломба"
        case .removed: return "Удалён"
        case .caries: return "Кариес"
        case .pulpitis: return "Пульпит"
        case .periodontitis: return "Периодонтит"
        case .parodontitis: return "Пародонтит"
        case .root: return "Корень"
        case .fluorosis: return "Флюороз"
        case .hypoplasia: return "Гипоплазия"
        case .wedgeDefect: return "Клиновидный дефект"
        case .crown: return "Искусственная коронка"
        case .retention: return "Ретенция"
        case .dystopia: return "Дистопия"
        case .implant: return "Имплант"
        case .implantCrown: return "Коронка на импланте"
        case .pathologicalAbrasion: return "Патологическая стираемость"
        }
    }
}

/// Номера зубов постоянного прикуса по двухцифровой системе (FDI) —
/// первая цифра означает квадрант (1–4), вторая — позицию от центра (1–8).
/// Именно эта раскладка используется в российских стоматологических картах.
enum ToothChart {
    static let upperRight = [18, 17, 16, 15, 14, 13, 12, 11]
    static let upperLeft = [21, 22, 23, 24, 25, 26, 27, 28]
    static let lowerLeft = [48, 47, 46, 45, 44, 43, 42, 41]
    static let lowerRight = [31, 32, 33, 34, 35, 36, 37, 38]
    static let allTeeth = upperRight + upperLeft + lowerLeft + lowerRight
}

// MARK: - Запись осмотра в карте пациента (по образцу карты стоматолога)

@Model
final class ExamRecord {
    var id: UUID
    var patientID: UUID
    var date: Date
    var examType: String            // "Взрослая" / "Детская"
    var doctorName: String
    var nurseName: String

    // Осмотр
    var complaints: String              // Жалобы
    var allergyHistory: String          // Аллергологический анамнез
    var diseaseHistory: String          // Анамнез заболевания
    var lifeHistory: String             // Анамнез жизни
    var externalExam: String            // Внешний осмотр
    var objectively: String             // Объективно
    var bite: String                    // Прикус
    var xrayResults: String             // Результаты рентгеновских исследований
    var mucous: String                  // Слизистые
    var sanitationDone: Bool            // Санация полости рта
    var prostheticsNeeded: Bool         // Требуется протезирование
    var diagnosisICD10: String          // Общий диагноз по МКБ10

    // Лечение
    var treatmentPlan: String           // План лечения
    var anesthesia: String              // Анестезия
    var treatment: String               // Лечение
    var prescriptions: String           // Назначения

    // Листок нетрудоспособности
    var sickLeaveNumber: String
    var sickLeaveIssuedFrom: Date?
    var sickLeaveIssuedTo: Date?
    var sickLeaveExtended1From: Date?
    var sickLeaveExtended1To: Date?
    var sickLeaveExtended2From: Date?
    var sickLeaveExtended2To: Date?
    var sickLeaveClosedFrom: Date?

    var generalRecommendations: String  // Общие рекомендации
    var specialNotes: String            // Особые отметки
    var toothFormulaData: String        // JSON: [номер зуба (строкой): код состояния]
    var createdAt: Date

    /// Зубная формула в удобном виде: номер зуба (11–48) → код состояния (Н, С, П, ...).
    var toothFormula: [Int: String] {
        get {
            guard let data = toothFormulaData.data(using: .utf8),
                  let raw = try? JSONDecoder().decode([String: String].self, from: data) else { return [:] }
            var result: [Int: String] = [:]
            for (key, value) in raw {
                if let intKey = Int(key) { result[intKey] = value }
            }
            return result
        }
        set {
            let raw = Dictionary(uniqueKeysWithValues: newValue.map { (String($0.key), $0.value) })
            if let data = try? JSONEncoder().encode(raw), let json = String(data: data, encoding: .utf8) {
                toothFormulaData = json
            }
        }
    }

    init(patientID: UUID,
         date: Date = Date(),
         examType: String = "Взрослая",
         doctorName: String = "",
         nurseName: String = "",
         complaints: String = "",
         allergyHistory: String = "",
         diseaseHistory: String = "",
         lifeHistory: String = "",
         externalExam: String = "",
         objectively: String = "",
         bite: String = "",
         xrayResults: String = "",
         mucous: String = "",
         sanitationDone: Bool = false,
         prostheticsNeeded: Bool = false,
         diagnosisICD10: String = "",
         treatmentPlan: String = "",
         anesthesia: String = "",
         treatment: String = "",
         prescriptions: String = "",
         sickLeaveNumber: String = "",
         sickLeaveIssuedFrom: Date? = nil,
         sickLeaveIssuedTo: Date? = nil,
         sickLeaveExtended1From: Date? = nil,
         sickLeaveExtended1To: Date? = nil,
         sickLeaveExtended2From: Date? = nil,
         sickLeaveExtended2To: Date? = nil,
         sickLeaveClosedFrom: Date? = nil,
         generalRecommendations: String = "",
         specialNotes: String = "",
         toothFormulaData: String = "{}") {
        self.id = UUID()
        self.patientID = patientID
        self.date = date
        self.examType = examType
        self.doctorName = doctorName
        self.nurseName = nurseName
        self.complaints = complaints
        self.allergyHistory = allergyHistory
        self.diseaseHistory = diseaseHistory
        self.lifeHistory = lifeHistory
        self.externalExam = externalExam
        self.objectively = objectively
        self.bite = bite
        self.xrayResults = xrayResults
        self.mucous = mucous
        self.sanitationDone = sanitationDone
        self.prostheticsNeeded = prostheticsNeeded
        self.diagnosisICD10 = diagnosisICD10
        self.treatmentPlan = treatmentPlan
        self.anesthesia = anesthesia
        self.treatment = treatment
        self.prescriptions = prescriptions
        self.sickLeaveNumber = sickLeaveNumber
        self.sickLeaveIssuedFrom = sickLeaveIssuedFrom
        self.sickLeaveIssuedTo = sickLeaveIssuedTo
        self.sickLeaveExtended1From = sickLeaveExtended1From
        self.sickLeaveExtended1To = sickLeaveExtended1To
        self.sickLeaveExtended2From = sickLeaveExtended2From
        self.sickLeaveExtended2To = sickLeaveExtended2To
        self.sickLeaveClosedFrom = sickLeaveClosedFrom
        self.generalRecommendations = generalRecommendations
        self.specialNotes = specialNotes
        self.toothFormulaData = toothFormulaData
        self.createdAt = Date()
    }
}
