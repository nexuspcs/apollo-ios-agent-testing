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
    var availability: TutorAvailability
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
    var availability: [DayOfWeek: [TimeSlot]]
    
    init(availability: [DayOfWeek: [TimeSlot]] = [:]) {
        self.availability = availability
    }
    
    func availabilityForDay(_ day: DayOfWeek) -> [TimeSlot] {
        return availability[day] ?? []
    }
    
    mutating func setAvailability(for day: DayOfWeek, slots: [TimeSlot]) {
        availability[day] = slots
    }
}

enum DayOfWeek: String, CaseIterable, Codable, Identifiable {
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    case sunday = "Sunday"
    
    var id: String { rawValue }
    
    var displayName: String { rawValue }
}

struct TimeSlot: Codable, Identifiable {
    let id: String
    let start: String // Format: "HH:mm"
    let end: String // Format: "HH:mm"
    
    init(start: String, end: String) {
        self.id = UUID().uuidString
        self.start = start
        self.end = end
    }
    
    // Backward compatibility
    var startTime: String { start }
    var endTime: String { end }
}