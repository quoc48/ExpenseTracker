import SwiftUI

struct AddExpenseView: View {
    @StateObject private var categoryService = CategoryService()
    @StateObject private var expenseService = ExpenseService()
    @Environment(\.dismiss) private var dismiss
    
    @State private var amount: String = ""
    @State private var description: String = ""
    @State private var selectedCategory: Category?
    @State private var selectedDate = Date()
    @State private var showingCategoryPicker = false
    @State private var isSubmitting = false
    @State private var showingSuccessAlert = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            Form {
                // Amount Section
                Section("Số tiền") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            TextField("0", text: $amount)
                                .keyboardType(.numberPad)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.trailing)
                            
                            Text("₫")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                        
                        if !amount.isEmpty, let amountValue = Decimal(string: amount.replacingOccurrences(of: ",", with: "")) {
                            Text(formatCurrency(amountValue))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // Category Section
                Section("Danh mục") {
                    Button(action: {
                        showingCategoryPicker = true
                    }) {
                        HStack {
                            if let category = selectedCategory {
                                Text(category.icon)
                                    .font(.title2)
                                
                                Text(category.name)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Chọn danh mục")
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
                
                // Description Section
                Section("Mô tả") {
                    TextField("Nhập mô tả chi tiêu...", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                // Date Section
                Section("Ngày") {
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                }
                
                // Error Section
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Thêm Chi Tiêu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") {
                        Task {
                            await submitExpense()
                        }
                    }
                    .disabled(!isFormValid || isSubmitting)
                }
            }
            .sheet(isPresented: $showingCategoryPicker) {
                CategoryPickerView(selectedCategory: $selectedCategory)
            }
            .alert("Thành công", isPresented: $showingSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Chi tiêu đã được thêm thành công!")
            }
            .task {
                await categoryService.fetchDefaultCategories()
            }
            .onChange(of: categoryService.errorMessage) { _, newValue in
                if let error = newValue {
                    errorMessage = error
                }
            }
            .onChange(of: expenseService.errorMessage) { _, newValue in
                if let error = newValue {
                    errorMessage = error
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        !amount.isEmpty &&
        Decimal(string: amount.replacingOccurrences(of: ",", with: "")) != nil &&
        selectedCategory != nil &&
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Methods
    
    private func submitExpense() async {
        guard let category = selectedCategory,
              let amountValue = Decimal(string: amount.replacingOccurrences(of: ",", with: "")) else {
            errorMessage = "Thông tin không hợp lệ"
            return
        }
        
        isSubmitting = true
        errorMessage = nil
        
        do {
            _ = try await expenseService.createExpense(
                amount: amountValue,
                description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                category: category,
                date: selectedDate
            )
            
            showingSuccessAlert = true
            
        } catch {
            errorMessage = "Không thể lưu chi tiêu: \(error.localizedDescription)"
        }
        
        isSubmitting = false
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

#Preview {
    AddExpenseView()
}