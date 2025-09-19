import SwiftUI

// MARK: - Student Views

struct StudentMessagesView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var selectedConversation: Conversation?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(appViewModel.conversations) { conversation in
                    Button(action: { selectedConversation = conversation }) {
                        ConversationRow(conversation: conversation)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Messages")
            .onAppear {
                Task {
                    await appViewModel.loadConversations(userId: "current_user_id")
                }
            }
            .sheet(item: $selectedConversation) { conversation in
                MessageView(recipientId: conversation.tutorId)
            }
        }
    }
}

struct StudentDashboardView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Upcoming sessions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Upcoming Sessions")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if appViewModel.sessions.isEmpty {
                            EmptyStateView(
                                icon: "calendar",
                                title: "No upcoming sessions",
                                subtitle: "Book your first session to get started!"
                            )
                        } else {
                            ForEach(appViewModel.sessions) { session in
                                SessionCard(session: session)
                            }
                        }
                    }
                    
                    // Recent tutors
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Tutors")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(appViewModel.tutors.prefix(5)) { tutor in
                                    TutorAvatarCard(tutor: tutor)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .navigationTitle("Dashboard")
            .onAppear {
                Task {
                    await appViewModel.loadUserSessions(userId: "current_user_id")
                }
            }
        }
    }
}

struct StudentProfileView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text(authViewModel.currentUser?.firstName ?? "Student")
                                .font(.headline)
                            Text(authViewModel.currentStudent?.yearLevel.rawValue ?? "Year 12")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Account") {
                    NavigationLink("Edit Profile", destination: Text("Edit Profile"))
                    NavigationLink("Payment Methods", destination: Text("Payment Methods"))
                    NavigationLink("Session History", destination: Text("Session History"))
                }
                
                Section("Support") {
                    NavigationLink("Help Center", destination: Text("Help Center"))
                    NavigationLink("Contact Support", destination: Text("Contact Support"))
                    NavigationLink("Terms & Conditions", destination: Text("Terms & Conditions"))
                }
                
                Section {
                    Button("Sign Out") {
                        authViewModel.signOut()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Profile")
        }
    }
}

// MARK: - Tutor Views

struct TutorMessagesView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var selectedConversation: Conversation?
    @State private var searchText = ""
    
    var filteredConversations: [Conversation] {
        if searchText.isEmpty {
            return appViewModel.conversations
        } else {
            return appViewModel.conversations.filter { conversation in
                // In a real app, you'd filter by student name or last message content
                conversation.lastMessage?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search conversations", text: $searchText)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                if filteredConversations.isEmpty {
                    EmptyStateView(
                        icon: "message",
                        title: searchText.isEmpty ? "No conversations yet" : "No matching conversations",
                        subtitle: searchText.isEmpty ? "Start chatting with students!" : "Try a different search term"
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredConversations) { conversation in
                            Button(action: { selectedConversation = conversation }) {
                                EnhancedConversationRow(conversation: conversation)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Messages")
            .onAppear {
                Task {
                    await appViewModel.loadConversations(userId: authViewModel.currentUser?.id ?? "")
                }
            }
            .sheet(item: $selectedConversation) { conversation in
                MessageView(recipientId: conversation.studentId)
            }
        }
    }
}

struct EnhancedConversationRow: View {
    let conversation: Conversation
    
    var body: some View {
        HStack(spacing: 12) {
            // Student avatar
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 50, height: 50)
                .overlay(
                    Text("S") // In real app, would use student's first letter
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Student Name") // In real app, would show actual student name
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    if let timestamp = conversation.lastMessageTimestamp {
                        Text(timestamp.formatted(.dateTime.month().day().hour().minute()))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Text(conversation.lastMessage ?? "No messages yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if conversation.unreadCount > 0 {
                        Text("\(conversation.unreadCount)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
    }
}

struct TutorDashboardView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var showingEarningsAnalytics = false
    @State private var showingAvailabilitySettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Welcome section
                    if let tutor = authViewModel.currentTutor, let user = authViewModel.currentUser {
                        TutorWelcomeCard(tutorName: user.firstName, isStripeConnected: tutor.isStripeConnected)
                    }
                    
                    // Quick actions
                    QuickActionsGrid(
                        onEarningsAnalytics: { showingEarningsAnalytics = true },
                        onAvailabilitySettings: { showingAvailabilitySettings = true }
                    )
                    
                    // Earnings summary
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Earnings")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button("View Details") {
                                showingEarningsAnalytics = true
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        }
                        
                        HStack(spacing: 20) {
                            EarningsCard(title: "This Week", amount: 450.00, color: .green)
                            EarningsCard(title: "This Month", amount: 1850.00, color: .blue)
                        }
                    }
                    
                    // Booking requests
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Booking Requests")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if mockBookingRequests.isEmpty {
                            EmptyStateView(
                                icon: "bell",
                                title: "No new booking requests",
                                subtitle: "We'll notify you when students want to book sessions"
                            )
                        } else {
                            ForEach(mockBookingRequests, id: \.id) { request in
                                BookingRequestCard(request: request)
                            }
                        }
                    }
                    
                    // Upcoming sessions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Upcoming Sessions")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if appViewModel.sessions.isEmpty {
                            EmptyStateView(
                                icon: "calendar",
                                title: "No upcoming sessions",
                                subtitle: "Students will book sessions with you soon!"
                            )
                        } else {
                            ForEach(appViewModel.sessions) { session in
                                SessionCard(session: session)
                            }
                        }
                    }
                    
                    // Recent students
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Students")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("3 active students")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 16)
            }
            .navigationTitle("Dashboard")
            .sheet(isPresented: $showingEarningsAnalytics) {
                EarningsAnalyticsView()
            }
            .sheet(isPresented: $showingAvailabilitySettings) {
                TutorAvailabilityView()
            }
        }
        .onAppear {
            Task {
                await appViewModel.loadUserSessions(userId: authViewModel.currentUser?.id ?? "")
            }
        }
    }
    
    private var mockBookingRequests: [BookingRequest] {
        [
            BookingRequest(
                id: "req1",
                studentName: "Sarah M.",
                subject: "Mathematics Advanced",
                preferredDateTime: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date(),
                duration: .oneHour,
                deliveryMode: .online,
                message: "Hi! I need help with calculus for my upcoming exam."
            ),
            BookingRequest(
                id: "req2",
                studentName: "James L.",
                subject: "Physics",
                preferredDateTime: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
                duration: .twoHours,
                deliveryMode: .inPerson,
                message: "Looking for help with kinematics and dynamics."
            )
        ]
    }
}

