import SwiftUI

struct ReportsDashboardView: View {
    @StateObject private var expenseService = ExpenseService.shared
    @State private var startDate = Calendar.current.dateInterval(of: .month, for: Date())?.start ?? Date()
    @State private var endDate = Date()
    @State private var expenses: [Expense] = []
    @State private var isLoading = true
    @State private var selectedTab: ReportTab = .overview
    
    enum ReportTab: String, CaseIterable {
        case overview = "Tổng Quan"
        case trends = "Xu Hướng"
        case categories = "Danh Mục"
        case budget = "Ngân Sách"
        
        var icon: String {
            switch self {
            case .overview: return "chart.bar.fill"
            case .trends: return "chart.line.uptrend.xyaxis"
            case .categories: return "chart.pie.fill"
            case .budget: return "dollarsign.circle.fill"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with date range
                headerSection
                
                // Tab selector
                tabSelector
                
                // Content based on selected tab
                TabView(selection: $selectedTab) {
                    overviewContent
                        .tag(ReportTab.overview)
                    
                    trendsContent
                        .tag(ReportTab.trends)
                    
                    categoriesContent
                        .tag(ReportTab.categories)
                    
                    budgetContent
                        .tag(ReportTab.budget)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Báo Cáo Chi Tiêu")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Xuất PDF", action: exportToPDF)
                        Button("Xuất Excel", action: exportToExcel)
                        Button("Chia sẻ", action: shareReport)
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .refreshable {
                await loadReportData()
            }
        }
        .task {
            await loadReportData()
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            // Date range filter
            DateRangeFilter(startDate: $startDate, endDate: $endDate)
                .onChange(of: startDate) { _, _ in
                    Task { await loadReportData() }
                }
                .onChange(of: endDate) { _, _ in
                    Task { await loadReportData() }
                }
            
            // Quick stats overview
            if !isLoading {
                HStack(spacing: 20) {
                    QuickStatCard(
                        title: "Tổng Chi",
                        value: formatVND(totalSpending),
                        icon: "creditcard.fill",
                        color: .blue
                    )
                    
                    QuickStatCard(
                        title: "Giao Dịch",
                        value: "\(expenses.count)",
                        icon: "list.bullet",
                        color: .green
                    )
                    
                    QuickStatCard(
                        title: "TB/Ngày",
                        value: formatShortVND(dailyAverage),
                        icon: "calendar",
                        color: .orange
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    // MARK: - Tab Selector
    
    private var tabSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(ReportTab.allCases, id: \.rawValue) { tab in
                    TabButton(
                        tab: tab,
                        isSelected: selectedTab == tab,
                        action: { selectedTab = tab }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
    
    // MARK: - Content Views
    
    private var overviewContent: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                if isLoading {
                    loadingView
                } else if expenses.isEmpty {
                    emptyStateView
                } else {
                    // Summary cards
                    summaryCardsSection
                    
                    // Recent transactions
                    recentTransactionsSection
                    
                    // Top categories
                    topCategoriesSection
                }
            }
            .padding()
        }
    }
    
    private var trendsContent: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                if isLoading {
                    loadingView
                } else {
                    // Spending trend chart placeholder
                    trendChartSection
                    
                    // Weekly breakdown
                    weeklyBreakdownSection
                    
                    // Monthly comparison
                    monthlyComparisonSection
                }
            }
            .padding()
        }
    }
    
    private var categoriesContent: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                if isLoading {
                    loadingView
                } else {
                    // Category pie chart
                    categoryPieChartSection
                    
                    // Category ranking
                    categoryRankingSection
                }
            }
            .padding()
        }
    }
    
    private var budgetContent: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                if isLoading {
                    loadingView
                } else {
                    // Budget overview
                    budgetOverviewSection
                    
                    // Budget progress
                    budgetProgressSection
                    
                    // Spending alerts
                    spendingAlertsSection
                }
            }
            .padding()
        }
    }
    
    // MARK: - Content Sections
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Đang tải báo cáo...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Chưa Có Dữ Liệu")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Thêm chi tiêu để xem báo cáo chi tiết")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Thêm Chi Tiêu Đầu Tiên") {
                // Navigate to add expense
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.top, 50)
    }
    
    private var summaryCardsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            SummaryCard(
                title: "Chi Tiêu Cao Nhất",
                value: formatVND(maxExpense),
                subtitle: maxExpenseCategory,
                color: .red
            )
            
            SummaryCard(
                title: "Chi Tiêu Thường Xuyên",
                value: formatVND(avgExpense),
                subtitle: "Trung bình/giao dịch",
                color: .blue
            )
            
            SummaryCard(
                title: "Danh Mục Nhiều Nhất",
                value: topCategory?.category ?? "N/A",
                subtitle: formatShortVND(topCategory?.amount ?? 0),
                color: .green
            )
            
            SummaryCard(
                title: "Xu Hướng",
                value: trendIndicator,
                subtitle: "So với kỳ trước",
                color: trendColor
            )
        }
    }
    
    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Giao Dịch Gần Đây")
                    .font(.headline)
                
                Spacer()
                
                NavigationLink("Xem Tất Cả") {
                    EnhancedExpenseListView()
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(Array(expenses.prefix(5))) { expense in
                    ExpenseRowView(expense: expense)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    private var topCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Top Danh Mục Chi Tiêu")
                .font(.headline)
            
            LazyVStack(spacing: 12) {
                ForEach(Array(categoryBreakdown.prefix(5).enumerated()), id: \.element.category) { index, item in
                    CategoryRankingRow(
                        rank: index + 1,
                        category: item.category,
                        amount: item.amount,
                        percentage: item.percentage,
                        transactionCount: item.transactionCount,
                        trend: "→"
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    private var trendChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Xu Hướng Chi Tiêu")
                .font(.headline)
            
            // Placeholder for line chart
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .frame(height: 200)
                
                VStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                    
                    Text("Biểu Đồ Xu Hướng")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("Sẽ hiển thị xu hướng chi tiêu theo thời gian")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    private var weeklyBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Phân Tích Theo Tuần")
                .font(.headline)
            
            // Weekly spending breakdown
            LazyVStack(spacing: 12) {
                ForEach(weeklyBreakdown, id: \.week) { week in
                    HStack {
                        Text(week.week)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(formatVND(week.amount))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text("(\(week.transactionCount))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    private var monthlyComparisonSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("So Sánh Tháng")
                .font(.headline)
            
            VStack(spacing: 12) {
                ComparisonRow(
                    title: "Tháng này",
                    amount: totalSpending,
                    change: nil
                )
                
                ComparisonRow(
                    title: "Tháng trước",
                    amount: lastMonthSpending,
                    change: monthlyChange
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    private var categoryPieChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Phân Bố Chi Tiêu")
                .font(.headline)
            
            // Simplified pie chart visualization
            ZStack {
                ForEach(Array(categoryBreakdown.prefix(6).enumerated()), id: \.element.category) { index, item in
                    Circle()
                        .trim(from: cumulativePercentages[index] / 100, 
                              to: (cumulativePercentages[index] + item.percentage) / 100)
                        .stroke(categoryColor(for: index), lineWidth: 25)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1), value: item.percentage)
                }
                
                VStack(spacing: 4) {
                    Text("Tổng")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(formatShortVND(totalSpending))
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
            .frame(height: 200)
            
            // Category legend
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
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    private var categoryRankingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Xếp Hạng Danh Mục")
                .font(.headline)
            
            LazyVStack(spacing: 12) {
                ForEach(Array(categoryBreakdown.enumerated()), id: \.element.category) { index, item in
                    CategoryRankingRow(
                        rank: index + 1,
                        category: item.category,
                        amount: item.amount,
                        percentage: item.percentage,
                        transactionCount: item.transactionCount,
                        trend: "→"
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    private var budgetOverviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tổng Quan Ngân Sách")
                .font(.headline)
            
            // Budget cards
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                BudgetCard(
                    title: "Ngân Sách Tháng",
                    amount: monthlyBudget,
                    color: .blue
                )
                
                BudgetCard(
                    title: "Đã Sử Dụng",
                    amount: totalSpending,
                    color: budgetUsageColor
                )
                
                BudgetCard(
                    title: "Còn Lại",
                    amount: remainingBudget,
                    color: remainingBudget >= 0 ? .green : .red
                )
                
                BudgetCard(
                    title: "Tiến Độ",
                    amount: 0,
                    color: .orange,
                    subtitle: "\(String(format: "%.1f", budgetUsagePercentage))%"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    private var budgetProgressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tiến Độ Ngân Sách")
                .font(.headline)
            
            VStack(spacing: 12) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(height: 12)
                            .opacity(0.3)
                            .foregroundColor(.gray)
                            .cornerRadius(6)
                        
                        Rectangle()
                            .frame(width: min(CGFloat(budgetUsagePercentage) * geometry.size.width / 100, geometry.size.width), height: 12)
                            .foregroundColor(budgetProgressColor)
                            .cornerRadius(6)
                            .animation(.easeInOut(duration: 0.5), value: budgetUsagePercentage)
                    }
                }
                .frame(height: 12)
                
                HStack {
                    Text(budgetStatusText)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(budgetProgressColor)
                    
                    Spacer()
                    
                    Text("\(String(format: "%.1f", budgetUsagePercentage))% sử dụng")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    private var spendingAlertsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Cảnh Báo Chi Tiêu")
                .font(.headline)
            
            LazyVStack(spacing: 12) {
                ForEach(spendingAlerts, id: \.id) { alert in
                    AlertRow(alert: alert)
                }
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
    
    private var dailyAverage: Decimal {
        let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 1
        return totalSpending / Decimal(max(days, 1))
    }
    
    private var maxExpense: Decimal {
        expenses.max { $0.amount < $1.amount }?.amount ?? 0
    }
    
    private var avgExpense: Decimal {
        guard !expenses.isEmpty else { return 0 }
        return totalSpending / Decimal(expenses.count)
    }
    
    private var maxExpenseCategory: String {
        expenses.max { $0.amount < $1.amount }?.categoryName ?? "N/A"
    }
    
    private var categoryBreakdown: [(category: String, amount: Decimal, percentage: Double, transactionCount: Int)] {
        let grouped = Dictionary(grouping: expenses) { $0.categoryName }
        let total = totalSpending
        
        guard total > 0 else { return [] }
        
        return grouped.compactMap { (categoryName, expenses) in
            let categoryTotal = expenses.reduce(0) { $0 + $1.amount }
            let percentage = Double(truncating: categoryTotal as NSNumber) / Double(truncating: total as NSNumber) * 100
            
            return (
                category: categoryName,
                amount: categoryTotal,
                percentage: percentage,
                transactionCount: expenses.count
            )
        }
        .sorted { $0.amount > $1.amount }
    }
    
    private var topCategory: (category: String, amount: Decimal)? {
        categoryBreakdown.first.map { (category: $0.category, amount: $0.amount) }
    }
    
    private var trendIndicator: String {
        let change = monthlyChange
        if change > 10 {
            return "↗️ Tăng"
        } else if change < -10 {
            return "↘️ Giảm"
        } else {
            return "→ Ổn định"
        }
    }
    
    private var trendColor: Color {
        let change = monthlyChange
        if change > 10 {
            return .red
        } else if change < -10 {
            return .green
        } else {
            return .blue
        }
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
    
    private var weeklyBreakdown: [(week: String, amount: Decimal, transactionCount: Int)] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: expenses) { expense in
            calendar.dateInterval(of: .weekOfYear, for: expense.transactionDate)?.start ?? expense.transactionDate
        }
        
        return grouped.compactMap { (weekStart, expenses) in
            let weekName = "Tuần \(calendar.component(.weekOfYear, from: weekStart))"
            let amount = expenses.reduce(0) { $0 + $1.amount }
            return (week: weekName, amount: amount, transactionCount: expenses.count)
        }
        .sorted { $0.week < $1.week }
    }
    
    private var lastMonthSpending: Decimal {
        // Placeholder - would need to fetch last month's data
        totalSpending * 0.85 // Simulate 85% of current spending
    }
    
    private var monthlyChange: Double {
        guard lastMonthSpending > 0 else { return 0 }
        let change = (Double(truncating: totalSpending as NSNumber) - Double(truncating: lastMonthSpending as NSNumber)) / Double(truncating: lastMonthSpending as NSNumber) * 100
        return change
    }
    
    private var monthlyBudget: Decimal = 10_000_000 // Default 10M VND
    
    private var remainingBudget: Decimal {
        monthlyBudget - totalSpending
    }
    
    private var budgetUsagePercentage: Double {
        guard monthlyBudget > 0 else { return 0 }
        return Double(truncating: totalSpending as NSNumber) / Double(truncating: monthlyBudget as NSNumber) * 100
    }
    
    private var budgetUsageColor: Color {
        if budgetUsagePercentage > 100 {
            return .red
        } else if budgetUsagePercentage > 80 {
            return .orange
        } else {
            return .green
        }
    }
    
    private var budgetProgressColor: Color {
        if budgetUsagePercentage <= 50 {
            return .green
        } else if budgetUsagePercentage <= 80 {
            return .blue
        } else if budgetUsagePercentage <= 100 {
            return .orange
        } else {
            return .red
        }
    }
    
    private var budgetStatusText: String {
        if budgetUsagePercentage <= 50 {
            return "Tốt - Trong tầm kiểm soát"
        } else if budgetUsagePercentage <= 80 {
            return "Bình thường"
        } else if budgetUsagePercentage <= 100 {
            return "Cảnh báo - Gần hết ngân sách"
        } else {
            return "Vượt ngân sách"
        }
    }
    
    private var spendingAlerts: [SpendingAlert] {
        var alerts: [SpendingAlert] = []
        
        if budgetUsagePercentage > 100 {
            alerts.append(SpendingAlert(
                id: "budget_exceeded",
                type: .critical,
                title: "Vượt Ngân Sách",
                message: "Bạn đã chi vượt ngân sách \(String(format: "%.1f", budgetUsagePercentage - 100))%"
            ))
        } else if budgetUsagePercentage > 90 {
            alerts.append(SpendingAlert(
                id: "budget_warning",
                type: .warning,
                title: "Gần Hết Ngân Sách",
                message: "Còn lại \(formatVND(remainingBudget))"
            ))
        }
        
        // Check for high spending days
        let todaySpending = expenses.filter { Calendar.current.isDateInToday($0.transactionDate) }
            .reduce(0) { $0 + $1.amount }
        
        if todaySpending > dailyAverage * 2 {
            alerts.append(SpendingAlert(
                id: "high_daily_spending",
                type: .info,
                title: "Chi Tiêu Cao Hôm Nay",
                message: "Hôm nay bạn chi \(formatVND(todaySpending)), cao hơn trung bình"
            ))
        }
        
        return alerts
    }
    
    // MARK: - Methods
    
    private func loadReportData() async {
        isLoading = true
        
        do {
            let loadedExpenses = try await expenseService.getExpenses(
                startDate: startDate,
                endDate: endDate
            )
            
            await MainActor.run {
                self.expenses = loadedExpenses
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
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
    
    private func exportToPDF() {
        // TODO: Implement PDF export
    }
    
    private func exportToExcel() {
        // TODO: Implement Excel export
    }
    
    private func shareReport() {
        // TODO: Implement share functionality
    }
}

// MARK: - Supporting Views and Models

struct TabButton: View {
    let tab: ReportsDashboardView.ReportTab
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.title2)
                
                Text(tab.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .blue : .secondary)
            .frame(minWidth: 60)
            .padding(.vertical, 8)
        }
    }
}

struct QuickStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .lineLimit(1)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
                .lineLimit(2)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct ComparisonRow: View {
    let title: String
    let amount: Decimal
    let change: Double?
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatVND(amount))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                if let change = change {
                    HStack(spacing: 4) {
                        Image(systemName: change >= 0 ? "arrow.up" : "arrow.down")
                            .font(.caption2)
                        
                        Text("\(String(format: "%.1f", abs(change)))%")
                            .font(.caption2)
                    }
                    .foregroundColor(change >= 0 ? .red : .green)
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

struct BudgetCard: View {
    let title: String
    let amount: Decimal
    let color: Color
    let subtitle: String?
    
    init(title: String, amount: Decimal, color: Color, subtitle: String? = nil) {
        self.title = title
        self.amount = amount
        self.color = color
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            } else {
                Text(formatVND(amount))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
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

struct SpendingAlert {
    let id: String
    let type: AlertType
    let title: String
    let message: String
    
    enum AlertType {
        case info, warning, critical
        
        var color: Color {
            switch self {
            case .info: return .blue
            case .warning: return .orange
            case .critical: return .red
            }
        }
        
        var icon: String {
            switch self {
            case .info: return "info.circle"
            case .warning: return "exclamationmark.triangle"
            case .critical: return "exclamationmark.octagon"
            }
        }
    }
}

struct AlertRow: View {
    let alert: SpendingAlert
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: alert.type.icon)
                .font(.title2)
                .foregroundColor(alert.type.color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(alert.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(alert.message)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(alert.type.color.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    ReportsDashboardView()
}