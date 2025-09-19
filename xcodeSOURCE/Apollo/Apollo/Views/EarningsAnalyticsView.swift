import SwiftUI

struct EarningsAnalyticsView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var selectedPeriod: EarningsPeriod = .thisMonth
    @State private var showingDetails = false
    
    private let mockEarningsData = EarningsData(
        thisWeek: 450.00,
        thisMonth: 1850.00,
        lastMonth: 1650.00,
        thisYear: 8750.00,
        totalEarnings: 15420.00,
        sessionCount: 89,
        avgSessionValue: 52.5
    )
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Period selector
                    periodSelector
                    
                    // Main earnings card
                    mainEarningsCard
                    
                    // Quick stats
                    quickStatsGrid
                    
                    // Earnings chart placeholder
                    earningsChart
                    
                    // Recent transactions
                    recentTransactions
                }
                .padding(.horizontal, 16)
            }
            .navigationTitle("Earnings Analytics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Details") {
                        showingDetails = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingDetails) {
            EarningsDetailView(earningsData: mockEarningsData)
        }
    }
    
    private var periodSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(EarningsPeriod.allCases, id: \.self) { period in
                    PeriodButton(
                        title: period.rawValue,
                        isSelected: selectedPeriod == period
                    ) {
                        selectedPeriod = period
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private var mainEarningsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedPeriod.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("$\(Int(earningsForPeriod))")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("vs Previous")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up")
                            .font(.caption)
                        Text("+12.3%")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.green)
                }
            }
            
            // Progress indicator
            ProgressView(value: progressValue, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .scaleEffect(x: 1, y: 2, anchor: .center)
            
            Text("$\(Int(earningsForPeriod * 1.2)) goal")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var quickStatsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatCard(
                title: "Sessions",
                value: "\(mockEarningsData.sessionCount)",
                icon: "calendar",
                color: .blue
            )
            StatCard(
                title: "Avg/Session",
                value: "$\(Int(mockEarningsData.avgSessionValue))",
                icon: "chart.bar",
                color: .green
            )
            StatCard(
                title: "Students",
                value: "24",
                icon: "person.2",
                color: .purple
            )
            StatCard(
                title: "Rating",
                value: "4.8",
                icon: "star",
                color: .orange
            )
        }
    }
    
    private var earningsChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Earnings Trend")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Placeholder for chart - in real app would use Charts framework
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .frame(height: 200)
                .overlay(
                    VStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("Chart visualization")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Weekly earnings trend")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                )
        }
    }
    
    private var recentTransactions: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Payments")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("View All") {
                    showingDetails = true
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            VStack(spacing: 12) {
                ForEach(mockTransactions, id: \.id) { transaction in
                    TransactionRow(transaction: transaction)
                }
            }
        }
    }
    
    private var earningsForPeriod: Double {
        switch selectedPeriod {
        case .thisWeek:
            return mockEarningsData.thisWeek
        case .thisMonth:
            return mockEarningsData.thisMonth
        case .lastMonth:
            return mockEarningsData.lastMonth
        case .thisYear:
            return mockEarningsData.thisYear
        }
    }
    
    private var progressValue: Double {
        earningsForPeriod / (earningsForPeriod * 1.2)
    }
    
    private let mockTransactions = [
        MockTransaction(id: "1", studentName: "Sarah M.", amount: 85.00, date: Date(), subject: "Mathematics"),
        MockTransaction(id: "2", studentName: "James L.", amount: 120.00, date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), subject: "Physics"),
        MockTransaction(id: "3", studentName: "Emma R.", amount: 65.00, date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(), subject: "Chemistry")
    ]
}

struct PeriodButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
        }
    }
}

struct StatCard: View {
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

struct TransactionRow: View {
    let transaction: MockTransaction
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(transaction.studentName.prefix(1)))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.studentName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(transaction.subject)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("$\(String(format: "%.2f", transaction.amount))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                
                Text(transaction.date.formatted(.dateTime.month().day()))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct EarningsDetailView: View {
    let earningsData: EarningsData
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Summary cards
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        DetailCard(title: "Total Earnings", value: "$\(Int(earningsData.totalEarnings))")
                        DetailCard(title: "This Year", value: "$\(Int(earningsData.thisYear))")
                        DetailCard(title: "This Month", value: "$\(Int(earningsData.thisMonth))")
                        DetailCard(title: "This Week", value: "$\(Int(earningsData.thisWeek))")
                    }
                    
                    Divider()
                    
                    // Performance metrics
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Performance Metrics")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        MetricRow(title: "Total Sessions", value: "\(earningsData.sessionCount)")
                        MetricRow(title: "Average per Session", value: "$\(String(format: "%.2f", earningsData.avgSessionValue))")
                        MetricRow(title: "Hourly Rate", value: "$75.00")
                        MetricRow(title: "Response Rate", value: "98%")
                    }
                }
                .padding(.horizontal, 16)
            }
            .navigationTitle("Earnings Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DetailCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct MetricRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.blue)
        }
    }
}

// MARK: - Data Models

enum EarningsPeriod: String, CaseIterable {
    case thisWeek = "This Week"
    case thisMonth = "This Month"
    case lastMonth = "Last Month"
    case thisYear = "This Year"
}

struct EarningsData {
    let thisWeek: Double
    let thisMonth: Double
    let lastMonth: Double
    let thisYear: Double
    let totalEarnings: Double
    let sessionCount: Int
    let avgSessionValue: Double
}

struct MockTransaction {
    let id: String
    let studentName: String
    let amount: Double
    let date: Date
    let subject: String
}

struct EarningsAnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        EarningsAnalyticsView()
            .environmentObject(AppViewModel())
    }
}