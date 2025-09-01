import SwiftUI

struct CategoryAnalyticsView: View {
    @StateObject private var expenseService = ExpenseService.shared
    @StateObject private var categoryService = CategoryService.shared
    @State private var expenses: [Expense] = []
    @State private var categories: [Category] = []
    @State private var selectedPeriod: TimePeriod = .thisMonth
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    enum TimePeriod: String, CaseIterable {
        case thisMonth = "Tháng này"
        case lastMonth = "Tháng trước"
        case last3Months = "3 tháng qua"
        case thisYear = "Năm này"
        
        var dateRange: (start: Date, end: Date) {
            let calendar = Calendar.current
            let now = Date()
            
            switch self {
            case .thisMonth:
                let start = calendar.startOfMonth(for: now)
                let end = calendar.date(byAdding: .month, value: 1, to: start) ?? now
                return (start, end)
            case .lastMonth:
                let start = calendar.date(byAdding: .month, value: -1, to: calendar.startOfMonth(for: now)) ?? now
                let end = calendar.startOfMonth(for: now)
                return (start, end)
            case .last3Months:
                let start = calendar.date(byAdding: .month, value: -3, to: now) ?? now
                let end = now
                return (start, end)
            case .thisYear:
                let start = calendar.date(from: calendar.dateComponents([.year], from: now)) ?? now
                let end = calendar.date(byAdding: .year, value: 1, to: start) ?? now
                return (start, end)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Period selector
                    periodSelectorView
                    
                    // Total spending overview
                    totalSpendingCard
                    
                    // Category pie chart visualization
                    categoryPieChartView
                    
                    // Category ranking list
                    categoryRankingSection
                    
                    // Spending trends by category
                    spendingTrendsSection
                }
                .padding()
            }
            .navigationTitle("Phân Tích Danh Mục")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await loadAnalyticsData()
            }
        }
        .task {
            await loadAnalyticsData()
        }
    }
    
    private var periodSelectorView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TimePeriod.allCases, id: \.rawValue) { period in
                    Button(action: {
                        selectedPeriod = period
                        Task {
                            await loadAnalyticsData()
                        }
                    }) {
                        Text(period.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedPeriod == period ? Color.blue : Color(.systemGray5))
                            .foregroundColor(selectedPeriod == period ? .white : .primary)
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var totalSpendingCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tổng Chi Tiêu")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(selectedPeriod.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Text(formatVND(totalSpending))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    
                    Text("\(expenses.count) giao dịch")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if !categoryBreakdown.isEmpty {
                HStack {
                    Text("Trung bình/danh mục:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(formatVND(averagePerCategory))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    private var categoryPieChartView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Biểu Đồ Chi Tiêu")
                .font(.headline)
                .foregroundColor(.primary)
            
            if categoryBreakdown.isEmpty && !isLoading {
                emptyChartView
            } else {
                ZStack {
                    // Simplified pie chart using circles
                    pieChartVisualization
                    
                    // Center total
                    VStack(spacing: 4) {
                        Text("Tổng")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(formatShortVND(totalSpending))
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                }
                .frame(height: 200)
                
                // Legend
                categoryLegendView
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    private var pieChartVisualization: some View {
        ZStack {
            ForEach(Array(categoryBreakdown.prefix(6).enumerated()), id: \.element.category) { index, item in
                Circle()
                    .trim(from: cumulativePercentages[index] / 100, 
                          to: (cumulativePercentages[index] + item.percentage) / 100)
                    .stroke(categoryColor(for: index), lineWidth: 30)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1), value: item.percentage)
            }
        }
        .frame(width: 150, height: 150)
    }
    
    private var categoryLegendView: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 8) {
            ForEach(Array(categoryBreakdown.prefix(6).enumerated()), id: \.element.category) { index, item in
                HStack(spacing: 8) {
                    Circle()
                        .fill(categoryColor(for: index))
                        .frame(width: 12, height: 12)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.category)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Text("\(String(format: "%.1f", item.percentage))%")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
        }
    }
    
    private var emptyChartView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.pie")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("Chưa Có Dữ Liệu")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Thêm chi tiêu để xem phân tích")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(height: 200)
    }
    
    private var categoryRankingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Xếp Hạng Danh Mục")
                .font(.headline)
                .foregroundColor(.primary)
            
            if categoryBreakdown.isEmpty && !isLoading {
                Text("Chưa có dữ liệu để hiển thị")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(Array(categoryBreakdown.enumerated()), id: \.element.category) { index, item in
                        CategoryRankingRow(
                            rank: index + 1,
                            category: item.category,
                            amount: item.amount,
                            percentage: item.percentage,
                            transactionCount: item.transactionCount,
                            trend: item.trend
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
    
    private var spendingTrendsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Xu Hướng Chi Tiêu")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                TrendRow(
                    title: "Danh mục chi nhiều nhất",
                    value: topCategory?.category ?? "N/A",
                    amount: topCategory?.amount ?? 0
                )
                
                TrendRow(
                    title: "Danh mục giao dịch nhiều nhất",
                    value: mostFrequentCategory?.category ?? "N/A",
                    amount: mostFrequentCategory?.amount ?? 0
                )
                
                TrendRow(
                    title: "Trung bình/giao dịch",
                    value: formatVND(averageTransactionAmount),
                    amount: nil
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Computed Properties
    
    private var totalSpending: Decimal {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    private var categoryBreakdown: [(category: String, amount: Decimal, percentage: Double, transactionCount: Int, trend: String)] {
        let grouped = Dictionary(grouping: expenses) { $0.categoryName }
        let total = totalSpending
        
        guard total > 0 else { return [] }
        
        return grouped.compactMap { (categoryName, expenses) in
            let categoryTotal = expenses.reduce(0) { $0 + $1.amount }
            let percentage = Double(truncating: categoryTotal as NSNumber) / Double(truncating: total as NSNumber) * 100
            let transactionCount = expenses.count
            
            // Simple trend calculation (placeholder)
            let trend = percentage > 20 ? "↗️" : percentage > 10 ? "→" : "↘️"
            
            return (
                category: categoryName,
                amount: categoryTotal,
                percentage: percentage,
                transactionCount: transactionCount,
                trend: trend
            )
        }
        .sorted { $0.amount > $1.amount }
    }
    
    private var cumulativePercentages: [Double] {
        var cumulative: [Double] = []
        var sum: Double = 0
        
        for item in categoryBreakdown.prefix(6) {
            cumulative.append(sum)
            sum += item.percentage
        }
        
        return cumulative
    }
    
    private var averagePerCategory: Decimal {
        let categoryCount = categoryBreakdown.count
        guard categoryCount > 0 else { return 0 }
        return totalSpending / Decimal(categoryCount)
    }
    
    private var topCategory: (category: String, amount: Decimal)? {
        categoryBreakdown.first.map { (category: $0.category, amount: $0.amount) }
    }
    
    private var mostFrequentCategory: (category: String, amount: Decimal)? {
        categoryBreakdown.max { $0.transactionCount < $1.transactionCount }
            .map { (category: $0.category, amount: $0.amount) }
    }
    
    private var averageTransactionAmount: Decimal {
        guard !expenses.isEmpty else { return 0 }
        return totalSpending / Decimal(expenses.count)
    }
    
    // MARK: - Methods
    
    private func loadAnalyticsData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let dateRange = selectedPeriod.dateRange
            
            async let expensesTask = expenseService.getExpenses(
                startDate: dateRange.start,
                endDate: dateRange.end
            )
            async let categoriesTask = categoryService.getCategories()
            
            let (loadedExpenses, loadedCategories) = try await (expensesTask, categoriesTask)
            
            await MainActor.run {
                self.expenses = loadedExpenses
                self.categories = loadedCategories
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Không thể tải dữ liệu: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    private func categoryColor(for index: Int) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .red, .pink]
        return colors[index % colors.count]
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
    
    private func formatShortVND(_ amount: Decimal) -> String {
        let value = Double(truncating: amount as NSNumber)
        
        if value >= 1_000_000 {
            return String(format: "₫%.1fM", value / 1_000_000)
        } else if value >= 1_000 {
            return String(format: "₫%.1fK", value / 1_000)
        } else {
            return formatVND(amount)
        }
    }
}

// MARK: - Supporting Views

struct CategoryRankingRow: View {
    let rank: Int
    let category: String
    let amount: Decimal
    let percentage: Double
    let transactionCount: Int
    let trend: String
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank
            Text("\(rank)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(rankColor)
                .frame(width: 30)
            
            // Category info
            HStack(spacing: 8) {
                Text(categoryIcon)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(category)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text("\(transactionCount) giao dịch")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Amount and trend
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    Text(formatVND(amount))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(trend)
                        .font(.caption)
                }
                
                Text("\(String(format: "%.1f", percentage))%")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .secondary
        }
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

struct TrendRow: View {
    let title: String
    let value: String
    let amount: Decimal?
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                if let amount = amount {
                    Text(formatVND(amount))
                        .font(.caption)
                        .foregroundColor(.blue)
                }
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

extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}

#Preview {
    CategoryAnalyticsView()
}