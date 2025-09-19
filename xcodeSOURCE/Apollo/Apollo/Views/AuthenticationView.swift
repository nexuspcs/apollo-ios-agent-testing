import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var showingRegistration = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // Logo and title
                VStack(spacing: 16) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("Apollo")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Connect with HSC tutors")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Authentication form
                PhoneAuthView()
                
                Spacer()
                
                // Sign up prompt
                HStack {
                    Text("New to Apollo?")
                        .foregroundColor(.secondary)
                    
                    Button("Sign up") {
                        showingRegistration = true
                    }
                    .foregroundColor(.blue)
                }
                .padding(.bottom, 50)
            }
            .padding(.horizontal, 32)
            .sheet(isPresented: $showingRegistration) {
                UserTypeSelectionView()
            }
        }
    }
}

struct PhoneAuthView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var phoneNumber = ""
    @State private var verificationCode = ""
    @State private var showingVerification = false
    
    var body: some View {
        VStack(spacing: 20) {
            if !showingVerification {
                // Phone number input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Phone Number")
                        .font(.headline)
                    
                    HStack {
                        Text("+61")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 16)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        
                        TextField("400 000 000", text: $phoneNumber)
                            .keyboardType(.phonePad)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
                
                Button("Send Code") {
                    Task {
                        await authViewModel.signInWithPhoneNumber("+61\(phoneNumber)")
                        showingVerification = true
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(phoneNumber.isEmpty || authViewModel.isLoading)
            } else {
                // Verification code input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Verification Code")
                        .font(.headline)
                    
                    Text("Enter the 6-digit code sent to +61\(phoneNumber)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextField("123456", text: $verificationCode)
                        .keyboardType(.numberPad)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                
                Button("Verify") {
                    Task {
                        await authViewModel.verifyPhoneNumber(verificationCode: verificationCode)
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(verificationCode.isEmpty || authViewModel.isLoading)
                
                Button("Resend Code") {
                    Task {
                        await authViewModel.signInWithPhoneNumber("+61\(phoneNumber)")
                    }
                }
                .foregroundColor(.blue)
            }
            
            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }
}

struct UserTypeSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedUserType: UserType?
    @State private var showingTutorRegistration = false
    @State private var showingStudentRegistration = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Text("I am a...")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Choose your role to get started")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 50)
                
                Spacer()
                
                VStack(spacing: 20) {
                    // Student option
                    UserTypeCard(
                        userType: .student,
                        title: "Student",
                        subtitle: "Find HSC tutors",
                        icon: "graduationcap",
                        isSelected: selectedUserType == .student
                    ) {
                        selectedUserType = .student
                    }
                    
                    // Tutor option
                    UserTypeCard(
                        userType: .tutor,
                        title: "Tutor",
                        subtitle: "Teach and earn money",
                        icon: "person.fill.checkmark",
                        isSelected: selectedUserType == .tutor
                    ) {
                        selectedUserType = .tutor
                    }
                }
                
                Spacer()
                
                Button("Continue") {
                    if let userType = selectedUserType {
                        if userType == .tutor {
                            showingTutorRegistration = true
                        } else {
                            showingStudentRegistration = true
                        }
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(selectedUserType == nil)
                .padding(.bottom, 50)
            }
            .padding(.horizontal, 32)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingTutorRegistration) {
            TutorSignupFlowView {
                dismiss()
            }
        }
        .sheet(isPresented: $showingStudentRegistration) {
            StudentRegistrationView {
                dismiss()
            }
        }
    }
}

struct UserTypeCard: View {
    let userType: UserType
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : .blue)
                    .frame(width: 50, height: 50)
                    .background(isSelected ? Color.blue : Color.blue.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.blue)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(AuthenticationViewModel())
}