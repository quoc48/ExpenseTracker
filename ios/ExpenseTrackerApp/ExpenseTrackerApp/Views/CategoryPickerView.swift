import SwiftUI

struct CategoryPickerView: View {
    @StateObject private var categoryService = CategoryService()
    @Binding var selectedCategory: Category?
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                searchBar
                
                // Categories Grid
                if categoryService.isLoading {
                    loadingView
                } else if categoryService.categories.isEmpty {
                    emptyStateView
                } else {
                    categoriesGrid
                }
            }
            .navigationTitle("Chọn Danh Mục")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") {
                        dismiss()
                    }
                }
            }
            .task {
                await categoryService.fetchDefaultCategories()
            }
        }
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Tìm kiếm danh mục...", text: $searchText)
                .textFieldStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Đang tải danh mục...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder.badge.questionmark")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("Không có danh mục")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Vui lòng kiểm tra kết nối mạng")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Thử lại") {
                Task {
                    await categoryService.fetchDefaultCategories()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    // MARK: - Categories Grid
    
    private var categoriesGrid: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(filteredCategories) { category in
                    CategoryCard(
                        category: category,
                        isSelected: selectedCategory?.id == category.id
                    ) {
                        selectedCategory = category
                        dismiss()
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - Filtered Categories
    
    private var filteredCategories: [Category] {
        if searchText.isEmpty {
            return categoryService.categories
        } else {
            return categoryService.categories.filter { category in
                category.name.localizedCaseInsensitiveContains(searchText) ||
                category.icon.contains(searchText)
            }
        }
    }
}

// MARK: - Category Card

struct CategoryCard: View {
    let category: Category
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Icon
                Text(category.icon)
                    .font(.system(size: 32))
                
                // Name
                Text(category.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                // Default Badge
                if category.isDefault {
                    Text("Mặc định")
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color.blue : Color(.systemGray4),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview("Category Picker") {
    CategoryPickerView(selectedCategory: .constant(nil))
}

#Preview("Category Card") {
    VStack {
        CategoryCard(
            category: Category.sampleCategory,
            isSelected: false
        ) {
            print("Tapped")
        }
        
        CategoryCard(
            category: Category.sampleCategory,
            isSelected: true
        ) {
            print("Tapped")
        }
    }
    .padding()
}