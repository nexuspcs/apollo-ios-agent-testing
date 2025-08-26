import SwiftUI

struct BookingView: View {
    let tutor: Tutor
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var selectedSubject: String?
    @State private var selectedDuration: SessionDuration = .oneHour
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    @State private var selectedDeliveryMode: DeliveryMode = .online
    @State private var notes = ""
    @State private var isBooking = false
    @State private var showingPayment = false
    
    private var totalAmount: Double {
        let hours = Double(selectedDuration.rawValue) / 60.0
        return tutor.hourlyRate * hours
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Tutor summary
                    tutorSummary
                    
                    // Subject selection
                    subjectSelection
                    
                    // Duration selection
                    durationSelection
                    
                    // Date and time selection
                    dateTimeSelection
                    
                    // Delivery mode
                    deliveryModeSelection
                    
                    // Notes
                    notesSection
                    
                    // Price summary
                    priceSummary
                    
                    // Book button
                    bookButton
                }
                .padding(.horizontal, 16)
            }
            .navigationTitle("Book Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingPayment) {
                PaymentView(
                    amount: totalAmount,
                    tutorName: "First Name", // In real app, would show tutor's name
                    subject: selectedSubject.flatMap { subjectId in
                        Subject.hscSubjects.first(where: { $0.id == subjectId })?.name
                    } ?? "",
                    duration: selectedDuration,
                    scheduledDate: selectedDate
                )
            }
        }
    }
    
    private var tutorSummary: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: tutor.profileImageUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text("First Name") // In real app, would show tutor's name
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(tutor.suburb)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("$\(Int(tutor.hourlyRate))/hour")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var subjectSelection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Subject")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 120), spacing: 8)
            ], spacing: 8) {
                ForEach(tutor.subjects, id: \.self) { subjectId in
                    if let subject = Subject.hscSubjects.first(where: { $0.id == subjectId }) {
                        Button(action: { selectedSubject = subjectId }) {
                            Text(subject.name)
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(selectedSubject == subjectId ? Color.blue : Color.blue.opacity(0.1))
                                .foregroundColor(selectedSubject == subjectId ? .white : .blue)
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
    }
    
    private var durationSelection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Duration")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                ForEach(SessionDuration.allCases, id: \.self) { duration in
                    Button(action: { selectedDuration = duration }) {
                        VStack(spacing: 4) {
                            Text(duration.displayName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("$\(Int(tutor.hourlyRate * Double(duration.rawValue) / 60.0))")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedDuration == duration ? Color.blue : Color.blue.opacity(0.1))
                        .foregroundColor(selectedDuration == duration ? .white : .blue)
                        .cornerRadius(8)
                    }
                }
            }
        }
    }
    
    private var dateTimeSelection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Date & Time")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                DatePicker("Date", selection: $selectedDate, in: Date()..., displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                
                DatePicker("Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
            }
        }
    }
    
    private var deliveryModeSelection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Delivery Mode")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                ForEach([DeliveryMode.online, DeliveryMode.inPerson], id: \.self) { mode in
                    if tutor.deliveryMode == mode || tutor.deliveryMode == .both {
                        Button(action: { selectedDeliveryMode = mode }) {
                            HStack {
                                Image(systemName: mode == .online ? "video" : "person.2")
                                Text(mode.rawValue)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selectedDeliveryMode == mode ? Color.blue : Color.blue.opacity(0.1))
                            .foregroundColor(selectedDeliveryMode == mode ? .white : .blue)
                            .cornerRadius(8)
                        }
                    }
                }
            }
        }
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes (Optional)")
                .font(.headline)
                .fontWeight(.semibold)
            
            TextField("What would you like to focus on?", text: $notes, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(3...6)
        }
    }
    
    private var priceSummary: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Session (\(selectedDuration.displayName))")
                Spacer()
                Text("$\(String(format: "%.2f", totalAmount))")
            }
            
            HStack {
                Text("Platform fee (4%)")
                Spacer()
                Text("$\(String(format: "%.2f", totalAmount * 0.04))")
            }
            .foregroundColor(.secondary)
            
            Divider()
            
            HStack {
                Text("Total")
                    .fontWeight(.semibold)
                Spacer()
                Text("$\(String(format: "%.2f", totalAmount))")
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var bookButton: some View {
        Button("Book & Pay") {
            showingPayment = true
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(selectedSubject == nil || isBooking)
    }
}

struct PaymentView: View {
    let amount: Double
    let tutorName: String
    let subject: String
    let duration: SessionDuration
    let scheduledDate: Date
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var isProcessing = false
    @State private var paymentSuccess = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                if paymentSuccess {
                    successView
                } else {
                    paymentForm
                }
            }
            .padding(.horizontal, 16)
            .navigationTitle("Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isProcessing)
                }
            }
        }
    }
    
    private var paymentForm: some View {
        VStack(spacing: 24) {
            // Session summary
            VStack(alignment: .leading, spacing: 12) {
                Text("Session Summary")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                VStack(spacing: 8) {
                    HStack {
                        Text("Tutor:")
                        Spacer()
                        Text(tutorName)
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Text("Subject:")
                        Spacer()
                        Text(subject)
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Text("Duration:")
                        Spacer()
                        Text(duration.displayName)
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Text("Date:")
                        Spacer()
                        Text(scheduledDate.formatted(date: .abbreviated, time: .shortened))
                            .fontWeight(.medium)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Total:")
                        Spacer()
                        Text("$\(String(format: "%.2f", amount))")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
            }
            .padding(16)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            Spacer()
            
            // Payment form (placeholder for Stripe integration)
            VStack(spacing: 16) {
                Text("Payment Form")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("Stripe payment integration would go here")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button("Process Payment") {
                    processPayment()
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(isProcessing)
            }
        }
    }
    
    private var successView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Booking Confirmed!")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Your session with \(tutorName) has been booked. You'll receive a confirmation message shortly.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button("Done") {
                dismiss()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.top, 50)
    }
    
    private func processPayment() {
        isProcessing = true
        
        // Simulate payment processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isProcessing = false
            paymentSuccess = true
        }
    }
}

#Preview {
    BookingView(tutor: Tutor(
        userId: "tutor1",
        subjects: ["math-advanced", "physics"],
        educationLevel: .university,
        hourlyRate: 45.0,
        deliveryMode: .both,
        suburb: "Bondi"
    ))
    .environmentObject(AppViewModel())
}