import SwiftUI

struct StudentRegistrationView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    
    let onComplete: () -> Void
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var yearLevel: YearLevel = .year12
    @State private var phoneNumber: String = ""
    @State private var suburb: String = ""
    @State private var selectedSubjects: Set<String> = []
    
    @State private var isSaving = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Create your student profile")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Tell us about yourself so we can find the best tutors for you")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 20) {
                        // Personal Info
                        GroupedSection(title: "Personal Information") {
                            VStack(spacing: 16) {
                                HStack(spacing: 12) {
                                    TextField("First Name", text: $firstName)
                                        .textFieldStyle(RoundedTextFieldStyle())
                                    
                                    TextField("Last Name", text: $lastName)
                                        .textFieldStyle(RoundedTextFieldStyle())
                                }
                                
                                TextField("Phone Number", text: $phoneNumber)
                                    .keyboardType(.phonePad)
                                    .textFieldStyle(RoundedTextFieldStyle())
                                
                                TextField("Suburb", text: $suburb)
                                    .autocapitalization(.words)
                                    .textFieldStyle(RoundedTextFieldStyle())
                            }
                        }
                        
                        // Academic Info
                        GroupedSection(title: "Academic Information") {
                            VStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Year Level")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Picker("Year Level", selection: $yearLevel) {
                                        ForEach(YearLevel.allCases, id: \.self) { level in
                                            Text(level.rawValue).tag(level)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Subjects of Interest")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Text("Select subjects you might need help with")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    SubjectsMultiSelectView(selectedSubjects: $selectedSubjects)
                                }
                            }
                        }
                    }
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    Button(action: saveAndContinue) {
                        HStack {
                            if isSaving {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text("Create Profile")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(isSaving || !isFormValid)
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Student Registration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !phoneNumber.trimmingCharacters(in: .whitespaces).isEmpty &&
        !suburb.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private func saveAndContinue() {
        errorMessage = nil
        
        isSaving = true
        defer { isSaving = false }
        
        Task {
            await authViewModel.registerStudent(
                firstName: firstName.trimmingCharacters(in: .whitespaces),
                lastName: lastName.trimmingCharacters(in: .whitespaces),
                phoneNumber: phoneNumber.trimmingCharacters(in: .whitespaces),
                yearLevel: yearLevel,
                suburb: suburb.trimmingCharacters(in: .whitespaces),
                subjects: Array(selectedSubjects)
            )
            
            await MainActor.run {
                onComplete()
            }
        }
    }
}

#Preview {
    StudentRegistrationView {
        // Preview action
    }
    .environmentObject(AuthenticationViewModel())
}