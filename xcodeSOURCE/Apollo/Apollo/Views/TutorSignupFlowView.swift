import SwiftUI

struct TutorSignupFlowView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    
    let onComplete: () -> Void
    
    @State private var currentStep: SignupStep = .registration
    @State private var showingSuccess = false
    
    var body: some View {
        NavigationView {
            Group {
                switch currentStep {
                case .registration:
                    TutorRegistrationStepView { 
                        currentStep = .stripeConnect
                    }
                case .stripeConnect:
                    TutorStripeConnectStepView {
                        currentStep = .availability
                    }
                case .availability:
                    TutorAvailabilityStepView {
                        showingSuccess = true
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingSuccess) {
            TutorSignupSuccessView {
                onComplete()
            }
        }
    }
}

enum SignupStep: CaseIterable {
    case registration
    case stripeConnect
    case availability
    
    var title: String {
        switch self {
        case .registration: return "Personal Info"
        case .stripeConnect: return "Payment Setup"
        case .availability: return "Set Availability"
        }
    }
    
    var stepNumber: Int {
        switch self {
        case .registration: return 1
        case .stripeConnect: return 2
        case .availability: return 3
        }
    }
}

struct TutorRegistrationStepView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    let onNext: () -> Void
    
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
        ScrollView {
            VStack(spacing: 24) {
                // Step indicator
                StepIndicatorView(currentStep: 1, totalSteps: 3)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Let's get you set up as a tutor")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Fill in your details to create your tutor profile")
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
                            
                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .textFieldStyle(RoundedTextFieldStyle())
                            
                            TextField("Phone Number", text: $phoneNumber)
                                .keyboardType(.phonePad)
                                .textFieldStyle(RoundedTextFieldStyle())
                            
                            TextField("Suburb", text: $suburb)
                                .autocapitalization(.words)
                                .textFieldStyle(RoundedTextFieldStyle())
                        }
                    }
                    
                    // Education & Subjects
                    GroupedSection(title: "Teaching Details") {
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Education Level")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Picker("Education Level", selection: $educationLevel) {
                                    ForEach(EducationLevel.allCases, id: \.self) { level in
                                        Text(level.rawValue).tag(level)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Subjects")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                SubjectsMultiSelectView(selectedSubjects: $selectedSubjects)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Delivery Mode")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Picker("Delivery Mode", selection: $deliveryMode) {
                                    ForEach(DeliveryMode.allCases, id: \.self) { mode in
                                        Text(mode.rawValue).tag(mode)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Hourly Rate ($)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                TextField("45", text: $hourlyRate)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(RoundedTextFieldStyle())
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
                        Text("Continue to Payment Setup")
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
        .navigationTitle("Step 1 of 3")
    }
    
    private var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !phoneNumber.trimmingCharacters(in: .whitespaces).isEmpty &&
        !selectedSubjects.isEmpty &&
        !hourlyRate.trimmingCharacters(in: .whitespaces).isEmpty &&
        !suburb.trimmingCharacters(in: .whitespaces).isEmpty &&
        Double(hourlyRate) != nil
    }
    
    private func saveAndContinue() {
        errorMessage = nil
        guard let rateDouble = Double(hourlyRate), rateDouble > 0 else {
            errorMessage = "Please enter a valid hourly rate."
            return
        }
        
        isSaving = true
        defer { isSaving = false }
        
        Task {
            await authViewModel.registerTutor(
                firstName: firstName.trimmingCharacters(in: .whitespaces),
                lastName: lastName.trimmingCharacters(in: .whitespaces),
                email: email.trimmingCharacters(in: .whitespaces),
                phoneNumber: phoneNumber.trimmingCharacters(in: .whitespaces),
                subjects: Array(selectedSubjects),
                educationLevel: educationLevel,
                hourlyRate: rateDouble,
                deliveryMode: deliveryMode,
                suburb: suburb.trimmingCharacters(in: .whitespaces)
            )
            
            await MainActor.run {
                onNext()
            }
        }
    }
}

struct TutorStripeConnectStepView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    let onNext: () -> Void
    
    @State private var isConnecting = false
    @State private var errorMessage: String?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Step indicator
                StepIndicatorView(currentStep: 2, totalSteps: 3)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Set up payments")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Connect your Stripe account to receive payments from students")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Benefits
                VStack(spacing: 16) {
                    BenefitRow(
                        icon: "creditcard",
                        title: "Secure Payments",
                        subtitle: "Get paid securely through Stripe"
                    )
                    
                    BenefitRow(
                        icon: "clock",
                        title: "Fast Transfers",
                        subtitle: "Receive payments within 2 business days"
                    )
                    
                    BenefitRow(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Track Earnings",
                        subtitle: "See detailed analytics and earnings history"
                    )
                    
                    BenefitRow(
                        icon: "shield.checkered",
                        title: "Protected",
                        subtitle: "Your financial data is encrypted and secure"
                    )
                }
                .padding(.vertical, 20)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
                
                VStack(spacing: 12) {
                    Button(action: connectStripeAccount) {
                        HStack {
                            if isConnecting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "creditcard")
                            }
                            Text("Connect Stripe Account")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(isConnecting)
                    
                    Button("Skip for now") {
                        onNext()
                    }
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                }
                
                Text("By connecting, you agree to Stripe's Terms of Service")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }
            .padding(.horizontal, 20)
        }
        .navigationTitle("Step 2 of 3")
    }
    
    private func connectStripeAccount() {
        isConnecting = true
        errorMessage = nil
        
        Task {
            do {
                try await Task.sleep(nanoseconds: 2_000_000_000) // 2 second delay
                
                await MainActor.run {
                    // Mock Stripe connection
                    Task {
                        await authViewModel.connectStripeAccount(accountId: "acct_mock_\(UUID().uuidString)")
                        isConnecting = false
                        onNext()
                    }
                }
            } catch {
                await MainActor.run {
                    isConnecting = false
                    errorMessage = "Failed to connect Stripe account. Please try again."
                }
            }
        }
    }
}

