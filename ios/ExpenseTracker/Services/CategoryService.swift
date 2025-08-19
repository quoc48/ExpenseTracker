import Foundation
import Supabase

@MainActor
class CategoryService: ObservableObject {
    private let supabase = SupabaseService.shared
    
    @Published var categories: [Category] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Fetch Categories
    
    func fetchCategories() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response: [Category] = try await supabase.database
                .from("categories")
                .select()
                .order("name")
                .execute()
                .value
            
            self.categories = response
            
        } catch {
            self.errorMessage = "Không thể tải danh mục: \(error.localizedDescription)"
            print("Error fetching categories: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Get Default Categories
    
    func fetchDefaultCategories() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response: [Category] = try await supabase.database
                .from("categories")
                .select()
                .eq("is_default", value: true)
                .order("name")
                .execute()
                .value
            
            self.categories = response
            
        } catch {
            self.errorMessage = "Không thể tải danh mục mặc định: \(error.localizedDescription)"
            print("Error fetching default categories: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Get User Categories
    
    func fetchUserCategories() async {
        guard let userId = supabase.userId else {
            errorMessage = "Người dùng chưa đăng nhập"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response: [Category] = try await supabase.database
                .from("categories")
                .select()
                .or("user_id.eq.\(userId.uuidString),is_default.eq.true")
                .order("is_default", ascending: false)
                .order("name")
                .execute()
                .value
            
            self.categories = response
            
        } catch {
            self.errorMessage = "Không thể tải danh mục người dùng: \(error.localizedDescription)"
            print("Error fetching user categories: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Create Category
    
    func createCategory(name: String, icon: String, color: String, defaultType: String?) async throws -> Category {
        guard let userId = supabase.userId else {
            throw CategoryError.userNotAuthenticated
        }
        
        let newCategory = Category(
            id: UUID(),
            name: name,
            icon: icon,
            color: color,
            defaultType: defaultType,
            isDefault: false,
            userId: userId,
            createdAt: Date()
        )
        
        do {
            let response: [Category] = try await supabase.database
                .from("categories")
                .insert(newCategory)
                .select()
                .execute()
                .value
            
            guard let createdCategory = response.first else {
                throw CategoryError.creationFailed
            }
            
            // Add to local categories list
            self.categories.append(createdCategory)
            self.categories.sort { $0.name < $1.name }
            
            return createdCategory
            
        } catch {
            self.errorMessage = "Không thể tạo danh mục: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Update Category
    
    func updateCategory(_ category: Category, name: String? = nil, icon: String? = nil, color: String? = nil) async throws {
        guard let userId = supabase.userId else {
            throw CategoryError.userNotAuthenticated
        }
        
        // Only allow updating user's own categories (not default ones)
        guard category.userId == userId else {
            throw CategoryError.cannotEditDefaultCategory
        }
        
        var updates: [String: Any] = [:]
        if let name = name { updates["name"] = name }
        if let icon = icon { updates["icon"] = icon }
        if let color = color { updates["color"] = color }
        updates["updated_at"] = Date()
        
        do {
            try await supabase.database
                .from("categories")
                .update(updates)
                .eq("id", value: category.id.uuidString)
                .execute()
            
            // Update local categories list
            if let index = categories.firstIndex(where: { $0.id == category.id }) {
                var updatedCategory = categories[index]
                if let name = name { updatedCategory = Category(id: updatedCategory.id, name: name, icon: updatedCategory.icon, color: updatedCategory.color, defaultType: updatedCategory.defaultType, isDefault: updatedCategory.isDefault, userId: updatedCategory.userId, createdAt: updatedCategory.createdAt) }
                // Note: In a real app, you'd want a proper update mechanism for the struct
                categories[index] = updatedCategory
            }
            
        } catch {
            self.errorMessage = "Không thể cập nhật danh mục: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Delete Category
    
    func deleteCategory(_ category: Category) async throws {
        guard let userId = supabase.userId else {
            throw CategoryError.userNotAuthenticated
        }
        
        // Only allow deleting user's own categories (not default ones)
        guard category.userId == userId else {
            throw CategoryError.cannotDeleteDefaultCategory
        }
        
        do {
            try await supabase.database
                .from("categories")
                .delete()
                .eq("id", value: category.id.uuidString)
                .execute()
            
            // Remove from local categories list
            categories.removeAll { $0.id == category.id }
            
        } catch {
            self.errorMessage = "Không thể xóa danh mục: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Helper Methods
    
    func category(by id: UUID) -> Category? {
        return categories.first { $0.id == id }
    }
    
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Category Errors
enum CategoryError: LocalizedError {
    case userNotAuthenticated
    case creationFailed
    case cannotEditDefaultCategory
    case cannotDeleteDefaultCategory
    
    var errorDescription: String? {
        switch self {
        case .userNotAuthenticated:
            return "Người dùng chưa đăng nhập"
        case .creationFailed:
            return "Không thể tạo danh mục"
        case .cannotEditDefaultCategory:
            return "Không thể chỉnh sửa danh mục mặc định"
        case .cannotDeleteDefaultCategory:
            return "Không thể xóa danh mục mặc định"
        }
    }
}