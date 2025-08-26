import Foundation

// MARK: - Session Model
struct TutoringSession: Codable, Identifiable {
    let id: String
    let studentId: String
    let tutorId: String
    let subjectId: String
    let duration: SessionDuration
    let scheduledDateTime: Date
    let deliveryMode: DeliveryMode
    let location: String? // For in-person sessions
    let meetingLink: String? // For online sessions
    let totalAmount: Double
    let stripePaymentIntentId: String?
    let status: SessionStatus
    let createdAt: Date
    let notes: String?
    
    init(studentId: String, tutorId: String, subjectId: String, duration: SessionDuration, scheduledDateTime: Date, deliveryMode: DeliveryMode, totalAmount: Double, location: String? = nil) {
        self.id = UUID().uuidString
        self.studentId = studentId
        self.tutorId = tutorId
        self.subjectId = subjectId
        self.duration = duration
        self.scheduledDateTime = scheduledDateTime
        self.deliveryMode = deliveryMode
        self.location = location
        self.meetingLink = nil
        self.totalAmount = totalAmount
        self.stripePaymentIntentId = nil
        self.status = .pending
        self.createdAt = Date()
        self.notes = nil
    }
}

enum SessionStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case confirmed = "confirmed"
    case inProgress = "in_progress"
    case completed = "completed"
    case cancelled = "cancelled"
}

// MARK: - Message Model
struct Message: Codable, Identifiable {
    let id: String
    let conversationId: String
    let senderId: String
    let recipientId: String
    let content: String
    let timestamp: Date
    let isRead: Bool
    let messageType: MessageType
    
    init(conversationId: String, senderId: String, recipientId: String, content: String, messageType: MessageType = .text) {
        self.id = UUID().uuidString
        self.conversationId = conversationId
        self.senderId = senderId
        self.recipientId = recipientId
        self.content = content
        self.timestamp = Date()
        self.isRead = false
        self.messageType = messageType
    }
}

enum MessageType: String, Codable {
    case text = "text"
    case bookingPrompt = "booking_prompt"
    case sessionConfirmation = "session_confirmation"
}

// MARK: - Conversation Model
struct Conversation: Codable, Identifiable {
    let id: String
    let studentId: String
    let tutorId: String
    let lastMessage: String?
    let lastMessageTimestamp: Date?
    let unreadCount: Int
    let isActive: Bool
    let createdAt: Date
    
    init(studentId: String, tutorId: String) {
        self.id = UUID().uuidString
        self.studentId = studentId
        self.tutorId = tutorId
        self.lastMessage = nil
        self.lastMessageTimestamp = nil
        self.unreadCount = 0
        self.isActive = true
        self.createdAt = Date()
    }
}

// MARK: - Search Filter Model
struct TutorSearchFilter: Codable {
    var subjects: [String] // Subject IDs
    var minRating: Double?
    var maxHourlyRate: Double?
    var deliveryMode: DeliveryMode?
    var availableThisWeek: Bool
    var availableToday: Bool
    var nearbyOnly: Bool
    var maxDistance: Double? // in kilometers
    
    init() {
        self.subjects = []
        self.minRating = nil
        self.maxHourlyRate = nil
        self.deliveryMode = nil
        self.availableThisWeek = false
        self.availableToday = false
        self.nearbyOnly = false
        self.maxDistance = nil
    }
}

// MARK: - Payment Model
struct Payment: Codable, Identifiable {
    let id: String
    let sessionId: String
    let studentId: String
    let tutorId: String
    let amount: Double
    let stripePaymentIntentId: String
    let platformFee: Double // 4% commission
    let tutorEarnings: Double
    let status: PaymentStatus
    let createdAt: Date
    let processedAt: Date?
    
    init(sessionId: String, studentId: String, tutorId: String, amount: Double, stripePaymentIntentId: String) {
        self.id = UUID().uuidString
        self.sessionId = sessionId
        self.studentId = studentId
        self.tutorId = tutorId
        self.amount = amount
        self.stripePaymentIntentId = stripePaymentIntentId
        self.platformFee = amount * 0.04 // 4% commission
        self.tutorEarnings = amount - (amount * 0.04)
        self.status = .pending
        self.createdAt = Date()
        self.processedAt = nil
    }
}

enum PaymentStatus: String, Codable {
    case pending = "pending"
    case processing = "processing"
    case succeeded = "succeeded"
    case failed = "failed"
    case refunded = "refunded"
}