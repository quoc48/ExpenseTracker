import SwiftUI

struct BudgetComparisonView: View {
    @StateObject private var expenseService = ExpenseService.shared
    @State private var monthlyExpenses: [Expense] = []
    @State private var monthlyBudget: Decimal = 10_000_000 // Default 10M VND
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showBudgetSetup = false
    @State private var selectedMonth = Date()
    
    private let calendar = Calendar.current
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Month selector
                    monthSelectorView
                    
                    // Budget overview card
                    budgetOverviewCard
                    
                    // Progress visualization
                    budgetProgressView
                    
                    // Category budget breakdown
                    categoryBudgetSection
                    
                    // Spending trend this month
                    spendingTrendSection
                }
                .padding()
            }
            .navigationTitle("Ngân Sách")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cài Đặt") {
                        showBudgetSetup = true
                    }
                }
            }
            .sheet(isPresented: $showBudgetSetup) {
                BudgetSetupView(monthlyBudget: $monthlyBudget)
            }
            .refreshable {
                await loadMonthlyData()
            }
        }
        .task {
            await loadMonthlyData()
        }
    }
    
    private var monthSelectorView: some View {
        HStack {
            Button(action: { changeMonth(-1) }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text(monthYearString)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Ngân Sách Tháng")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: { changeMonth(1) }) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal)
    }
    
    private var budgetOverviewCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ngân Sách Tháng")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(formatVND(monthlyBudget))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text("Đã Chi")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Text(formatVND(totalSpentThisMonth))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(spentColor)
                    }
                }
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Còn Lại")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(formatVND(remainingBudget))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(remainingBudget >= 0 ? .green : .red)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Tiến Độ")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("\(String(format: "%.1f", budgetUsedPercentage))%")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(progressColor)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    private var budgetProgressView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tiến Độ Ngân Sách")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(height: 12)
                            .opacity(0.3)
                            .foregroundColor(.gray)
                            .cornerRadius(6)
                        
                        Rectangle()
                            .frame(width: min(CGFloat(budgetUsedPercentage) * geometry.size.width / 100, geometry.size.width), height: 12)
                            .foregroundColor(progressColor)
                            .cornerRadius(6)
                            .animation(.easeInOut(duration: 0.5), value: budgetUsedPercentage)
                    }
                }
                .frame(height: 12)
                
                HStack {
                    Text(budgetStatusText)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(progressColor)
                    
                    Spacer()
                    
                    Text("Mục tiêu: \(formatVND(monthlyBudget))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Daily budget tracking
            dailyBudgetView
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    private var dailyBudgetView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ngân Sách Hàng Ngày")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Khuyến nghị")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(formatVND(dailyBudgetRecommendation))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Còn lại \(daysLeftInMonth) ngày")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(formatVND(dailyBudgetRemaining))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(dailyBudgetRemaining >= 0 ? .green : .red)
                }
            }
            .padding(.top, 4)
        }
    }
    
    private var categoryBudgetSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Chi Tiêu Theo Danh Mục")
                .font(.headline)
                .foregroundColor(.primary)
            
            if monthlyExpenses.isEmpty && !isLoading {
                Text("Chưa có chi tiêu nào trong tháng này")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(categorySpending, id: \.category) { item in
                        CategoryBudgetRow(
                            category: item.category,
                            spent: item.amount,
                            budget: item.budget,
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
    
    private var spendingTrendSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Xu Hướng Chi Tiêu")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                HStack {
                    Text("Tuần này")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(formatVND(weeklySpending))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                HStack {
                    Text("Trung bình/ngày")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(formatVND(dailyAverageSpending))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                HStack {
                    Text("Dự kiến cuối tháng")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(formatVND(projectedMonthlySpending))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(projectedMonthlySpending > monthlyBudget ? .red : .green)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Computed Properties
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "vi_VN")
        return formatter.string(from: selectedMonth).capitalized
    }
    
    private var totalSpentThisMonth: Decimal {
        monthlyExpenses.reduce(0) { $0 + $1.amount }
    }
    
    private var remainingBudget: Decimal {
        monthlyBudget - totalSpentThisMonth
    }
    
    private var budgetUsedPercentage: Double {
        guard monthlyBudget > 0 else { return 0 }
        return Double(truncating: totalSpentThisMonth as NSNumber) / Double(truncating: monthlyBudget as NSNumber) * 100
    }
    
    private var spentColor: Color {
        if budgetUsedPercentage > 100 {
            return .red
        } else if budgetUsedPercentage > 80 {
            return .orange
        } else {
            return .primary
        }
    }
    
    private var progressColor: Color {
        if budgetUsedPercentage <= 50 {
            return .green
        } else if budgetUsedPercentage <= 80 {
            return .blue
        } else if budgetUsedPercentage <= 100 {
            return .orange
        } else {
            return .red
        }
    }
    
    private var budgetStatusText: String {
        if budgetUsedPercentage <= 50 {
            return "Tốt - Trong tầm kiểm soát"
        } else if budgetUsedPercentage <= 80 {
            return "Bình thường - Hãy chú ý"
        } else if budgetUsedPercentage <= 100 {
            return "Cảnh báo - Gần hết ngân sách"
        } else {
            return "Vượt ngân sách - Cần tiết kiệm"
        }
    }
    
    private var daysLeftInMonth: Int {
        let endOfMonth = calendar.dateInterval(of: .month, for: selectedMonth)?.end ?? selectedMonth
        let today = Date()
        return calendar.dateComponents([.day], from: today, to: endOfMonth).day ?? 0
    }
    
    private var dailyBudgetRecommendation: Decimal {
        let daysInMonth = calendar.range(of: .day, in: .month, for: selectedMonth)?.count ?? 30
        return monthlyBudget / Decimal(daysInMonth)
    }
    
    private var dailyBudgetRemaining: Decimal {
        let daysLeft = max(daysLeftInMonth, 1)
        return remainingBudget / Decimal(daysLeft)
    }
    
    private var weeklySpending: Decimal {
        let oneWeekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
        let thisWeekExpenses = monthlyExpenses.filter { $0.transactionDate >= oneWeekAgo }
        return thisWeekExpenses.reduce(0) { $0 + $1.amount }
    }
    
    private var dailyAverageSpending: Decimal {
        let daysElapsed = calendar.dateComponents([.day], from: calendar.startOfMonth(for: selectedMonth), to: Date()).day ?? 1
        let days = max(daysElapsed, 1)
        return totalSpentThisMonth / Decimal(days)
    }
    
    private var projectedMonthlySpending: Decimal {
        let daysInMonth = calendar.range(of: .day, in: .month, for: selectedMonth)?.count ?? 30
        return dailyAverageSpending * Decimal(daysInMonth)
    }
    
    private var categorySpending: [(category: String, amount: Decimal, budget: Decimal, percentage: Double)] {
        let grouped = Dictionary(grouping: monthlyExpenses) { $0.categoryName }
        
        return grouped.compactMap { (categoryName, expenses) in
            let categoryTotal = expenses.reduce(0) { $0 + $1.amount }
            let categoryBudget = monthlyBudget * 0.1 // Simplified: 10% per category
            let percentage = Double(truncating: categoryTotal as NSNumber) / Double(truncating: categoryBudget as NSNumber) * 100
            
            return (category: categoryName, amount: categoryTotal, budget: categoryBudget, percentage: percentage)
        }
        .sorted { $0.amount > $1.amount }
    }
    
    // MARK: - Methods
    
    private func changeMonth(_ direction: Int) {
        if let newDate = calendar.date(byAdding: .month, value: direction, to: selectedMonth) {
            selectedMonth = newDate
            Task {
                await loadMonthlyData()
            }
        }
    }
    
    private func loadMonthlyData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let startOfMonth = calendar.startOfMonth(for: selectedMonth)
            let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) ?? selectedMonth
            
            let expenses = try await expenseService.getExpenses(
                startDate: startOfMonth,
                endDate: endOfMonth
            )
            
            await MainActor.run {
                self.monthlyExpenses = expenses
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

struct CategoryBudgetRow: View {
    let category: String
    let spent: Decimal
    let budget: Decimal
    let percentage: Double
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(categoryIcon)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(category)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text("Ngân sách: \(formatVND(budget))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(formatVND(spent))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("\(String(format: "%.1f", percentage))%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(percentageColor)
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(height: 6)
                        .opacity(0.3)
                        .foregroundColor(.gray)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .frame(width: min(CGFloat(percentage) * geometry.size.width / 100, geometry.size.width), height: 6)
                        .foregroundColor(percentageColor)
                        .cornerRadius(3)
                        .animation(.easeInOut(duration: 0.5), value: percentage)
                }
            }
            .frame(height: 6)
        }
        .padding(.vertical, 4)
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
    
    private var percentageColor: Color {
        if percentage <= 70 {
            return .green
        } else if percentage <= 90 {
            return .orange
        } else {
            return .red
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

struct BudgetSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var monthlyBudget: Decimal
    @State private var budgetInput: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Cài Đặt Ngân Sách Tháng")) {
                    HStack {
                        Text("₫")
                            .foregroundColor(.secondary)
                        
                        TextField("Nhập số tiền", text: $budgetInput)
                            .keyboardType(.numberPad)
                            .onAppear {
                                budgetInput = formatNumber(monthlyBudget)
                            }
                    }
                    
                    Text("Ví dụ: 10.000.000 (10 triệu VND)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Gợi Ý Ngân Sách")) {
                    BudgetSuggestionRow(title: "Sinh viên", amount: 3_000_000)
                    BudgetSuggestionRow(title: "Người đi làm", amount: 8_000_000)
                    BudgetSuggestionRow(title: "Gia đình nhỏ", amount: 15_000_000)
                    BudgetSuggestionRow(title: "Gia đình lớn", amount: 25_000_000)
                }
            }
            .navigationTitle("Ngân Sách")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Hủy") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Lưu") {
                        saveBudget()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveBudget() {
        let cleanedInput = budgetInput.replacingOccurrences(of: ".", with: "")
        if let amount = Decimal(string: cleanedInput) {
            monthlyBudget = amount
        }
    }
    
    private func formatNumber(_ number: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return formatter.string(from: number as NSNumber) ?? "0"
    }
}

struct BudgetSuggestionRow: View {
    let title: String
    let amount: Decimal
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(formatVND(amount))
                .font(.subheadline)
                .foregroundColor(.blue)
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

// Calendar extension
extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}

#Preview {
    BudgetComparisonView()
}