import SwiftUI

struct TutorRegistrationView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var selectedSubjects: Set<String> = []
    @State private var educationLevel: EducationLevel = .highSchool
    @State private var deliveryMode: DeliveryMode = .both
    @State private var hourlyRate: String = ""
    @State private var suburb: String = ""

    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Info")) {
                    TextField("First Name", text: $firstName)
                        .autocapitalization(.words)
                    TextField("Last Name", text: $lastName)
                        .autocapitalization(.words)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                }
                Section(header: Text("Subjects")) {
                    SubjectsMultiSelectView(selectedSubjects: $selectedSubjects)
                }
                Section(header: Text("Education & Delivery")) {
                    Picker("Education Level", selection: $educationLevel) {
                        ForEach(EducationLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    Picker("Delivery Mode", selection: $deliveryMode) {
                        ForEach([DeliveryMode.online, DeliveryMode.inPerson, DeliveryMode.both], id: \.self) { mode in
                            Text(mode.rawValue.capitalized).tag(mode)
                        }
                    }
                }
                Section(header: Text("Rate & Location")) {
                    TextField("Hourly Rate", text: $hourlyRate)
                        .keyboardType(.decimalPad)
                    TextField("Suburb", text: $suburb)
                        .autocapitalization(.words)
                }
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                Section {
                    Button {
                        Task {
                            await save()
                        }
                    } label: {
                        if isSaving {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            Text("Save")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .disabled(isSaving)
                }
            }
            .navigationTitle("Register as Tutor")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func save() async {
        errorMessage = nil
        guard !firstName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "First name is required."
            return
        }
        guard !phoneNumber.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Phone number is required."
            return
        }
        guard !selectedSubjects.isEmpty else {
            errorMessage = "Please select at least one subject."
            return
        }
        isSaving = true
        defer { isSaving = false }
        let rateDouble = Double(hourlyRate)
        await authViewModel.registerTutor(
            firstName: firstName.trimmingCharacters(in: .whitespaces),
            lastName: lastName.trimmingCharacters(in: .whitespaces),
            email: email.trimmingCharacters(in: .whitespaces),
            phoneNumber: phoneNumber.trimmingCharacters(in: .whitespaces),
            subjects: Array(selectedSubjects),
            educationLevel: educationLevel,
            deliveryMode: deliveryMode,
            hourlyRate: rateDouble,
            suburb: suburb.trimmingCharacters(in: .whitespaces)
        )
        dismiss()
    }
}

private struct SubjectsMultiSelectView: View {
    @Binding var selectedSubjects: Set<String>

    var body: some View {
        let columns = [GridItem(.adaptive(minimum: 100), spacing: 8)]
        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(Subject.hscSubjects, id: \.id) { subject in
                let isSelected = selectedSubjects.contains(subject.id)
                Button {
                    if isSelected {
                        selectedSubjects.remove(subject.id)
                    } else {
                        selectedSubjects.insert(subject.id)
                    }
                } label: {
                    Text(subject.name)
                        .font(.subheadline)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .foregroundColor(isSelected ? .white : .primary)
                        .background(isSelected ? Color.accentColor : Color(UIColor.systemGray5))
                        .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 4)
    }
}

struct TutorRegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        TutorRegistrationView()
            .environmentObject(AuthenticationViewModel())
    }
}
