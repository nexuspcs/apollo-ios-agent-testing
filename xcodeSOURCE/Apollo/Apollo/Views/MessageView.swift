import SwiftUI

struct MessageView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    
    let recipientId: String
    
    @State private var messageText = ""
    @State private var messages: [Message] = []
    @State private var isSending = false
    @State private var showingBookingPrompt = false
    
    var currentUserId: String {
        authViewModel.currentUser?.id ?? ""
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Messages list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            MessageBubble(
                                message: message,
                                isFromCurrentUser: message.senderId == currentUserId
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                }
                
                // Message input
                VStack(spacing: 0) {
                    Divider()
                    
                    HStack(spacing: 12) {
                        // Quick actions for tutors
                        if authViewModel.currentUser?.userType == .tutor {
                            Button(action: { showingBookingPrompt = true }) {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.title3)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        // Message input field
                        HStack {
                            TextField("Type a message...", text: $messageText, axis: .vertical)
                                .lineLimit(1...4)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                        }
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                        
                        // Send button
                        Button(action: sendMessage) {
                            if isSending {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.up")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(width: 36, height: 36)
                        .background(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemBackground))
            }
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadMessages()
        }
        .sheet(isPresented: $showingBookingPrompt) {
            BookingPromptView(recipientId: recipientId)
        }
    }
    
    private func sendMessage() {
        let trimmedText = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        isSending = true
        
        Task {
            await appViewModel.sendMessage(to: recipientId, content: trimmedText)
            
            await MainActor.run {
                messageText = ""
                isSending = false
                loadMessages()
            }
        }
    }
    
    private func loadMessages() {
        messages = generateMockMessages()
    }
    
    private func generateMockMessages() -> [Message] {
        let conversationId = generateConversationId(senderId: currentUserId, recipientId: recipientId)
        
        return [
            Message(
                conversationId: conversationId,
                senderId: recipientId,
                recipientId: currentUserId,
                content: "Hi! I saw your profile and I'm interested in getting help with Mathematics Advanced."
            ),
            Message(
                conversationId: conversationId,
                senderId: currentUserId,
                recipientId: recipientId,
                content: "Hello! I'd be happy to help you with Mathematics Advanced. What specific topics are you struggling with?"
            ),
            Message(
                conversationId: conversationId,
                senderId: recipientId,
                recipientId: currentUserId,
                content: "I'm having trouble with calculus, particularly integration by parts and substitution methods."
            ),
            Message(
                conversationId: conversationId,
                senderId: currentUserId,
                recipientId: recipientId,
                content: "Those are great topics to work on! I can definitely help you build confidence with integration techniques. Would you like to schedule a session?"
            )
        ]
    }
    
    private func generateConversationId(senderId: String, recipientId: String) -> String {
        return [senderId, recipientId].sorted().joined(separator: "_")
    }
}

struct MessageBubble: View {
    let message: Message
    let isFromCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer(minLength: 50)
            }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.body)
                    .foregroundColor(isFromCurrentUser ? .white : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(isFromCurrentUser ? Color.blue : Color(.systemGray5))
                    .cornerRadius(18)
                
                Text(message.timestamp.formatted(.dateTime.hour().minute()))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
            
            if !isFromCurrentUser {
                Spacer(minLength: 50)
            }
        }
    }
}

struct BookingPromptView: View {
    @Environment(\.dismiss) var dismiss
    
    let recipientId: String
    
    @State private var selectedSubject = ""
    @State private var selectedDuration: SessionDuration = .oneHour
    @State private var selectedDate = Date()
    @State private var selectedDeliveryMode: DeliveryMode = .online
    @State private var additionalNotes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Session Details")) {
                    Picker("Subject", selection: $selectedSubject) {
                        ForEach(Subject.hscSubjects, id: \.id) { subject in
                            Text(subject.name).tag(subject.id)
                        }
                    }
                    
                    Picker("Duration", selection: $selectedDuration) {
                        ForEach(SessionDuration.allCases, id: \.self) { duration in
                            Text(duration.displayName).tag(duration)
                        }
                    }
                    
                    DatePicker("Preferred Date & Time", 
                              selection: $selectedDate,
                              in: Date()...,
                              displayedComponents: [.date, .hourAndMinute])
                    
                    Picker("Delivery Mode", selection: $selectedDeliveryMode) {
                        ForEach(DeliveryMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                }
                
                Section(header: Text("Additional Notes")) {
                    TextField("Any specific topics or questions?", text: $additionalNotes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Suggest Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Send Proposal") {
                        sendBookingProposal()
                    }
                    .disabled(selectedSubject.isEmpty)
                }
            }
        }
    }
    
    private func sendBookingProposal() {
        // In a real app, this would send a structured booking proposal
        dismiss()
    }
}

#Preview {
    MessageView(recipientId: "student123")
        .environmentObject(AppViewModel())
        .environmentObject(AuthenticationViewModel())
}