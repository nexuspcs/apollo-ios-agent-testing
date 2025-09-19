import Foundation
import Combine
import os.log

@MainActor
class AppViewModel: ObservableObject {
    @Published var tutors: [Tutor] = []
    @Published var sessions: [TutoringSession] = []
    @Published var messages: [Message] = []
    @Published var conversations: [Conversation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "App", category: "AppViewModel")
    
    // MARK: - Init
    
    init() {
        AppConfig.load()
        logger.info("App readyForProduction=\(AppConfig.readyForProduction, privacy: .public), firebase=\(AppConfig.firebaseConfigured, privacy: .public)")
    }
    
    // MARK: - Tutor Search
    
    func searchTutors(filter: TutorSearchFilter) async {
        logger.debug("Using mock mode: \(AppConfig.isMockMode, privacy: .public)")
        isLoading = true
        errorMessage = nil
        
        // Simulate API call - in real app, this would query Firebase
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
        
        // Mock data for demonstration
        tutors = generateMockTutors()
        
        isLoading = false
    }
    
    func loadNearbyTutors(latitude: Double, longitude: Double) async {
        logger.debug("Using mock mode: \(AppConfig.isMockMode, privacy: .public)")
        isLoading = true
        
        // In real app, this would query tutors by location from Firebase
        tutors = generateMockTutors()
        
        isLoading = false
    }
    
    // MARK: - Session Management
    
    func bookSession(tutorId: String, subjectId: String, duration: SessionDuration, scheduledDateTime: Date, deliveryMode: DeliveryMode, hourlyRate: Double) async -> Bool {
        logger.debug("Booking session in mock mode: \(AppConfig.isMockMode, privacy: .public)")
        isLoading = true
        errorMessage = nil
        
        do {
            // Calculate total amount
            let hours = Double(duration.rawValue) / 60.0
            let totalAmount = hourlyRate * hours
            
            // Create session (placeholder - would integrate with Stripe)
            let session = TutoringSession(
                studentId: "current_student_id", // Would get from auth
                tutorId: tutorId,
                subjectId: subjectId,
                duration: duration,
                scheduledDateTime: scheduledDateTime,
                deliveryMode: deliveryMode,
                totalAmount: totalAmount
            )
            
            // Save to Firebase and process payment
            sessions.append(session)
            
            isLoading = false
            return true
        } catch {
            errorMessage = "Booking failed: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
    
    func loadUserSessions(userId: String) async {
        logger.debug("Using mock mode: \(AppConfig.isMockMode, privacy: .public)")
        isLoading = true
        
        // Load sessions from Firebase
        sessions = generateMockSessions()
        
        isLoading = false
    }
    
    // MARK: - Messaging
    
    func sendMessage(to recipientId: String, content: String) async {
        let conversationId = generateConversationId(senderId: "current_user_id", recipientId: recipientId)
        
        let message = Message(
            conversationId: conversationId,
            senderId: "current_user_id",
            recipientId: recipientId,
            content: content
        )
        
        // Save to Firebase
        messages.append(message)
        
        // Update conversation
        if let index = conversations.firstIndex(where: { $0.id == conversationId }) {
            var conversation = conversations[index]
            conversation = Conversation(studentId: conversation.studentId, tutorId: conversation.tutorId)
            conversations[index] = conversation
        } else {
            let conversation = Conversation(studentId: "current_user_id", tutorId: recipientId)
            conversations.append(conversation)
        }
    }
    
    func loadConversations(userId: String) async {
        logger.debug("Using mock mode: \(AppConfig.isMockMode, privacy: .public)")
        isLoading = true
        
        // Load conversations from Firebase
        conversations = generateMockConversations()
        
        isLoading = false
    }
    
    func loadMessages(conversationId: String) async {
        logger.debug("Using mock mode: \(AppConfig.isMockMode, privacy: .public)")
        isLoading = true
        
        // Load messages from Firebase
        messages = generateMockMessages()
        
        isLoading = false
    }
    
    // MARK: - Private Methods
    
    private func generateConversationId(senderId: String, recipientId: String) -> String {
        return [senderId, recipientId].sorted().joined(separator: "_")
    }
    
    // MARK: - Mock Data Generation
    
    private func generateMockTutors() -> [Tutor] {
        return [
            Tutor(
                userId: "tutor1",
                subjects: ["math-advanced", "physics"],
                educationLevel: .university,
                hourlyRate: 45.0,
                deliveryMode: .both,
                suburb: "Bondi",
                latitude: -33.8915,
                longitude: 151.2767
            ),
            Tutor(
                userId: "tutor2",
                subjects: ["english-advanced", "modern-history"],
                educationLevel: .university,
                hourlyRate: 40.0,
                deliveryMode: .online,
                suburb: "Manly"
            ),
            Tutor(
                userId: "tutor3",
                subjects: ["chemistry", "biology"],
                educationLevel: .gapYear,
                hourlyRate: 35.0,
                deliveryMode: .inPerson,
                suburb: "Parramatta"
            )
        ]
    }
    
    private func generateMockSessions() -> [TutoringSession] {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        
        return [
            TutoringSession(
                studentId: "current_student_id",
                tutorId: "tutor1",
                subjectId: "math-advanced",
                duration: .oneHour,
                scheduledDateTime: tomorrow,
                deliveryMode: .online,
                totalAmount: 45.0
            )
        ]
    }
    
    private func generateMockConversations() -> [Conversation] {
        return [
            Conversation(studentId: "current_student_id", tutorId: "tutor1"),
            Conversation(studentId: "current_student_id", tutorId: "tutor2")
        ]
    }
    
    private func generateMockMessages() -> [Message] {
        return [
            Message(
                conversationId: "conversation1",
                senderId: "tutor1",
                recipientId: "current_student_id",
                content: "Hi! I can help you with Mathematics Advanced. When would you like to schedule a session?"
            ),
            Message(
                conversationId: "conversation1",
                senderId: "current_student_id",
                recipientId: "tutor1",
                content: "Hi! I'm struggling with calculus. Are you available tomorrow afternoon?"
            )
        ]
    }
}
