import Foundation

struct Category: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let icon: String
    let color: String
    let defaultType: String?
    let isDefault: Bool
    let userId: UUID?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case icon
        case color
        case defaultType = "default_type"
        case isDefault = "is_default"
        case userId = "user_id"
        case createdAt = "created_at"
    }
}

// MARK: - Extensions
extension Category {
    static let sampleCategory = Category(
        id: UUID(),
        name: "Thực phẩm",
        icon: "🍜",
        color: "#007AFF",
        defaultType: "food",
        isDefault: true,
        userId: nil,
        createdAt: Date()
    )
    
    static let sampleCategories = [
        Category(id: UUID(), name: "Thực phẩm", icon: "🍜", color: "#007AFF", defaultType: "food", isDefault: true, userId: nil, createdAt: Date()),
        Category(id: UUID(), name: "Tạp hoá", icon: "🛒", color: "#007AFF", defaultType: "groceries", isDefault: true, userId: nil, createdAt: Date()),
        Category(id: UUID(), name: "Thời trang", icon: "👔", color: "#007AFF", defaultType: "fashion", isDefault: true, userId: nil, createdAt: Date()),
        Category(id: UUID(), name: "Giáo dục", icon: "📚", color: "#007AFF", defaultType: "education", isDefault: true, userId: nil, createdAt: Date()),
        Category(id: UUID(), name: "Tiền nhà", icon: "🏠", color: "#007AFF", defaultType: "housing", isDefault: true, userId: nil, createdAt: Date())
    ]
}

// MARK: - Display Helpers
extension Category {
    var displayName: String {
        return name
    }
    
    var displayIcon: String {
        return icon
    }
    
    var hexColor: String {
        return color.hasPrefix("#") ? color : "#\(color)"
    }
}