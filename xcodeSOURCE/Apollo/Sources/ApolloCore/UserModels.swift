import Foundation

// MARK: - User Model
struct User: Codable, Identifiable {
    let id: String
    let firstName: String
    let lastName: String?
    let email: String?
    let phoneNumber: String
    let userType: UserType
    let createdAt: Date
    let isActive: Bool
    
    init(id: String, firstName: String, lastName: String? = nil, email: String? = nil, phoneNumber: String, userType: UserType) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.userType = userType
        self.createdAt = Date()
        self.isActive = true
    }
}

// MARK: - Student Model
struct Student: Codable, Identifiable {
    let id: String
    let userId: String
    let yearLevel: YearLevel
    let subjects: [String] // Subject IDs
    let suburb: String?
    
    init(userId: String, yearLevel: YearLevel, subjects: [String] = [], suburb: String? = nil) {
        self.id = UUID().uuidString
        self.userId = userId
        self.yearLevel = yearLevel
        self.subjects = subjects
        self.suburb = suburb
    }
}

// MARK: - Tutor Model
struct Tutor: Codable, Identifiable {
    let id: String
    let userId: String
    let subjects: [String] // Subject IDs
    let educationLevel: EducationLevel
    let hourlyRate: Double
    let deliveryMode: DeliveryMode
    let suburb: String
    let latitude: Double?
    let longitude: Double?
    let bio: String?
    let profileImageUrl: String?
    let isVerified: Bool
    let isStripeConnected: Bool
    let stripeAccountId: String?
    let availability: TutorAvailability
    let rating: Double
    let totalSessions: Int
    
    init(userId: String, subjects: [String], educationLevel: EducationLevel, hourlyRate: Double, deliveryMode: DeliveryMode, suburb: String, latitude: Double? = nil, longitude: Double? = nil) {
        self.id = UUID().uuidString
        self.userId = userId
        self.subjects = subjects
        self.educationLevel = educationLevel
        self.hourlyRate = hourlyRate
        self.deliveryMode = deliveryMode
        self.suburb = suburb
        self.latitude = latitude
        self.longitude = longitude
        self.bio = nil
        self.profileImageUrl = nil
        self.isVerified = false
        self.isStripeConnected = false
        self.stripeAccountId = nil
        self.availability = TutorAvailability()
        self.rating = 0.0
        self.totalSessions = 0
    }
}

// MARK: - Tutor Availability
struct TutorAvailability: Codable {
    var monday: [TimeSlot]
    var tuesday: [TimeSlot]
    var wednesday: [TimeSlot]
    var thursday: [TimeSlot]
    var friday: [TimeSlot]
    var saturday: [TimeSlot]
    var sunday: [TimeSlot]
    
    init() {
        self.monday = []
        self.tuesday = []
        self.wednesday = []
        self.thursday = []
        self.friday = []
        self.saturday = []
        self.sunday = []
    }
    
    func availabilityForDay(_ day: DayOfWeek) -> [TimeSlot] {
        switch day {
        case .monday: return monday
        case .tuesday: return tuesday
        case .wednesday: return wednesday
        case .thursday: return thursday
        case .friday: return friday
        case .saturday: return saturday
        case .sunday: return sunday
        }
    }
}

enum DayOfWeek: String, CaseIterable, Codable {
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    case sunday = "Sunday"
}

struct TimeSlot: Codable, Identifiable {
    let id: String
    let startTime: String // Format: "HH:mm"
    let endTime: String // Format: "HH:mm"
    
    init(startTime: String, endTime: String) {
        self.id = UUID().uuidString
        self.startTime = startTime
        self.endTime = endTime
    }
}