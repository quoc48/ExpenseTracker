import SwiftUI

struct BudgetDetailView: View {
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var monthlyData: [MonthlyExpense] = []
    
    private let monthlyBudget: Double = 10_000_000 // ₫10M monthly budget
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Year Picker Section
                yearPickerSection
                
                // Budget Overview Section
                budgetOverviewSection
                
                // Monthly Expenses Chart
                monthlyExpensesChart
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .background(Color(hex: "F5F6F7"))
            .navigationTitle("Chi tiết ngân sách")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadMockData()
            }
        }
    }
    
    // MARK: - Year Picker Section
    
    private var yearPickerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Chọn năm")
                .font(.custom("SF Pro Text", size: 16))
                .fontWeight(.medium)
                .foregroundColor(Color(hex: "000000"))
            
            HStack {
                Button(action: { changeYear(-1) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "2F51FF"))
                }
                
                Spacer()
                
                Text("\(selectedYear)")
                    .font(.custom("SF Pro Text", size: 24))
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "000000"))
                
                Spacer()
                
                Button(action: { changeYear(1) }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "2F51FF"))
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(8)
    }
    
    // MARK: - Budget Overview Section
    
    private var budgetOverviewSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Tổng quan ngân sách \(selectedYear)")
                    .font(.custom("SF Pro Text", size: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ngân sách năm")
                        .font(.custom("SF Pro Text", size: 14))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(formatVND(monthlyBudget * 12))
                        .font(.custom("SF Pro Text", size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Đã chi")
                        .font(.custom("SF Pro Text", size: 14))
                        .foregroundColor(.white.opacity(0.8))
                    
                    let totalSpent = monthlyData.reduce(0) { $0 + $1.amount }
                    Text(formatVND(totalSpent))
                        .font(.custom("SF Pro Text", size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            
            // Progress bar for yearly budget
            let yearlyBudget = monthlyBudget * 12
            let totalSpent = monthlyData.reduce(0) { $0 + $1.amount }
            let percentage = min(totalSpent / yearlyBudget, 1.0)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Tiến độ sử dụng")
                        .font(.custom("SF Pro Text", size: 14))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text("\(Int(percentage * 100))%")
                        .font(.custom("SF Pro Text", size: 14))
                        .foregroundColor(.white)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(height: 8)
                            .foregroundColor(.white.opacity(0.2))
                            .cornerRadius(4)
                        
                        Rectangle()
                            .frame(width: geometry.size.width * percentage, height: 8)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(16)
        .background(Color(hex: "2C2C2C"))
        .cornerRadius(8)
    }
    
    // MARK: - Monthly Expenses Chart
    
    private var monthlyExpensesChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Chi tiêu theo tháng")
                    .font(.custom("SF Pro Text", size: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "000000"))
                
                Spacer()
                
                Text("Ngân sách: \(formatVND(monthlyBudget))")
                    .font(.custom("SF Pro Text", size: 14))
                    .foregroundColor(.secondary)
            }
            
            // Chart Area
            VStack(spacing: 8) {
                // Chart bars
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(monthlyData) { month in
                        VStack(spacing: 4) {
                            // Bar
                            let barHeight = max(CGFloat(month.amount / monthlyBudget) * 200, 4)
                            Rectangle()
                                .fill(month.amount > monthlyBudget ? Color.red : Color(hex: "2F51FF"))
                                .frame(width: 24, height: barHeight)
                                .cornerRadius(2)
                            
                            // Month label
                            Text(month.monthAbbrev)
                                .font(.custom("SF Pro Text", size: 10))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(height: 220)
                
                // Chart legend
                HStack {
                    Text("Tháng")
                        .font(.custom("SF Pro Text", size: 12))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Rectangle()
                                .fill(Color(hex: "2F51FF"))
                                .frame(width: 12, height: 4)
                                .cornerRadius(2)
                            Text("Trong ngân sách")
                                .font(.custom("SF Pro Text", size: 12))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 4) {
                            Rectangle()
                                .fill(Color.red)
                                .frame(width: 12, height: 4)
                                .cornerRadius(2)
                            Text("Vượt ngân sách")
                                .font(.custom("SF Pro Text", size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(8)
    }
    
    // MARK: - Helper Methods
    
    private func changeYear(_ delta: Int) {
        selectedYear += delta
        loadMockData()
    }
    
    private func loadMockData() {
        // Generate mock data for 12 months
        let months = ["Th1", "Th2", "Th3", "Th4", "Th5", "Th6", 
                     "Th7", "Th8", "Th9", "Th10", "Th11", "Th12"]
        
        monthlyData = months.enumerated().map { index, month in
            let baseAmount = monthlyBudget * 0.5 // Start with 50% of budget
            let variation = Double.random(in: 0.3...1.5) // 30% to 150% variation
            let amount = baseAmount * variation
            
            return MonthlyExpense(
                month: index + 1,
                monthAbbrev: month,
                amount: amount,
                year: selectedYear
            )
        }
    }
    
    private func formatVND(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "vi_VN")
        
        if let formatted = formatter.string(from: NSNumber(value: amount)) {
            return "₫\(formatted)"
        }
        return "₫\(Int(amount))"
    }
}

// MARK: - Data Models

struct MonthlyExpense: Identifiable {
    let id = UUID()
    let month: Int
    let monthAbbrev: String
    let amount: Double
    let year: Int
}

#Preview {
    BudgetDetailView()
}