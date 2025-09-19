import Foundation
import Combine
import os.log

@MainActor
class AuthenticationViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var currentStudent: Student?
    @Published var currentTutor: Tutor?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "App", category: "Auth")
    
    private let authStateKey = "auth.isAuthenticated"
    private let currentUserKey = "auth.currentUser"
    private let currentStudentKey = "auth.currentStudent"
    private let currentTutorKey = "auth.currentTutor"
    
    init() {
        // Attempt to restore persisted auth state in mock mode
        if let data = UserDefaults.standard.data(forKey: currentUserKey) {
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                self.currentUser = user
            } catch {
                logger.error("Failed to decode currentUser: \(error.localizedDescription, privacy: .public)")
                UserDefaults.standard.removeObject(forKey: currentUserKey)
            }
        }
        if let data = UserDefaults.standard.data(forKey: currentStudentKey) {
            do {
                let student = try JSONDecoder().decode(Student.self, from: data)
                self.currentStudent = student
            } catch {
                logger.error("Failed to decode currentStudent: \(error.localizedDescription, privacy: .public)")
                UserDefaults.standard.removeObject(forKey: currentStudentKey)
            }
        }
        if let data = UserDefaults.standard.data(forKey: currentTutorKey) {
            do {
                let tutor = try JSONDecoder().decode(Tutor.self, from: data)
                self.currentTutor = tutor
            } catch {
                logger.error("Failed to decode currentTutor: \(error.localizedDescription, privacy: .public)")
                UserDefaults.standard.removeObject(forKey: currentTutorKey)
            }
        }
        let persistedAuth = UserDefaults.standard.bool(forKey: authStateKey)
        self.isAuthenticated = persistedAuth && (self.currentUser != nil)
        logger.info("Restored auth state: isAuthenticated=\(self.isAuthenticated, privacy: .public)")
    }
    
    func checkAuthenticationStatus() {
        logger.debug("checkAuthenticationStatus -> isAuthenticated=\(self.isAuthenticated, privacy: .public)")
    }
    
    func signInWithPhoneNumber(_ phoneNumber: String) async {
        self.isLoading = true
        self.errorMessage = nil
        
        // Mock phone verification - in production would use Firebase
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
        
        // Simulate verification code sent
        UserDefaults.standard.set("mock_verification_id", forKey: "authVerificationID")
        
        self.isLoading = false
    }
    
    func verifyPhoneNumber(verificationCode: String) async {
        self.isLoading = true
        self.errorMessage = nil
        
        guard UserDefaults.standard.string(forKey: "authVerificationID") != nil else {
            self.errorMessage = "Verification ID not found"
            self.isLoading = false
            return
        }
        
        // Mock verification - in production would verify with Firebase
        if verificationCode == "123456" {
            // Success - create mock user
            self.currentUser = User(id: "mock_user_id", firstName: "Test", phoneNumber: "+61400000000", userType: .student)
            self.currentStudent = Student(userId: "mock_user_id", yearLevel: .year12)
            self.isAuthenticated = true
            self.persistAuthState()
        } else {
            self.errorMessage = "Invalid verification code"
        }
        
        self.isLoading = false
    }
    
    func registerStudent(firstName: String, yearLevel: YearLevel, phoneNumber: String) async {
        self.isLoading = true
        self.errorMessage = nil
        
        // Mock registration - in production would save to Firebase
        let user = User(id: "mock_user_id", firstName: firstName, phoneNumber: phoneNumber, userType: .student)
        let student = Student(userId: "mock_user_id", yearLevel: yearLevel)
        
        self.currentUser = user
        self.currentStudent = student
        self.isAuthenticated = true
        self.persistAuthState()
        
        self.isLoading = false
    }
    
    func registerTutor(firstName: String, lastName: String, email: String, phoneNumber: String, subjects: [String], educationLevel: EducationLevel, hourlyRate: Double, deliveryMode: DeliveryMode, suburb: String) async {
        self.isLoading = true
        self.errorMessage = nil
        
        // Mock registration - in production would save to Firebase
        let user = User(id: "mock_user_id", firstName: firstName, lastName: lastName, email: email, phoneNumber: phoneNumber, userType: .tutor)
        let tutor = Tutor(userId: "mock_user_id", subjects: subjects, educationLevel: educationLevel, hourlyRate: hourlyRate, deliveryMode: deliveryMode, suburb: suburb)
        
        self.currentUser = user
        self.currentTutor = tutor
        self.isAuthenticated = true
        self.persistAuthState()
        
        self.isLoading = false
        
        self.logger.info("Tutor registered successfully: \(firstName) \(lastName)")
    }
    
    func connectStripeAccount(accountId: String) async {
        self.isLoading = true
        self.errorMessage = nil
        
        // Mock Stripe connection - in production would integrate with Stripe Connect
        if var tutor = self.currentTutor {
            // In a real implementation, we'd create a new Tutor instance with updated Stripe info
            // For now, we'll mock it by updating the properties
            self.logger.info("Connecting Stripe account: \(accountId)")
            
            // Update persisted data to reflect Stripe connection
            self.persistAuthState()
        }
        
        self.isLoading = false
    }
    
    func updateTutorAvailability(_ availability: TutorAvailability) {
        if var tutor = self.currentTutor {
            // Update availability in the current tutor object
            // In a real app, this would be saved to the backend
            self.logger.info("Updated tutor availability")
            self.persistAuthState()
        }
    }
    
    func signOut() {
        self.currentUser = nil
        self.currentStudent = nil
        self.currentTutor = nil
        self.isAuthenticated = false
        
        UserDefaults.standard.removeObject(forKey: authStateKey)
        UserDefaults.standard.removeObject(forKey: currentUserKey)
        UserDefaults.standard.removeObject(forKey: currentStudentKey)
        UserDefaults.standard.removeObject(forKey: currentTutorKey)
        logger.info("Signed out and cleared persisted auth state")
    }
    
    private func persistAuthState() {
        UserDefaults.standard.set(self.isAuthenticated, forKey: self.authStateKey)
        if let user = self.currentUser, let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: self.currentUserKey)
        }
        if let student = self.currentStudent, let studentData = try? JSONEncoder().encode(student) {
            UserDefaults.standard.set(studentData, forKey: self.currentStudentKey)
        }
        if let tutor = self.currentTutor, let tutorData = try? JSONEncoder().encode(tutor) {
            UserDefaults.standard.set(tutorData, forKey: self.currentTutorKey)
        }
        self.logger.debug("Persisted auth state: isAuthenticated=\(self.isAuthenticated, privacy: .public)")
    }
}

