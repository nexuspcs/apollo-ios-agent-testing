import Foundation
import Combine

@MainActor
class AuthenticationViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var currentStudent: Student?
    @Published var currentTutor: Tutor?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Mock authentication state for development
        // In production, would listen to Firebase Auth state changes
        isAuthenticated = false
    }
    
    func checkAuthenticationStatus() {
        // Mock implementation - in production would check Firebase auth
        isAuthenticated = false
    }
    
    func signInWithPhoneNumber(_ phoneNumber: String) async {
        isLoading = true
        errorMessage = nil
        
        // Mock phone verification - in production would use Firebase
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
        
        // Simulate verification code sent
        UserDefaults.standard.set("mock_verification_id", forKey: "authVerificationID")
        
        isLoading = false
    }
    
    func verifyPhoneNumber(verificationCode: String) async {
        isLoading = true
        errorMessage = nil
        
        guard UserDefaults.standard.string(forKey: "authVerificationID") != nil else {
            errorMessage = "Verification ID not found"
            isLoading = false
            return
        }
        
        // Mock verification - in production would verify with Firebase
        if verificationCode == "123456" {
            // Success - create mock user
            currentUser = User(id: "mock_user_id", firstName: "Test", phoneNumber: "+61400000000", userType: .student)
            currentStudent = Student(userId: "mock_user_id", yearLevel: .year12)
            isAuthenticated = true
        } else {
            errorMessage = "Invalid verification code"
        }
        
        isLoading = false
    }
    
    func registerStudent(firstName: String, yearLevel: YearLevel, phoneNumber: String) async {
        isLoading = true
        errorMessage = nil
        
        // Mock registration - in production would save to Firebase
        let user = User(id: "mock_user_id", firstName: firstName, phoneNumber: phoneNumber, userType: .student)
        let student = Student(userId: "mock_user_id", yearLevel: yearLevel)
        
        currentUser = user
        currentStudent = student
        isAuthenticated = true
        
        isLoading = false
    }
    
    func registerTutor(firstName: String, lastName: String, email: String, phoneNumber: String, subjects: [String], educationLevel: EducationLevel, hourlyRate: Double, deliveryMode: DeliveryMode, suburb: String) async {
        isLoading = true
        errorMessage = nil
        
        // Mock registration - in production would save to Firebase
        let user = User(id: "mock_user_id", firstName: firstName, lastName: lastName, email: email, phoneNumber: phoneNumber, userType: .tutor)
        let tutor = Tutor(userId: "mock_user_id", subjects: subjects, educationLevel: educationLevel, hourlyRate: hourlyRate, deliveryMode: deliveryMode, suburb: suburb)
        
        currentUser = user
        currentTutor = tutor
        isAuthenticated = true
        
        isLoading = false
    }
    
    func signOut() {
        currentUser = nil
        currentStudent = nil
        currentTutor = nil
        isAuthenticated = false
    }
}