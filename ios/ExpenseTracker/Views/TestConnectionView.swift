import SwiftUI

struct TestConnectionView: View {
    @StateObject private var categoryService = CategoryService()
    @StateObject private var expenseService = ExpenseService()
    @StateObject private var supabaseService = SupabaseService.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Connection Status
                    connectionStatusSection
                    
                    // Categories Test
                    categoriesSection
                    
                    // Expenses Test (if authenticated)
                    if supabaseService.isAuthenticated {
                        expensesSection
                    }
                    
                    // Test Actions
                    testActionsSection
                }
                .padding()
            }
            .navigationTitle("Database Test")
            .task {
                await categoryService.fetchDefaultCategories()
            }
        }
    }
    
    // MARK: - Connection Status Section
    
    private var connectionStatusSection: some View {
        VStack(spacing: 12) {
            Text("Kết nối Database")
                .font(.headline)
            
            HStack {
                Circle()
                    .fill(supabaseService.isAuthenticated ? .green : .orange)
                    .frame(width: 12, height: 12)
                
                Text(supabaseService.isAuthenticated ? "Đã đăng nhập" : "Chưa đăng nhập")
                    .font(.subheadline)
                
                Spacer()
            }
            
            if let user = supabaseService.currentUser {
                Text("User ID: \(user.id)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    // MARK: - Categories Section
    
    private var categoriesSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Danh mục Vietnamese")
                    .font(.headline)
                
                Spacer()
                
                if categoryService.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            if let error = categoryService.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            } else {
                Text("Tìm thấy \(categoryService.categories.count) danh mục")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                ForEach(categoryService.categories.prefix(6)) { category in
                    CategoryTestCard(category: category)
                }
            }
            
            if categoryService.categories.count > 6 {
                Text("... và \(categoryService.categories.count - 6) danh mục khác")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    // MARK: - Expenses Section
    
    private var expensesSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Chi tiêu")
                    .font(.headline)
                
                Spacer()
                
                if expenseService.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            if let error = expenseService.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            } else {
                Text("Tìm thấy \(expenseService.expenses.count) chi tiêu")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if expenseService.expenses.isEmpty {
                Text("Chưa có chi tiêu nào")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(expenseService.expenses.prefix(3)) { expense in
                    ExpenseTestCard(expense: expense)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    // MARK: - Test Actions Section
    
    private var testActionsSection: some View {
        VStack(spacing: 12) {
            Text("Test Actions")
                .font(.headline)
            
            Button("Tải lại danh mục") {
                Task {
                    await categoryService.fetchDefaultCategories()
                }
            }
            .buttonStyle(.borderedProminent)
            
            if supabaseService.isAuthenticated {
                Button("Tải chi tiêu") {
                    Task {
                        await expenseService.fetchExpenses()
                    }
                }
                .buttonStyle(.bordered)
            }
            
            Button("Tải dữ liệu mẫu") {
                categoryService.categories = Category.sampleCategories
                expenseService.expenses = Expense.sampleExpenses
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// MARK: - Category Test Card

struct CategoryTestCard: View {
    let category: Category
    
    var body: some View {
        HStack(spacing: 8) {
            Text(category.icon)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(category.name)
                    .font(.caption)
                    .fontWeight(.medium)
                
                if category.isDefault {
                    Text("Mặc định")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}

// MARK: - Expense Test Card

struct ExpenseTestCard: View {
    let expense: Expense
    
    var body: some View {
        HStack {
            Text(expense.categoryIcon)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(expense.description)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(expense.categoryName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(expense.formattedAmount)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(expense.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}

#Preview {
    TestConnectionView()
}