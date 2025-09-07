import SwiftUI

struct DashboardExpenseView: View {
    @StateObject private var expenseService = ExpenseService.shared
    @StateObject private var categoryService = CategoryService.shared
    @StateObject private var supabaseService = SupabaseService.shared
    
    @State private var monthlyTotal: Decimal = 0
    @State private var todayTotal: Decimal = 0
    @State private var topCategory: (name: String, icon: String, amount: Decimal)?
    @State private var recentTransactions: [Expense] = []
    @State private var showingAddExpense = false
    @State private var showingBudgetDetail = false
    @State private var showingDailyStatsDetail = false
    @State private var isLoading = true
    
    private let calendar = Calendar.current
    private let currentMonth = Calendar.current.component(.month, from: Date())
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 1. Header Section
                    headerSection
                    
                    // 2. Quick Stats Section (Today)
                    todayStatsSection
                    
                    // 3. Category Title
                    categoryTitleSection
                    
                    // 4. Category Card
                    categoryCardSection
                    
                    // 5. Recent Transactions Section
                    recentTransactionsSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .background(Color(hex: "F5F6F7"))
            .navigationTitle("Chi Tiêu")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddExpense = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .font(.title2)
                            .frame(width: 44, height: 44)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "2F51FF"), Color(hex: "0E33F3")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(Circle())
                    }
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView()
            }
            .sheet(isPresented: $showingBudgetDetail) {
                BudgetDetailView()
            }
            .sheet(isPresented: $showingDailyStatsDetail) {
                DailyStatsDetailView()
            }
            .task {
                await loadDashboardData()
            }
            .refreshable {
                await loadDashboardData()
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 0) {
            // Top dark section with month and total
            VStack(spacing: 12) {
                HStack {
                    Text("Tháng \(currentMonth)")
                        .font(.custom("SF Pro Text", size: 18))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { 
                        showingBudgetDetail = true 
                    }) {
                        HStack(spacing: 4) {
                            Text("Tháng trước")
                                .font(.custom("SF Pro Text", size: 14))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                
                HStack {
                    Text(formatVND(monthlyTotal))
                        .font(.custom("SF Pro Text", size: 32))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                
                HStack {
                    Text("So với ngân sách")
                        .font(.custom("SF Pro Text", size: 14))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    let monthlyBudget: Decimal = 10_000_000 // ₫10M monthly budget
                    let percentage = min(Double(monthlyTotal / monthlyBudget) * 100, 100)
                    Text("\(Int(percentage))%")
                        .font(.custom("SF Pro Text", size: 14))
                        .foregroundColor(.white)
                }
            }
            .padding(16)
            .background(Color(hex: "2C2C2C"))
            
            // Progress bar section
            let monthlyBudget: Decimal = 10_000_000
            let progressPercentage = min(Double(monthlyTotal / monthlyBudget), 1.0)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(height: 8)
                        .foregroundColor(.white.opacity(0.2))
                        .cornerRadius(4)
                    
                    Rectangle()
                        .frame(width: geometry.size.width * progressPercentage, height: 8)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "2F51FF"), Color(hex: "0E33F3")]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 175)
        .cornerRadius(8)
        .clipped()
    }
    
    // MARK: - Today Stats Section
    
    private var todayStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Hôm nay")
                    .font(.custom("SF Pro Text", size: 18))
                    .fontWeight(.medium)
                    .foregroundColor(Color(hex: "000000"))
                
                Spacer()
                
                Button(action: { 
                    showingDailyStatsDetail = true 
                }) {
                    HStack(spacing: 4) {
                        Text("Chi tiết")
                            .font(.custom("SF Pro Text", size: 14))
                            .foregroundColor(Color(hex: "000000"))
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(Color(hex: "000000"))
                    }
                }
            }
            
            Text(formatVND(todayTotal))
                .font(.custom("SF Pro Text", size: 32))
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "000000"))
        }
        .padding(15)
        .frame(maxWidth: .infinity, minHeight: 100)
        .background(
            ZStack {
                Color.white
                
                // Diagonal striped pattern using rectangles
                HStack(spacing: 2) {
                    ForEach(0..<50, id: \.self) { i in
                        Rectangle()
                            .fill(i % 2 == 0 ? Color.blue.opacity(0.1) : Color.pink.opacity(0.1))
                            .frame(width: 10)
                            .rotationEffect(.degrees(45))
                    }
                }
                .clipped()
            }
        )
        .cornerRadius(8)
    }
    
    // MARK: - Category Title Section
    
    private var categoryTitleSection: some View {
        HStack {
            Text("Danh mục nổi bật tháng 8")
                .font(.custom("SF Pro Text", size: 18))
                .fontWeight(.medium)
                .foregroundColor(Color(hex: "000000"))
            
            Spacer()
        }
        .padding(.horizontal, 0)
    }
    
    // MARK: - Category Card Section
    
    private var categoryCardSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Top row: (icon + category name) with auto spacing to link
            HStack {
                // Icon and category name grouped together with 4px spacing
                HStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "000000"))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "star.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    }
                    
                    Text("Thực phẩm")
                        .font(.custom("SF Pro Text", size: 18))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: "000000"))
                }
                
                Spacer()
                
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Text("Chi tiết")
                            .font(.custom("SF Pro Text", size: 16))
                            .foregroundColor(Color(hex: "000000"))
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(Color(hex: "000000"))
                    }
                }
            }
            
            // Bottom row: money amount with 12px spacing
            Text("₫5,857,231")
                .font(.custom("SF Pro Text", size: 32))
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "000000"))
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(8)
    }
    
    // MARK: - Recent Transactions Section
    
    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Chi tiêu gần đây")
                    .font(.custom("SF Pro Text", size: 24))
                    .fontWeight(.medium)
                    .foregroundColor(Color(hex: "000000"))
                
                Spacer()
                
                Button(action: {}) {
                    Text("Tất cả")
                        .font(.custom("SF Pro Text", size: 16))
                        .foregroundColor(Color(hex: "000000"))
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(Color(hex: "000000"))
                }
            }
            
            if recentTransactions.isEmpty && !isLoading {
                VStack(spacing: 12) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("Chưa có giao dịch")
                        .font(.custom("SF Pro Text", size: 18))
                        .fontWeight(.medium)
                        .foregroundColor(Color(hex: "000000"))
                    
                    Text("Nhấn + để thêm chi tiêu đầu tiên")
                        .font(.custom("SF Pro Text", size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(recentTransactions.prefix(10)) { expense in
                        RecentTransactionRow(expense: expense)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(8)
    }
    
    // MARK: - Data Loading
    
    private func loadDashboardData() async {
        isLoading = true
        
        do {
            // Load current month expenses
            let startOfMonth = calendar.startOfMonth(for: Date())
            let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) ?? Date()
            
            let monthlyExpenses = try await expenseService.getExpenses(
                startDate: startOfMonth,
                endDate: endOfMonth
            )
            
            // Load today's expenses
            let startOfDay = calendar.startOfDay(for: Date())
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? Date()
            
            let todayExpenses = try await expenseService.getExpenses(
                startDate: startOfDay,
                endDate: endOfDay
            )
            
            // Load recent transactions (latest 10)
            let allExpenses = try await expenseService.getExpenses(
                startDate: calendar.date(byAdding: .month, value: -3, to: Date()) ?? Date(),
                endDate: Date()
            )
            
            await MainActor.run {
                // Calculate totals
                self.monthlyTotal = monthlyExpenses.reduce(0) { $0 + $1.amount }
                self.todayTotal = todayExpenses.reduce(0) { $0 + $1.amount }
                
                // Find top category for current month
                let categoryTotals = Dictionary(grouping: monthlyExpenses) { $0.categoryName }
                    .mapValues { expenses in
                        expenses.reduce(0) { $0 + $1.amount }
                    }
                
                if let topCat = categoryTotals.max(by: { $0.value < $1.value }) {
                    // Find the icon for this category
                    let categoryIcon = monthlyExpenses.first { $0.categoryName == topCat.key }?.categoryIcon ?? "💰"
                    self.topCategory = (name: topCat.key, icon: categoryIcon, amount: topCat.value)
                }
                
                // Set recent transactions (latest 10)
                self.recentTransactions = Array(allExpenses.sorted { $0.createdAt > $1.createdAt }.prefix(10))
                
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                // Handle error - could show alert or error state
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

// MARK: - Recent Transaction Row

struct RecentTransactionRow: View {
    let expense: Expense
    
    var body: some View {
        HStack(spacing: 12) {
            Text(expense.categoryIcon)
                .font(.title2)
                .frame(width: 40, height: 40)
                .background(Color(hex: "F5F6F7"))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.description)
                    .font(.custom("SF Pro Text", size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(Color(hex: "000000"))
                    .lineLimit(1)
                
                Text(expense.categoryName)
                    .font(.custom("SF Pro Text", size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(formatVND(expense.amount))
                    .font(.custom("SF Pro Text", size: 16))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "000000"))
                
                Text(timeAgoString(from: expense.transactionDate))
                    .font(.custom("SF Pro Text", size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
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
    
    private func timeAgoString(from date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Hôm qua"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.locale = Locale(identifier: "vi_VN")
            return formatter.string(from: date)
        }
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Calendar Extension

extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}

#Preview {
    DashboardExpenseView()
}