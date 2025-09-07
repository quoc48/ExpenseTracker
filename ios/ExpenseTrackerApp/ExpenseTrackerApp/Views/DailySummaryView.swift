import SwiftUI

struct DailySummaryView: View {
    @StateObject private var expenseService = ExpenseService.shared
    @State private var todayExpenses: [Expense] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    private let calendar = Calendar.current
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with date
                    headerView
                    
                    // Today's total spending card
                    totalSpendingCard
                    
                    // Category breakdown
                    categoryBreakdownSection
                    
                    // Recent transactions
                    recentTransactionsSection
                }
                .padding()
            }
            .navigationTitle("Tổng Quan Hôm Nay")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await loadTodayExpenses()
            }
        }
        .task {
            await loadTodayExpenses()
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 4) {
            Text(todayDateString)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Báo Cáo Chi Tiêu Hôm Nay")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top)
    }
    
    private var totalSpendingCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tổng Chi Tiêu")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if isLoading {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Đang tải...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text(formatVND(totalSpentToday))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Giao Dịch")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("\(todayExpenses.count)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            
            // Daily spending progress bar (compared to average)
            if !todayExpenses.isEmpty {
                dailyProgressView
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    private var dailyProgressView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("So với trung bình hàng ngày")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(progressText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(progressColor)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(height: 6)
                        .opacity(0.3)
                        .foregroundColor(.gray)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .frame(width: min(CGFloat(progressPercentage) * geometry.size.width / 100, geometry.size.width), height: 6)
                        .foregroundColor(progressColor)
                        .cornerRadius(3)
                        .animation(.easeInOut(duration: 0.5), value: progressPercentage)
                }
            }
            .frame(height: 6)
        }
    }
    
    private var categoryBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Chi Tiêu Theo Danh Mục")
                .font(.headline)
                .foregroundColor(.primary)
            
            if todayExpenses.isEmpty && !isLoading {
                emptyStateView
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(categoryBreakdown, id: \.category) { item in
                        CategorySpendingCard(
                            category: item.category,
                            amount: item.amount,
                            percentage: item.percentage
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Giao Dịch Hôm Nay")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if todayExpenses.count > 3 {
                    NavigationLink("Xem Tất Cả", destination: ExpenseListView())
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            if todayExpenses.isEmpty && !isLoading {
                emptyTransactionsView
            } else {
                ForEach(Array(todayExpenses.prefix(3))) { expense in
                    ExpenseRowView(expense: expense)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.pie")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("Chưa Có Chi Tiêu Hôm Nay")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Hãy thêm chi tiêu đầu tiên của bạn!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 20)
    }
    
    private var emptyTransactionsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "list.bullet")
                .font(.system(size: 30))
                .foregroundColor(.gray)
            
            Text("Chưa Có Giao Dịch")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 16)
    }
    
    // MARK: - Computed Properties
    
    private var todayDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd/MM/yyyy"
        formatter.locale = Locale(identifier: "vi_VN")
        return formatter.string(from: Date())
    }
    
    private var totalSpentToday: Decimal {
        todayExpenses.reduce(0) { $0 + $1.amount }
    }
    
    private var categoryBreakdown: [(category: String, amount: Decimal, percentage: Double)] {
        let total = totalSpentToday
        guard total > 0 else { return [] }
        
        let grouped = Dictionary(grouping: todayExpenses) { $0.categoryName }
        
        return grouped.compactMap { (categoryName, expenses) in
            let categoryTotal = expenses.reduce(0) { $0 + $1.amount }
            let percentage = Double(truncating: categoryTotal as NSNumber) / Double(truncating: total as NSNumber) * 100
            
            return (category: categoryName, amount: categoryTotal, percentage: percentage)
        }
        .sorted { $0.amount > $1.amount }
    }
    
    private var progressPercentage: Double {
        // Simplified: compare to 500,000 VND average daily spending
        let averageDaily: Decimal = 500_000
        let today = totalSpentToday
        
        guard averageDaily > 0 else { return 0 }
        
        let percentage = Double(truncating: today as NSNumber) / Double(truncating: averageDaily as NSNumber) * 100
        return min(percentage, 200) // Cap at 200%
    }
    
    private var progressText: String {
        let percentage = progressPercentage
        if percentage < 80 {
            return "Tiết kiệm (\(String(format: "%.0f", percentage))%)"
        } else if percentage <= 120 {
            return "Bình thường (\(String(format: "%.0f", percentage))%)"
        } else {
            return "Vượt mức (\(String(format: "%.0f", percentage))%)"
        }
    }
    
    private var progressColor: Color {
        let percentage = progressPercentage
        if percentage < 80 {
            return .green
        } else if percentage <= 120 {
            return .blue
        } else {
            return .red
        }
    }
    
    // MARK: - Methods
    
    private func loadTodayExpenses() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let startOfDay = calendar.startOfDay(for: Date())
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? Date()
            
            let expenses = try await expenseService.getExpenses(
                startDate: startOfDay,
                endDate: endOfDay
            )
            
            await MainActor.run {
                self.todayExpenses = expenses
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Không thể tải dữ liệu: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    private func formatVND(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "VND"
        formatter.currencySymbol = "₫"
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = "."
        
        return formatter.string(from: amount as NSNumber) ?? "₫0"
    }
}

