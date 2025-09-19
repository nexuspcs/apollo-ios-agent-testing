import SwiftUI

struct StripeConnectView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var isConnecting = false
    @State private var showingSuccess = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "creditcard.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("Connect Your Stripe Account")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("To receive payments from students, you need to connect a Stripe account. This is secure and takes just a few minutes.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Benefits list
                VStack(alignment: .leading, spacing: 12) {
                    BenefitRow(icon: "checkmark.circle.fill", title: "Secure payments", subtitle: "Bank-level security for all transactions")
                    BenefitRow(icon: "calendar.circle.fill", title: "Fast payouts", subtitle: "Receive payments within 1-2 business days")
                    BenefitRow(icon: "chart.line.uptrend.xyaxis.circle.fill", title: "Track earnings", subtitle: "Detailed analytics and reporting")
                    BenefitRow(icon: "shield.checkered", title: "Protected", subtitle: "Fraud protection and dispute handling")
                }
                
                Spacer()
                
                if showingSuccess {
                    successView
                } else {
                    connectButton
                }
            }
            .padding(.horizontal, 24)
            .navigationTitle("Payment Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Skip") {
                        dismiss()
                    }
                    .disabled(isConnecting)
                }
            }
        }
    }
    
    private var connectButton: some View {
        VStack(spacing: 16) {
            Button {
                connectStripeAccount()
            } label: {
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
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
            
            Text("By connecting, you agree to Stripe's Terms of Service")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var successView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Account Connected!")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Your Stripe account has been successfully connected. You can now receive payments from students.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Continue") {
                dismiss()
            }
            .buttonStyle(PrimaryButtonStyleUno())
        }
    }
    
    private func connectStripeAccount() {
        isConnecting = true
        errorMessage = nil
        
        // Mock Stripe Connect flow
        Task {
            do {
                try await Task.sleep(nanoseconds: 2_000_000_000) // 2 second delay
                
                // Mock success - in production would integrate with Stripe Connect
                await MainActor.run {
                    // Update tutor model with Stripe connection
                    if var tutor = authViewModel.currentTutor {
                        let updatedTutor = Tutor(
                            userId: tutor.userId,
                            subjects: tutor.subjects,
                            educationLevel: tutor.educationLevel,
                            hourlyRate: tutor.hourlyRate,
                            deliveryMode: tutor.deliveryMode,
                            suburb: tutor.suburb,
                            latitude: tutor.latitude,
                            longitude: tutor.longitude
                        )
                        // In a real app, we'd create a new Tutor instance with updated Stripe info
                        // For now, we'll just mark as connected
                        authViewModel.currentTutor = updatedTutor
                    }
                    
                    isConnecting = false
                    showingSuccess = true
                    
                    // Auto-dismiss after showing success
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        dismiss()
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

struct BenefitRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct PrimaryButtonStyleUno: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(configuration.isPressed ? Color.blue.opacity(0.8) : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct StripeConnectView_Previews: PreviewProvider {
    static var previews: some View {
        StripeConnectView()
            .environmentObject(AuthenticationViewModel())
    }
}