struct TutorAvailabilityStepView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    let onNext: () -> Void
    
    @State private var availability: TutorAvailability = .init(availability: [:])
    @State private var addingDay: DayOfWeek?
    @State private var newStartTime = Date()
    @State private var newEndTime = Date()
    @State private var showAddSlotSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Step indicator
                StepIndicatorView(currentStep: 3, totalSteps: 3)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Set your availability")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Let students know when you're available for tutoring sessions")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 16) {
                    ForEach(DayOfWeek.allCases) { day in
                        AvailabilityDayCard(
                            day: day,
                            slots: availability.availability[day] ?? [],
                            onAddSlot: {
                                addingDay = day
                                newStartTime = defaultStartTime()
                                newEndTime = defaultEndTime()
                                showAddSlotSheet = true
                            },
                            onDeleteSlot: { indexSet in
                                var slots = availability.availability[day] ?? []
                                slots.remove(atOffsets: indexSet)
                                if slots.isEmpty {
                                    availability.availability[day] = nil
                                } else {
                                    availability.availability[day] = slots
                                }
                            }
                        )
                    }
                }
                
                VStack(spacing: 12) {
                    Button("Complete Setup") {
                        saveAvailability()
                        onNext()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    
                    Button("Skip for now") {
                        onNext()
                    }
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                }
                .padding(.top, 20)
            }
            .padding(.horizontal, 20)
        }
        .navigationTitle("Step 3 of 3")
        .sheet(isPresented: $showAddSlotSheet) {
            if let day = addingDay {
                NavigationView {
                    Form {
                        Section(header: Text("Start Time")) {
                            DatePicker("Start", selection: $newStartTime, displayedComponents: [.hourAndMinute])
                                .datePickerStyle(WheelDatePickerStyle())
                        }
                        Section(header: Text("End Time")) {
                            DatePicker("End", selection: $newEndTime, displayedComponents: [.hourAndMinute])
                                .datePickerStyle(WheelDatePickerStyle())
                        }
                    }
                    .navigationTitle("Add Slot - \(day.displayName)")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Add") {
                                let startStr = dateToString(newStartTime)
                                let endStr = dateToString(newEndTime)
                                let newSlot = TimeSlot(start: startStr, end: endStr)
                                var slots = availability.availability[day] ?? []
                                slots.append(newSlot)
                                availability.availability[day] = slots.sorted(by: { $0.start < $1.start })
                                showAddSlotSheet = false
                            }
                            .disabled(newEndTime <= newStartTime)
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showAddSlotSheet = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func saveAvailability() {
        authViewModel.updateTutorAvailability(availability)
    }
    
    private func defaultStartTime() -> Date {
        var components = DateComponents()
        components.hour = 9
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    private func defaultEndTime() -> Date {
        var components = DateComponents()
        components.hour = 10
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    private func dateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct TutorSignupSuccessView: View {
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                
                Text("Welcome to Apollo!")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Your tutor profile has been created successfully. You can now start accepting students and earning money.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            Spacer()
            
            Button("Start Tutoring") {
                onComplete()
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Supporting Views

struct StepIndicatorView: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        HStack {
            ForEach(1...totalSteps, id: \.self) { step in
                Circle()
                    .fill(step <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: 12, height: 12)
                
                if step < totalSteps {
                    Rectangle()
                        .fill(step < currentStep ? Color.blue : Color.gray.opacity(0.3))
                        .frame(height: 2)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, 10)
    }
}

struct GroupedSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            content
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
    }
}

struct AvailabilityDayCard: View {
    let day: DayOfWeek
    let slots: [TimeSlot]
    let onAddSlot: () -> Void
    let onDeleteSlot: (IndexSet) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(day.displayName)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: onAddSlot) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
            }
            
            if slots.isEmpty {
                Text("No availability set")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                    .italic()
            } else {
                ForEach(slots.indices, id: \.self) { index in
                    HStack {
                        Text("\(slots[index].start) - \(slots[index].end)")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Button(action: {
                            onDeleteSlot(IndexSet(integer: index))
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    TutorSignupFlowView {
        // Preview action
    }
    .environmentObject(AuthenticationViewModel())
}