// MARK: - Supporting Views for Enhanced Dashboard

struct TutorWelcomeCard: View {
    let tutorName: String
    let isStripeConnected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Welcome back, \(tutorName)! 👋")
                .font(.title3)
                .fontWeight(.semibold)
            
            if !isStripeConnected {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    
                    Text("Complete your Stripe setup to receive payments")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button("Set up") {
                        // Handle Stripe setup
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct QuickActionsGrid: View {
    let onEarningsAnalytics: () -> Void
    let onAvailabilitySettings: () -> Void
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            QuickActionCard(
                icon: "chart.bar.fill",
                title: "Analytics",
                subtitle: "View earnings",
                color: .blue
            ) {
                onEarningsAnalytics()
            }
            
            QuickActionCard(
                icon: "calendar.badge.plus",
                title: "Availability",
                subtitle: "Set schedule",
                color: .green
            ) {
                onAvailabilitySettings()
            }
            
            QuickActionCard(
                icon: "person.badge.plus",
                title: "Students",
                subtitle: "Manage students",
                color: .purple
            ) {
                // Handle students management
            }
            
            QuickActionCard(
                icon: "bell.fill",
                title: "Notifications",
                subtitle: "Settings",
                color: .orange
            ) {
                // Handle notifications
            }
        }
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
}

struct BookingRequestCard: View {
    let request: BookingRequest
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(request.studentName.prefix(1)))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(request.studentName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(request.subject)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(request.preferredDateTime.formatted(.dateTime.month().day().hour().minute()))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(request.message)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack(spacing: 8) {
                Button("Accept") {
                    // Handle accept
                }
                .buttonStyle(CompactButtonStyle(backgroundColor: .green))
                
                Button("Decline") {
                    // Handle decline
                }
                .buttonStyle(CompactButtonStyle(backgroundColor: .red))
                
                Spacer()
                
                Button("Message") {
                    // Handle message
                }
                .buttonStyle(CompactButtonStyle(backgroundColor: .blue))
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct CompactButtonStyle: ButtonStyle {
    let backgroundColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(backgroundColor)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Data Models

struct BookingRequest {
    let id: String
    let studentName: String
    let subject: String
    let preferredDateTime: Date
    let duration: SessionDuration
    let deliveryMode: DeliveryMode
    let message: String
}
}

struct TutorScheduleView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Schedule Management")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Manage your availability and upcoming sessions")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Calendar placeholder
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                        .frame(height: 300)
                        .overlay(
                            Text("Calendar view would go here")
                                .foregroundColor(.secondary)
                        )
                }
                .padding(.horizontal, 16)
            }
            .navigationTitle("Schedule")
        }
    }
}

