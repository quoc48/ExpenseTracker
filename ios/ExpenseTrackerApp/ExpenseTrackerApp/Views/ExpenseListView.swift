import SwiftUI

struct ExpenseListView: View {
    @StateObject private var expenseService = ExpenseService()
    @StateObject private var categoryService = CategoryService()
    @StateObject private var supabaseService = SupabaseService.shared
    
    @State private var showingAddExpense = false
    @State private var selectedPeriod: DatePeriod = .thisMonth
    @State private var searchText = ""
    @State private var selectedCategory: Category?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if supabaseService.isAuthenticated {
                    // Filter Controls
                    filterControls
                    
                    // Expense List
                    expenseListContent
                } else {
                    // Not Authenticated State
                    notAuthenticatedView
                }
            }
            .navigationTitle("Chi Tiêu")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddExpense = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .disabled(!supabaseService.isAuthenticated)
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView()
            }
            .task {
                if supabaseService.isAuthenticated {
                    await loadData()
                }
            }
            .onChange(of: selectedPeriod) { _, _ in
                Task {
                    await loadExpenses()
                }
            }
            .onChange(of: selectedCategory) { _, _ in
                Task {
                    await loadExpenses()
                }
            }
            .refreshable {
                await loadData()
            }
        }
    }
    
    // MARK: - Filter Controls
    
    private var filterControls: some View {
        VStack(spacing: 12) {
            // Period Picker
            HStack {
                Text("Thời gian:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Picker("Period", selection: $selectedPeriod) {
                    Text("Hôm nay").tag(DatePeriod.today)
                    Text("Tuần này").tag(DatePeriod.thisWeek)
                    Text("Tháng này").tag(DatePeriod.thisMonth)
                    Text("Năm này").tag(DatePeriod.thisYear)
                }
                .pickerStyle(.segmented)
            }
            
            // Category Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // All Categories Button
                    CategoryFilterChip(
                        title: "Tất cả",
                        icon: "list.bullet",
                        isSelected: selectedCategory == nil
                    ) {
                        selectedCategory = nil
                    }
                    
                    // Category Chips
                    ForEach(categoryService.categories) { category in
                        CategoryFilterChip(
                            title: category.name,
                            icon: category.icon,
                            isSelected: selectedCategory?.id == category.id
                        ) {
                            selectedCategory = selectedCategory?.id == category.id ? nil : category
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
    
    // MARK: - Expense List Content
    
    private var expenseListContent: some View {
        Group {
            if expenseService.isLoading {
                loadingView
            } else if filteredExpenses.isEmpty {
                emptyStateView
            } else {
                expenseList
            }
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Đang tải chi tiêu...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "creditcard")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("Chưa có chi tiêu")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Bắt đầu thêm chi tiêu của bạn")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button("Thêm chi tiêu đầu tiên") {
                showingAddExpense = true
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    // MARK: - Expense List
    
    private var expenseList: some View {
        List {
            // Summary Section
            summarySection
            
            // Expenses Section
            expensesSection
        }
        .listStyle(.insetGrouped)
    }
    
    private var summarySection: some View {
        Section {
            VStack(spacing: 8) {
                HStack {
                    Text("Tổng chi tiêu")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(periodText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text(totalAmount)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(filteredExpenses.count) giao dịch")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    private var expensesSection: some View {
        Section("Chi tiêu gần đây") {
            ForEach(filteredExpenses) { expense in
                ExpenseRowView(expense: expense)
            }
            .onDelete(perform: deleteExpenses)
        }
    }
    
    // MARK: - Not Authenticated View
    
    private var notAuthenticatedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("Chưa đăng nhập")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Vui lòng đăng nhập để xem chi tiêu của bạn")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    // MARK: - Computed Properties
    
    private var filteredExpenses: [Expense] {
        var expenses = expenseService.expenses
        
        // Filter by category if selected
        if let selectedCategory = selectedCategory {
            expenses = expenses.filter { $0.categoryId == selectedCategory.id }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            expenses = expenses.filter { expense in
                expense.description.localizedCaseInsensitiveContains(searchText) ||
                expense.categoryName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return expenses
    }
    
    private var totalAmount: String {
        let total = filteredExpenses.reduce(0) { $0 + $1.amount }
        return formatCurrency(total)
    }
    
    private var periodText: String {
        switch selectedPeriod {
        case .today: return "Hôm nay"
        case .thisWeek: return "Tuần này"
        case .thisMonth: return "Tháng này"
        case .thisYear: return "Năm này"
        case .custom: return "Tùy chọn"
        }
    }
    
    // MARK: - Methods
    
    private func loadData() async {
        await categoryService.fetchDefaultCategories()
        await loadExpenses()
    }
    
    private func loadExpenses() async {
        if let selectedCategory = selectedCategory {
            await expenseService.fetchExpenses(categoryId: selectedCategory.id)
        } else {
            let (startDate, endDate) = selectedPeriod.dateRange
            await expenseService.fetchExpenses(from: startDate, to: endDate)
        }
    }
    
    private func deleteExpenses(offsets: IndexSet) {
        for index in offsets {
            let expense = filteredExpenses[index]
            Task {
                try await expenseService.deleteExpense(expense)
            }
        }
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "VND"
        formatter.currencySymbol = "₫"
        formatter.maximumFractionDigits = 0
        
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "₫0"
    }
}

// MARK: - Category Filter Chip

struct CategoryFilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if icon.count == 1 {
                    Text(icon)
                        .font(.caption)
                } else {
                    Image(systemName: icon)
                        .font(.caption)
                }
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isSelected ? Color.blue : Color(.systemGray5))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Expense Row View

struct ExpenseRowView: View {
    let expense: Expense
    
    var body: some View {
        HStack(spacing: 12) {
            // Category Icon
            Text(expense.categoryIcon)
                .font(.title2)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            
            // Expense Details
            VStack(alignment: .leading, spacing: 2) {
                Text(expense.description)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(expense.categoryName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(expense.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Amount
            Text(expense.formattedAmount)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ExpenseListView()
}