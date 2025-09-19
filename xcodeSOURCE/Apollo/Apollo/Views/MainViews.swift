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
                MessageView(recipientId: conversation.studentId)
            }
        }
    }
}

struct TutorDashboardView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var showingEarningsAnalytics = false
    @State private var showingAvailability = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Quick actions
                    quickActionsSection
                    
                    // Earnings summary
                    earningsSection
                    
                    // Upcoming sessions
                    upcomingSessionsSection
                    
                    // Recent students
                    studentsSection
                    
                    // Performance metrics
                    performanceSection
                }
                .padding(.horizontal, 16)
            }
            .navigationTitle("Dashboard")
            .refreshable {
                // Refresh data
                Task {
                    await appViewModel.loadUserSessions(userId: "current_user_id")
                }
            }
        }
        .sheet(isPresented: $showingEarningsAnalytics) {
            EarningsAnalyticsView()
        }
        .sheet(isPresented: $showingAvailability) {
            TutorAvailabilityView()
        }
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                QuickActionButton(
                    title: "Set Availability",
                    icon: "calendar",
                    color: .blue
                ) {
                    showingAvailability = true
                }
                
                QuickActionButton(
                    title: "View Earnings",
                    icon: "chart.bar",
                    color: .green
                ) {
                    showingEarningsAnalytics = true
                }
                
                QuickActionButton(
                    title: "Messages",
                    icon: "message",
                    color: .orange
                ) {
                    // Navigate to messages
                }
            }
        }
    }
    
    private var earningsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Earnings")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("View Analytics") {
                    showingEarningsAnalytics = true
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            HStack(spacing: 20) {
                EarningsCard(title: "This Week", amount: 450.00, color: .green)
                EarningsCard(title: "This Month", amount: 1850.00, color: .blue)
            }
            
            // Earnings trend indicator
            HStack {
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundColor(.green)
                Text("+12.3% vs last week")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var upcomingSessionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Upcoming Sessions")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                if !appViewModel.sessions.isEmpty {
                    Text("\(appViewModel.sessions.count) sessions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if appViewModel.sessions.isEmpty {
                EmptyStateView(
                    icon: "calendar",
                    title: "No upcoming sessions",
                    subtitle: "Students will book sessions with you soon!"
                )
            } else {
                ForEach(appViewModel.sessions.prefix(3)) { session in
                    SessionCard(session: session)
                }
                
                if appViewModel.sessions.count > 3 {
                    Button("View All Sessions") {
                        // Navigate to full schedule
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
            }
        }
    }
    
    private var studentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your Students")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("3 active")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(0..<3) { index in
                        StudentCard(
                            name: ["Sarah M.", "James L.", "Emma R."][index],
                            subject: ["Mathematics", "Physics", "Chemistry"][index],
                            nextSession: Calendar.current.date(byAdding: .day, value: index + 1, to: Date()) ?? Date()
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    private var performanceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Performance")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                PerformanceCard(title: "Rating", value: "4.8", icon: "star.fill", color: .orange)
                PerformanceCard(title: "Response", value: "98%", icon: "message.fill", color: .blue)
                PerformanceCard(title: "Sessions", value: "89", icon: "calendar", color: .green)
                PerformanceCard(title: "Students", value: "24", icon: "person.2.fill", color: .purple)
            }
        }
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
    @State private var showingAvailability = false
    @State private var showingStripeConnect = false
    @State private var showingEarningsAnalytics = false
    
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
                            if let tutor = authViewModel.currentTutor {
                                Text("\(tutor.subjects.count) subjects • \(tutor.suburb)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        // Verification badge
                        if authViewModel.currentTutor?.isVerified == true {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.title3)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Tutor Profile") {
                    NavigationLink("Edit Profile", destination: Text("Edit Profile"))
                    NavigationLink("Subjects & Rates", destination: Text("Subjects & Rates"))
                    
                    Button("Availability") {
                        showingAvailability = true
                    }
                    .foregroundColor(.primary)
                    
                    Button("Payment Setup") {
                        showingStripeConnect = true
                    }
                    .foregroundColor(.primary)
                }
                
                Section("Performance") {
                    Button("Earnings Analytics") {
                        showingEarningsAnalytics = true
                    }
                    .foregroundColor(.primary)
                    
                    NavigationLink("Reviews", destination: Text("Reviews"))
                    NavigationLink("Statistics", destination: Text("Statistics"))
                }
                
                Section("Settings") {
                    NavigationLink("Notifications", destination: Text("Notifications"))
                    NavigationLink("Privacy", destination: Text("Privacy"))
                    NavigationLink("Help Center", destination: Text("Help Center"))
                    NavigationLink("Contact Support", destination: Text("Contact Support"))
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
        .sheet(isPresented: $showingAvailability) {
            TutorAvailabilityView()
        }
        .sheet(isPresented: $showingStripeConnect) {
            StripeConnectView()
        }
        .sheet(isPresented: $showingEarningsAnalytics) {
            EarningsAnalyticsView()
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

//struct MessageView: View {
//    let recipientId: String
//    @Environment(\.dismiss) var dismiss
//    @EnvironmentObject var appViewModel: AppViewModel
//    @State private var messageText = ""
//    @State private var messages: [Message] = []
//    
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 0) {
//                // Messages list
//                ScrollView {
//                    LazyVStack(spacing: 12) {
//                        ForEach(messages) { message in
//                            MessageBubble(message: message, isFromCurrentUser: message.senderId == "current_user_id")
//                        }
//                    }
//                    .padding(.horizontal, 16)
//                }
//                
//                // Message input
//                HStack(spacing: 12) {
//                    TextField("Type a message...", text: $messageText, axis: .vertical)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                        .lineLimit(1...4)
//                    
//                    Button("Send") {
//                        sendMessage()
//                    }
//                    .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
//                }
//                .padding(.horizontal, 16)
//                .padding(.vertical, 12)
//                .background(Color(.systemBackground))
//            }
//            .navigationTitle("Messages")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Close") {
//                        dismiss()
//                    }
//                }
//            }
//            .onAppear {
//                loadMessages()
//            }
//        }
//    }
//    
//    private func sendMessage() {
//        let content = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !content.isEmpty else { return }
//        
//        let message = Message(
//            conversationId: "conversation_id",
//            senderId: "current_user_id",
//            recipientId: recipientId,
//            content: content
//        )
//        
//        messages.append(message)
//        messageText = ""
//        
//        Task {
//            await appViewModel.sendMessage(to: recipientId, content: content)
//        }
//    }
//    
//    private func loadMessages() {
//        // Load mock messages
//        messages = [
//            Message(
//                conversationId: "conversation_id",
//                senderId: recipientId,
//                recipientId: "current_user_id",
//                content: "Hi! How can I help you with your studies?"
//            ),
//            Message(
//                conversationId: "conversation_id",
//                senderId: "current_user_id",
//                recipientId: recipientId,
//                content: "I'm struggling with calculus. Do you have any availability this week?"
//            )
//        ]
//    }
//}

//struct MessageBubble: View {
//    let message: Message
//    let isFromCurrentUser: Bool
//    
//    var body: some View {
//        HStack {
//            if isFromCurrentUser {
//                Spacer()
//            }
//            
//            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
//                Text(message.content)
//                    .padding(.horizontal, 16)
//                    .padding(.vertical, 12)
//                    .background(isFromCurrentUser ? Color.blue : Color(.systemGray5))
//                    .foregroundColor(isFromCurrentUser ? .white : .primary)
//                    .cornerRadius(18)
//                
//                Text(message.timestamp.formatted(.dateTime.hour().minute()))
//                    .font(.caption2)
//                    .foregroundColor(.secondary)
//            }
//            
//            if !isFromCurrentUser {
//                Spacer()
//            }
//        }
//    }
//}

// MARK: - Enhanced Dashboard Components

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StudentCard: View {
    let name: String
    let subject: String
    let nextSession: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(name.prefix(1)))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(subject)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Text("Next: \(nextSession.formatted(.dateTime.month().day().hour().minute()))")
                .font(.caption)
                .foregroundColor(.blue)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .frame(width: 180)
    }
}

struct PerformanceCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    StudentDashboardView()
        .environmentObject(AppViewModel())
        .environmentObject(AuthenticationViewModel())
}