struct TutorProfileView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text(authViewModel.currentUser?.firstName ?? "Tutor")
                                .font(.headline)
                            Text("Mathematics & Physics")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Tutor Profile") {
                    NavigationLink("Edit Profile", destination: Text("Edit Profile"))
                    NavigationLink("Subjects & Rates", destination: Text("Subjects & Rates"))
                    NavigationLink("Availability", destination: Text("Availability"))
                    NavigationLink("Stripe Account", destination: Text("Stripe Account"))
                }
                
                Section("Performance") {
                    NavigationLink("Earnings", destination: Text("Earnings"))
                    NavigationLink("Reviews", destination: Text("Reviews"))
                    NavigationLink("Statistics", destination: Text("Statistics"))
                }
                
                Section("Support") {
                    NavigationLink("Help Center", destination: Text("Help Center"))
                    NavigationLink("Contact Support", destination: Text("Contact Support"))
                    NavigationLink("Terms & Conditions", destination: Text("Terms & Conditions"))
                }
                
                Section {
                    Button("Sign Out") {
                        authViewModel.signOut()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Profile")
        }
    }
}

// MARK: - Shared Components

struct ConversationRow: View {
    let conversation: Conversation
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Tutor Name") // In real app, would show actual name
                    .font(.headline)
                
                Text(conversation.lastMessage ?? "Start a conversation")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                if let timestamp = conversation.lastMessageTimestamp {
                    Text(timestamp.formatted(.dateTime.hour().minute()))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if conversation.unreadCount > 0 {
                    Text("\(conversation.unreadCount)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                        .background(Color.red)
                        .clipShape(Circle())
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct SessionCard: View {
    let session: TutoringSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if let subject = Subject.hscSubjects.first(where: { $0.id == session.subjectId }) {
                        Text(subject.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    
                    Text("With Tutor Name") // In real app, would show actual tutor name
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("$\(Int(session.totalAmount))")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            
            HStack(spacing: 16) {
                Label(session.scheduledDateTime.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Label(session.deliveryMode.rawValue, systemImage: session.deliveryMode == .online ? "video" : "person.2")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct TutorAvatarCard: View {
    let tutor: Tutor
    
    var body: some View {
        VStack(spacing: 8) {
            AsyncImage(url: URL(string: tutor.profileImageUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            
            Text("First Name") // In real app, would show actual name
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
            
            Text(tutor.suburb)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .frame(width: 80)
    }
}

struct EarningsCard: View {
    let title: String
    let amount: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("$\(String(format: "%.0f", amount))")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
    }
}

struct MessageView: View {
    let recipientId: String
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var messageText = ""
    @State private var messages: [Message] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Messages list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            MessageBubble(message: message, isFromCurrentUser: message.senderId == "current_user_id")
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                // Message input
                HStack(spacing: 12) {
                    TextField("Type a message...", text: $messageText, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(1...4)
                    
                    Button("Send") {
                        sendMessage()
                    }
                    .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
            }
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadMessages()
            }
        }
    }
    
    private func sendMessage() {
        let content = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }
        
        let message = Message(
            conversationId: "conversation_id",
            senderId: "current_user_id",
            recipientId: recipientId,
            content: content
        )
        
        messages.append(message)
        messageText = ""
        
        Task {
            await appViewModel.sendMessage(to: recipientId, content: content)
        }
    }
    
    private func loadMessages() {
        // Load mock messages
        messages = [
            Message(
                conversationId: "conversation_id",
                senderId: recipientId,
                recipientId: "current_user_id",
                content: "Hi! How can I help you with your studies?"
            ),
            Message(
                conversationId: "conversation_id",
                senderId: "current_user_id",
                recipientId: recipientId,
                content: "I'm struggling with calculus. Do you have any availability this week?"
            )
        ]
    }
}

struct MessageBubble: View {
    let message: Message
    let isFromCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer()
            }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(isFromCurrentUser ? Color.blue : Color(.systemGray5))
                    .foregroundColor(isFromCurrentUser ? .white : .primary)
                    .cornerRadius(18)
                
                Text(message.timestamp.formatted(.dateTime.hour().minute()))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if !isFromCurrentUser {
                Spacer()
            }
        }
    }
}

#Preview {
    StudentDashboardView()
        .environmentObject(AppViewModel())
        .environmentObject(AuthenticationViewModel())
}