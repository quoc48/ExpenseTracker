import Foundation
import Supabase

@MainActor
class ExpenseService: ObservableObject {
    private let supabase = SupabaseService.shared
    
    @Published var expenses: [Expense] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Fetch Expenses
    
    func fetchExpenses(limit: Int = 50) async {
        guard let userId = supabase.userId else {
            errorMessage = "Người dùng chưa đăng nhập"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response: [Expense] = try await supabase.database
                .from("expenses")
                .select()
                .eq("user_id", value: userId.uuidString)
                .order("transaction_date", ascending: false)
                .limit(limit)
                .execute()
                .value
            
            self.expenses = response
            
        } catch {
            self.errorMessage = "Không thể tải chi tiêu: \(error.localizedDescription)"
            print("Error fetching expenses: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Fetch Expenses by Date Range
    
    func fetchExpenses(from startDate: Date, to endDate: Date) async {
        guard let userId = supabase.userId else {
            errorMessage = "Người dùng chưa đăng nhập"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let formatter = ISO8601DateFormatter()
        let startDateString = formatter.string(from: startDate)
        let endDateString = formatter.string(from: endDate)
        
        do {
            let response: [Expense] = try await supabase.database
                .from("expenses")
                .select()
                .eq("user_id", value: userId.uuidString)
                .gte("transaction_date", value: startDateString)
                .lte("transaction_date", value: endDateString)
                .order("transaction_date", ascending: false)
                .execute()
                .value
            
            self.expenses = response
            
        } catch {
            self.errorMessage = "Không thể tải chi tiêu theo thời gian: \(error.localizedDescription)"
            print("Error fetching expenses by date: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Fetch Expenses by Category
    
    func fetchExpenses(categoryId: UUID) async {
        guard let userId = supabase.userId else {
            errorMessage = "Người dùng chưa đăng nhập"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response: [Expense] = try await supabase.database
                .from("expenses")
                .select()
                .eq("user_id", value: userId.uuidString)
                .eq("category_id", value: categoryId.uuidString)
                .order("transaction_date", ascending: false)
                .execute()
                .value
            
            self.expenses = response
            
        } catch {
            self.errorMessage = "Không thể tải chi tiêu theo danh mục: \(error.localizedDescription)"
            print("Error fetching expenses by category: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Create Expense
    
    func createExpense(
        amount: Decimal,
        description: String,
        category: Category,
        date: Date = Date(),
        expenseType: String? = nil,
        metadata: [String: Any]? = nil
    ) async throws -> Expense {
        guard let userId = supabase.userId else {
            throw ExpenseError.userNotAuthenticated
        }
        
        let newExpense = Expense(
            id: UUID(),
            userId: userId,
            amount: amount,
            description: description,
            categoryId: category.id,
            categoryName: category.name,
            categoryIcon: category.icon,
            expenseType: expenseType ?? category.defaultType,
            transactionDate: date,
            createdAt: Date(),
            updatedAt: Date(),
            embedding: nil,
            metadata: metadata?.mapValues { AnyCodable($0) }
        )
        
        do {
            let response: [Expense] = try await supabase.database
                .from("expenses")
                .insert(newExpense)
                .select()
                .execute()
                .value
            
            guard let createdExpense = response.first else {
                throw ExpenseError.creationFailed
            }
            
            // Add to local expenses list
            self.expenses.insert(createdExpense, at: 0)
            
            return createdExpense
            
        } catch {
            self.errorMessage = "Không thể tạo chi tiêu: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Update Expense
    
    func updateExpense(
        _ expense: Expense,
        amount: Decimal? = nil,
        description: String? = nil,
        category: Category? = nil,
        date: Date? = nil,
        expenseType: String? = nil,
        metadata: [String: Any]? = nil
    ) async throws {
        guard let userId = supabase.userId else {
            throw ExpenseError.userNotAuthenticated
        }
        
        // Ensure user can only update their own expenses
        guard expense.userId == userId else {
            throw ExpenseError.notAuthorized
        }
        
        var updates: [String: Any] = [:]
        if let amount = amount { updates["amount"] = amount }
        if let description = description { updates["description"] = description }
        if let category = category {
            updates["category_id"] = category.id.uuidString
            updates["category_name"] = category.name
            updates["category_icon"] = category.icon
        }
        if let date = date { updates["transaction_date"] = date }
        if let expenseType = expenseType { updates["expense_type"] = expenseType }
        if let metadata = metadata { updates["metadata"] = metadata }
        updates["updated_at"] = Date()
        
        do {
            try await supabase.database
                .from("expenses")
                .update(updates)
                .eq("id", value: expense.id.uuidString)
                .execute()
            
            // Update local expenses list
            if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
                // Fetch the updated expense from the server to get the latest data
                await fetchExpenses()
            }
            
        } catch {
            self.errorMessage = "Không thể cập nhật chi tiêu: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Delete Expense
    
    func deleteExpense(_ expense: Expense) async throws {
        guard let userId = supabase.userId else {
            throw ExpenseError.userNotAuthenticated
        }
        
        // Ensure user can only delete their own expenses
        guard expense.userId == userId else {
            throw ExpenseError.notAuthorized
        }
        
        do {
            try await supabase.database
                .from("expenses")
                .delete()
                .eq("id", value: expense.id.uuidString)
                .execute()
            
            // Remove from local expenses list
            expenses.removeAll { $0.id == expense.id }
            
        } catch {
            self.errorMessage = "Không thể xóa chi tiêu: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Statistics
    
    func getTotalAmount(for period: DatePeriod = .thisMonth) async -> Decimal {
        let (startDate, endDate) = period.dateRange
        
        guard let userId = supabase.userId else { return 0 }
        
        let formatter = ISO8601DateFormatter()
        let startDateString = formatter.string(from: startDate)
        let endDateString = formatter.string(from: endDate)
        
        do {
            let response: [Expense] = try await supabase.database
                .from("expenses")
                .select("amount")
                .eq("user_id", value: userId.uuidString)
                .gte("transaction_date", value: startDateString)
                .lte("transaction_date", value: endDateString)
                .execute()
                .value
            
            return response.reduce(0) { $0 + $1.amount }
            
        } catch {
            print("Error calculating total amount: \(error)")
            return 0
        }
    }
    
    // MARK: - Helper Methods
    
    func expense(by id: UUID) -> Expense? {
        return expenses.first { $0.id == id }
    }
    
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Date Period Helper
enum DatePeriod {
    case today
    case thisWeek
    case thisMonth
    case thisYear
    case custom(start: Date, end: Date)
    
    var dateRange: (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .today:
            let start = calendar.startOfDay(for: now)
            let end = calendar.endOfDay(for: now)
            return (start, end)
            
        case .thisWeek:
            let start = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            let end = calendar.dateInterval(of: .weekOfYear, for: now)?.end ?? now
            return (start, end)
            
        case .thisMonth:
            let start = calendar.dateInterval(of: .month, for: now)?.start ?? now
            let end = calendar.dateInterval(of: .month, for: now)?.end ?? now
            return (start, end)
            
        case .thisYear:
            let start = calendar.dateInterval(of: .year, for: now)?.start ?? now
            let end = calendar.dateInterval(of: .year, for: now)?.end ?? now
            return (start, end)
            
        case .custom(let start, let end):
            return (start, end)
        }
    }
}

// MARK: - Calendar Extension
extension Calendar {
    func endOfDay(for date: Date) -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return self.date(byAdding: components, to: startOfDay(for: date)) ?? date
    }
}

// MARK: - Expense Errors
enum ExpenseError: LocalizedError {
    case userNotAuthenticated
    case creationFailed
    case notAuthorized
    
    var errorDescription: String? {
        switch self {
        case .userNotAuthenticated:
            return "Người dùng chưa đăng nhập"
        case .creationFailed:
            return "Không thể tạo chi tiêu"
        case .notAuthorized:
            return "Không có quyền thực hiện hành động này"
        }
    }
}