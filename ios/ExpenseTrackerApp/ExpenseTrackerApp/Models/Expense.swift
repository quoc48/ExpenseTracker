import Foundation

struct Expense: Codable, Identifiable, Hashable {
    let id: UUID
    let userId: UUID
    let amount: Decimal
    let description: String
    let categoryId: UUID
    let categoryName: String
    let categoryIcon: String
    let expenseType: String?
    let transactionDate: Date
    let createdAt: Date
    let updatedAt: Date
    let embedding: [Float]?
    let metadata: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case amount
        case description
        case categoryId = "category_id"
        case categoryName = "category_name"
        case categoryIcon = "category_icon"
        case expenseType = "expense_type"
        case transactionDate = "transaction_date"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case embedding
        case metadata
    }
}

// MARK: - AnyCodable for flexible metadata
struct AnyCodable: Codable, Hashable {
    let value: Any
    
    init<T>(_ value: T?) {
        self.value = value ?? ()
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else if let arrayValue = try? container.decode([AnyCodable].self) {
            value = arrayValue.map { $0.value }
        } else if let dictionaryValue = try? container.decode([String: AnyCodable].self) {
            value = dictionaryValue.mapValues { $0.value }
        } else {
            value = ()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let intValue as Int:
            try container.encode(intValue)
        case let doubleValue as Double:
            try container.encode(doubleValue)
        case let stringValue as String:
            try container.encode(stringValue)
        case let boolValue as Bool:
            try container.encode(boolValue)
        case let arrayValue as [Any]:
            let anyCodableArray = arrayValue.map { AnyCodable($0) }
            try container.encode(anyCodableArray)
        case let dictionaryValue as [String: Any]:
            let anyCodableDictionary = dictionaryValue.mapValues { AnyCodable($0) }
            try container.encode(anyCodableDictionary)
        default:
            try container.encodeNil()
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch value {
        case let intValue as Int:
            hasher.combine(intValue)
        case let doubleValue as Double:
            hasher.combine(doubleValue)
        case let stringValue as String:
            hasher.combine(stringValue)
        case let boolValue as Bool:
            hasher.combine(boolValue)
        default:
            hasher.combine(0)
        }
    }
    
    static func == (lhs: AnyCodable, rhs: AnyCodable) -> Bool {
        switch (lhs.value, rhs.value) {
        case (let left as Int, let right as Int):
            return left == right
        case (let left as Double, let right as Double):
            return left == right
        case (let left as String, let right as String):
            return left == right
        case (let left as Bool, let right as Bool):
            return left == right
        default:
            return false
        }
    }
}

// MARK: - Extensions
extension Expense {
    static let sampleExpense = Expense(
        id: UUID(),
        userId: UUID(),
        amount: 45000,
        description: "Cơm trưa tại nhà hàng",
        categoryId: UUID(),
        categoryName: "Thực phẩm",
        categoryIcon: "🍜",
        expenseType: "food",
        transactionDate: Date(),
        createdAt: Date(),
        updatedAt: Date(),
        embedding: nil,
        metadata: nil
    )
    
    static let sampleExpenses = [
        Expense(
            id: UUID(),
            userId: UUID(),
            amount: 45000,
            description: "Cơm trưa tại nhà hàng",
            categoryId: UUID(),
            categoryName: "Thực phẩm",
            categoryIcon: "🍜",
            expenseType: "food",
            transactionDate: Date(),
            createdAt: Date(),
            updatedAt: Date(),
            embedding: nil,
            metadata: nil
        ),
        Expense(
            id: UUID(),
            userId: UUID(),
            amount: 25000,
            description: "Xe bus đi làm",
            categoryId: UUID(),
            categoryName: "Giao thông",
            categoryIcon: "🚌",
            expenseType: "transportation",
            transactionDate: Date().addingTimeInterval(-86400),
            createdAt: Date(),
            updatedAt: Date(),
            embedding: nil,
            metadata: nil
        ),
        Expense(
            id: UUID(),
            userId: UUID(),
            amount: 150000,
            description: "Áo sơ mi mới",
            categoryId: UUID(),
            categoryName: "Thời trang",
            categoryIcon: "👔",
            expenseType: "fashion",
            transactionDate: Date().addingTimeInterval(-172800),
            createdAt: Date(),
            updatedAt: Date(),
            embedding: nil,
            metadata: nil
        )
    ]
}

// MARK: - Display Helpers
extension Expense {
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "VND"
        formatter.currencySymbol = "₫"
        formatter.maximumFractionDigits = 0
        
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "₫0"
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "vi_VN")
        
        return formatter.string(from: transactionDate)
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(transactionDate)
    }
    
    var isThisWeek: Bool {
        Calendar.current.isDate(transactionDate, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    var isThisMonth: Bool {
        Calendar.current.isDate(transactionDate, equalTo: Date(), toGranularity: .month)
    }
}