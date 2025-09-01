import SwiftUI

struct ContentView: View {
    @StateObject private var supabaseService = SupabaseService.shared
    
    var body: some View {
        Group {
            if supabaseService.isAuthenticated {
                MainTabView()
            } else {
                AuthenticationView()
            }
        }
        .task {
            await supabaseService.checkAuthState()
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardExpenseView()
                .tabItem {
                    Image(systemName: "creditcard")
                    Text("Chi Tiêu")
                }
            
            ReportsTabView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Báo Cáo")
                }
            
            TestConnectionView()
                .tabItem {
                    Image(systemName: "network")
                    Text("Test")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Cài Đặt")
                }
        }
    }
}

struct ReportsTabView: View {
    @State private var selectedReportView: ReportViewType = .dashboard
    
    enum ReportViewType: String, CaseIterable {
        case dashboard = "Tổng Quan"
        case daily = "Hôm Nay"
        case budget = "Ngân Sách"
        case analytics = "Phân Tích"
        
        var icon: String {
            switch self {
            case .dashboard: return "chart.bar.fill"
            case .daily: return "calendar"
            case .budget: return "dollarsign.circle"
            case .analytics: return "chart.pie"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Report type selector
                reportTypeSelector
                
                // Content based on selected report
                Group {
                    switch selectedReportView {
                    case .dashboard:
                        ReportsDashboardView()
                    case .daily:
                        DailySummaryView()
                    case .budget:
                        BudgetComparisonView()
                    case .analytics:
                        CategoryAnalyticsView()
                    }
                }
                .animation(.easeInOut, value: selectedReportView)
            }
            .navigationTitle("Báo Cáo")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var reportTypeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(ReportViewType.allCases, id: \.rawValue) { reportType in
                    ReportTypeButton(
                        reportType: reportType,
                        isSelected: selectedReportView == reportType,
                        action: { selectedReportView = reportType }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
}

struct ReportTypeButton: View {
    let reportType: ReportsTabView.ReportViewType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: reportType.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .blue)
                
                Text(reportType.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(minWidth: 70)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

struct SettingsView: View {
    @StateObject private var supabaseService = SupabaseService.shared
    
    var body: some View {
        NavigationStack {
            List {
                Section("Tài khoản") {
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(supabaseService.currentUser?.email ?? "N/A")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("User ID")
                        Spacer()
                        Text(supabaseService.userId?.uuidString.prefix(8) ?? "N/A")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                
                Section {
                    Button("Đăng xuất") {
                        Task {
                            try await supabaseService.signOut()
                        }
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Cài Đặt")
        }
    }
}

#Preview {
    ContentView()
}