// MARK: - Supporting Views

struct CategorySpendingCard: View {
    let category: String
    let amount: Decimal
    let percentage: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(categoryIcon)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(category)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(formatVND(amount))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                
                Spacer()
            }
            
            HStack {
                Text("\(String(format: "%.1f", percentage))%")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
    
    private var categoryIcon: String {
        switch category {
        case "Thực phẩm": return "🍜"
        case "Tạp hoá": return "🛒"
        case "Thời trang": return "👔"
        case "Giáo dục": return "📚"
        case "Tiền nhà": return "🏠"
        case "Giao thông": return "🚌"
        case "Y tế": return "⚕️"
        case "Giải trí": return "🎮"
        case "Mua sắm": return "🛍️"
        case "Cà phê": return "☕"
        case "Du lịch": return "✈️"
        case "Thể thao": return "⚽"
        case "Làm đẹp": return "💄"
        case "Thú cưng": return "🐕"
        default: return "💰"
        }
    }
    
    private func formatVND(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "VND"
        formatter.currencySymbol = "₫"
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = "."
        
        return formatter.string(from: amount as NSNumber) ?? "₫0"
    }
}

struct ExpenseRowView: View {
    let expense: Expense
    
    var body: some View {
        HStack(spacing: 12) {
            Text(categoryIcon)
                .font(.title2)
                .frame(width: 40, height: 40)
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.description)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(expense.categoryName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(formatVND(expense.amount))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(timeString)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var categoryIcon: String {
        switch expense.categoryName {
        case "Thực phẩm": return "🍜"
        case "Tạp hoá": return "🛒"
        case "Thời trang": return "👔"
        case "Giáo dục": return "📚"
        case "Tiền nhà": return "🏠"
        case "Giao thông": return "🚌"
        case "Y tế": return "⚕️"
        case "Giải trí": return "🎮"
        case "Mua sắm": return "🛍️"
        case "Cà phê": return "☕"
        case "Du lịch": return "✈️"
        case "Thể thao": return "⚽"
        case "Làm đẹp": return "💄"
        case "Thú cưng": return "🐕"
        default: return "💰"
        }
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "vi_VN")
        return formatter.string(from: expense.transactionDate)
    }
    
    private func formatVND(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "VND"
        formatter.currencySymbol = "₫"
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = "."
        
        return formatter.string(from: amount as NSNumber) ?? "₫0"
    }
}

#Preview {
    DailySummaryView()
}