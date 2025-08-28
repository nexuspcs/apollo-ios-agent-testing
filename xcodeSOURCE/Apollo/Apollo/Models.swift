import Foundation

// MARK: - User Types
enum UserType: String, Codable, CaseIterable {
    case student
    case tutor
}

enum YearLevel: String, Codable, CaseIterable {
    case year7 = "Year 7"
    case year8 = "Year 8"
    case year9 = "Year 9"
    case year10 = "Year 10"
    case year11 = "Year 11"
    case year12 = "Year 12"
}

enum EducationLevel: String, Codable, CaseIterable {
    case highSchool = "High School"
    case university = "University"
    case gapYear = "Gap Year"
}

enum DeliveryMode: String, Codable, CaseIterable {
    case inPerson = "In Person"
    case online = "Online"
    case both = "Both"
}

enum SessionDuration: Int, Codable, CaseIterable {
    case thirtyMinutes = 30
    case oneHour = 60
    case twoHours = 120
    
    var displayName: String {
        switch self {
        case .thirtyMinutes: return "30 min"
        case .oneHour: return "1 hour"
        case .twoHours: return "2 hours"
        }
    }
}

// MARK: - Subject Model
struct Subject: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let category: String
    
    static let hscSubjects: [Subject] = [
        // Mathematics
        Subject(id: "math-standard", name: "Mathematics Standard", category: "Mathematics"),
        Subject(id: "math-advanced", name: "Mathematics Advanced", category: "Mathematics"),
        Subject(id: "math-extension1", name: "Mathematics Extension 1", category: "Mathematics"),
        Subject(id: "math-extension2", name: "Mathematics Extension 2", category: "Mathematics"),
        
        // English
        Subject(id: "english-standard", name: "English Standard", category: "English"),
        Subject(id: "english-advanced", name: "English Advanced", category: "English"),
        Subject(id: "english-extension1", name: "English Extension 1", category: "English"),
        Subject(id: "english-extension2", name: "English Extension 2", category: "English"),
        
        // Sciences
        Subject(id: "biology", name: "Biology", category: "Science"),
        Subject(id: "chemistry", name: "Chemistry", category: "Science"),
        Subject(id: "physics", name: "Physics", category: "Science"),
        
        // Humanities
        Subject(id: "modern-history", name: "Modern History", category: "Humanities"),
        Subject(id: "ancient-history", name: "Ancient History", category: "Humanities"),
        Subject(id: "geography", name: "Geography", category: "Humanities"),
        Subject(id: "economics", name: "Economics", category: "Humanities"),
        Subject(id: "business-studies", name: "Business Studies", category: "Humanities"),
        
        // Languages
        Subject(id: "french", name: "French", category: "Languages"),
        Subject(id: "german", name: "German", category: "Languages"),
        Subject(id: "spanish", name: "Spanish", category: "Languages"),
        Subject(id: "japanese", name: "Japanese", category: "Languages"),
        Subject(id: "chinese", name: "Chinese", category: "Languages"),
    ]
}