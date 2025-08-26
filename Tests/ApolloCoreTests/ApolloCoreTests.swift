import XCTest
@testable import ApolloCore

final class ApolloCoreTests: XCTestCase {
    
    func testUserModelCreation() throws {
        let user = User(
            id: "test-id",
            firstName: "John",
            phoneNumber: "+61400000000",
            userType: .student
        )
        
        XCTAssertEqual(user.firstName, "John")
        XCTAssertEqual(user.userType, .student)
        XCTAssertEqual(user.phoneNumber, "+61400000000")
        XCTAssertTrue(user.isActive)
    }
    
    func testStudentModelCreation() throws {
        let student = Student(
            userId: "user-123",
            yearLevel: .year12,
            subjects: ["math-advanced", "physics"],
            suburb: "Sydney"
        )
        
        XCTAssertEqual(student.userId, "user-123")
        XCTAssertEqual(student.yearLevel, .year12)
        XCTAssertEqual(student.subjects.count, 2)
        XCTAssertEqual(student.suburb, "Sydney")
    }
    
    func testTutorModelCreation() throws {
        let tutor = Tutor(
            userId: "user-456",
            subjects: ["math-advanced", "chemistry"],
            educationLevel: .university,
            hourlyRate: 45.0,
            deliveryMode: .both,
            suburb: "Bondi"
        )
        
        XCTAssertEqual(tutor.userId, "user-456")
        XCTAssertEqual(tutor.hourlyRate, 45.0)
        XCTAssertEqual(tutor.deliveryMode, .both)
        XCTAssertEqual(tutor.suburb, "Bondi")
        XCTAssertFalse(tutor.isVerified)
        XCTAssertFalse(tutor.isStripeConnected)
    }
    
    func testSessionDurationCalculation() throws {
        let session = TutoringSession(
            studentId: "student-1",
            tutorId: "tutor-1",
            subjectId: "math-advanced",
            duration: .oneHour,
            scheduledDateTime: Date(),
            deliveryMode: .online,
            totalAmount: 45.0
        )
        
        XCTAssertEqual(session.duration, .oneHour)
        XCTAssertEqual(session.totalAmount, 45.0)
        XCTAssertEqual(session.status, .pending)
    }
    
    func testHSCSubjects() throws {
        let mathSubjects = Subject.hscSubjects.filter { $0.category == "Mathematics" }
        let englishSubjects = Subject.hscSubjects.filter { $0.category == "English" }
        let scienceSubjects = Subject.hscSubjects.filter { $0.category == "Science" }
        
        XCTAssertTrue(mathSubjects.count > 0)
        XCTAssertTrue(englishSubjects.count > 0)
        XCTAssertTrue(scienceSubjects.count > 0)
        
        // Check specific subjects exist
        let mathAdvanced = Subject.hscSubjects.first { $0.id == "math-advanced" }
        XCTAssertNotNil(mathAdvanced)
        XCTAssertEqual(mathAdvanced?.name, "Mathematics Advanced")
        XCTAssertEqual(mathAdvanced?.category, "Mathematics")
    }
    
    func testTutorSearchFilter() throws {
        var filter = TutorSearchFilter()
        
        // Initially empty
        XCTAssertTrue(filter.subjects.isEmpty)
        XCTAssertNil(filter.maxHourlyRate)
        XCTAssertFalse(filter.availableThisWeek)
        
        // Add filters
        filter.subjects.append("math-advanced")
        filter.maxHourlyRate = 50.0
        filter.availableThisWeek = true
        
        XCTAssertEqual(filter.subjects.count, 1)
        XCTAssertEqual(filter.maxHourlyRate, 50.0)
        XCTAssertTrue(filter.availableThisWeek)
    }
    
    func testMessageCreation() throws {
        let message = Message(
            conversationId: "conv-123",
            senderId: "user-1",
            recipientId: "user-2",
            content: "Hello, can you help me with calculus?"
        )
        
        XCTAssertEqual(message.conversationId, "conv-123")
        XCTAssertEqual(message.senderId, "user-1")
        XCTAssertEqual(message.content, "Hello, can you help me with calculus?")
        XCTAssertFalse(message.isRead)
        XCTAssertEqual(message.messageType, .text)
    }
    
    func testPaymentCalculation() throws {
        let payment = Payment(
            sessionId: "session-123",
            studentId: "student-1",
            tutorId: "tutor-1",
            amount: 100.0,
            stripePaymentIntentId: "pi_123"
        )
        
        XCTAssertEqual(payment.amount, 100.0)
        XCTAssertEqual(payment.platformFee, 4.0) // 4% of 100
        XCTAssertEqual(payment.tutorEarnings, 96.0) // 100 - 4
        XCTAssertEqual(payment.status, .pending)
    }
}