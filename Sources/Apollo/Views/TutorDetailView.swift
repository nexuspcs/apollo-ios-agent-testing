import SwiftUI

struct TutorFiltersView: View {
    @Binding var filter: TutorSearchFilter
    @Environment(\.dismiss) var dismiss
    @State private var tempFilter: TutorSearchFilter
    
    init(filter: Binding<TutorSearchFilter>) {
        self._filter = filter
        self._tempFilter = State(initialValue: filter.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Subjects") {
                    ForEach(Subject.hscSubjects.map(\.category).uniqued(), id: \.self) { category in
                        DisclosureGroup(category) {
                            ForEach(Subject.hscSubjects.filter { $0.category == category }) { subject in
                                HStack {
                                    Text(subject.name)
                                    Spacer()
                                    if tempFilter.subjects.contains(subject.id) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if tempFilter.subjects.contains(subject.id) {
                                        tempFilter.subjects.removeAll { $0 == subject.id }
                                    } else {
                                        tempFilter.subjects.append(subject.id)
                                    }
                                }
                            }
                        }
                    }
                }
                
                Section("Hourly Rate") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Maximum: $\(Int(tempFilter.maxHourlyRate ?? 100))/hour")
                            .font(.subheadline)
                        
                        Slider(
                            value: Binding(
                                get: { tempFilter.maxHourlyRate ?? 100 },
                                set: { tempFilter.maxHourlyRate = $0 }
                            ),
                            in: 20...100,
                            step: 5
                        )
                    }
                }
                
                Section("Rating") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Minimum: \(Int(tempFilter.minRating ?? 0)) stars")
                            .font(.subheadline)
                        
                        Slider(
                            value: Binding(
                                get: { tempFilter.minRating ?? 0 },
                                set: { tempFilter.minRating = $0 }
                            ),
                            in: 0...5,
                            step: 1
                        )
                    }
                }
                
                Section("Delivery Mode") {
                    ForEach(DeliveryMode.allCases, id: \.self) { mode in
                        HStack {
                            Text(mode.rawValue)
                            Spacer()
                            if tempFilter.deliveryMode == mode {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            tempFilter.deliveryMode = tempFilter.deliveryMode == mode ? nil : mode
                        }
                    }
                }
                
                Section("Availability") {
                    Toggle("Available this week", isOn: $tempFilter.availableThisWeek)
                    Toggle("Available today", isOn: $tempFilter.availableToday)
                }
                
                Section("Location") {
                    Toggle("Nearby only", isOn: $tempFilter.nearbyOnly)
                    
                    if tempFilter.nearbyOnly {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Within \(Int(tempFilter.maxDistance ?? 10)) km")
                                .font(.subheadline)
                            
                            Slider(
                                value: Binding(
                                    get: { tempFilter.maxDistance ?? 10 },
                                    set: { tempFilter.maxDistance = $0 }
                                ),
                                in: 5...50,
                                step: 5
                            )
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button("Reset") {
                            tempFilter = TutorSearchFilter()
                        }
                        
                        Button("Apply") {
                            filter = tempFilter
                            dismiss()
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
        }
    }
}

struct TutorDetailView: View {
    let tutor: Tutor
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var showingBooking = false
    @State private var showingMessage = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    tutorHeader
                    
                    // Subjects
                    subjectsSection
                    
                    // About
                    aboutSection
                    
                    // Availability
                    availabilitySection
                    
                    // Reviews (placeholder)
                    reviewsSection
                    
                    Spacer(minLength: 100) // Space for floating buttons
                }
                .padding(.horizontal, 16)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .overlay(alignment: .bottom) {
                // Floating action buttons
                HStack(spacing: 12) {
                    Button("Message") {
                        showingMessage = true
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .frame(maxWidth: .infinity)
                    
                    Button("Book Session") {
                        showingBooking = true
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: -2)
            }
            .sheet(isPresented: $showingBooking) {
                BookingView(tutor: tutor)
            }
            .sheet(isPresented: $showingMessage) {
                MessageView(recipientId: tutor.userId)
            }
        }
    }
    
    private var tutorHeader: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                // Profile image
                AsyncImage(url: URL(string: tutor.profileImageUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("First Name") // In real app, would show tutor's first name
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(tutor.suburb)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        ForEach(0..<5) { index in
                            Image(systemName: index < Int(tutor.rating) ? "star.fill" : "star")
                                .font(.subheadline)
                                .foregroundColor(.yellow)
                        }
                        
                        Text("(\(tutor.totalSessions) sessions)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("$\(Int(tutor.hourlyRate))/hour")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                Spacer()
            }
            
            // Education and delivery mode
            HStack(spacing: 16) {
                Label(tutor.educationLevel.rawValue, systemImage: "graduationcap")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Label(tutor.deliveryMode.rawValue, systemImage: tutor.deliveryMode == .online ? "video" : "person.2")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 16)
    }
    
    private var subjectsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Subjects")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 120), spacing: 8)
            ], spacing: 8) {
                ForEach(tutor.subjects, id: \.self) { subjectId in
                    if let subject = Subject.hscSubjects.first(where: { $0.id == subjectId }) {
                        Text(subject.name)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(tutor.bio ?? "Hi! I'm passionate about helping students excel in their HSC subjects. I provide personalized tutoring sessions tailored to each student's learning style and needs.")
                .font(.body)
                .lineLimit(nil)
        }
    }
    
    private var availabilitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Availability")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                ForEach(DayOfWeek.allCases, id: \.self) { day in
                    HStack {
                        Text(day.rawValue)
                            .font(.subheadline)
                            .frame(width: 80, alignment: .leading)
                        
                        let timeSlots = tutor.availability.availabilityForDay(day)
                        if timeSlots.isEmpty {
                            Text("Not available")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(timeSlots) { slot in
                                        Text("\(slot.startTime) - \(slot.endTime)")
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.green.opacity(0.1))
                                            .foregroundColor(.green)
                                            .cornerRadius(6)
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                    }
                }
            }
        }
    }
    
    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reviews")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Placeholder reviews
            VStack(spacing: 12) {
                ReviewCard(studentName: "Sarah", rating: 5, comment: "Excellent tutor! Really helped me understand calculus concepts.")
                ReviewCard(studentName: "James", rating: 4, comment: "Great at explaining complex topics in simple terms.")
            }
        }
    }
}

struct ReviewCard: View {
    let studentName: String
    let rating: Int
    let comment: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(studentName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                HStack(spacing: 2) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < rating ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }
            }
            
            Text(comment)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

#Preview {
    TutorDetailView(tutor: Tutor(
        userId: "tutor1",
        subjects: ["math-advanced", "physics"],
        educationLevel: .university,
        hourlyRate: 45.0,
        deliveryMode: .both,
        suburb: "Bondi"
    ))
    .environmentObject(AppViewModel())
}