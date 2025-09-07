import SwiftUI
import Foundation

struct DailyStatsDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var dailyData: [DailyExpense] = []
    
    private let calendar = Calendar.current
    private let monthNames = ["Tháng 1", "Tháng 2", "Tháng 3", "Tháng 4", "Tháng 5", "Tháng 6",
                             "Tháng 7", "Tháng 8", "Tháng 9", "Tháng 10", "Tháng 11", "Tháng 12"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Text("Chi tiết theo ngày")
                        .font(.custom("SF Pro Text", size: 18))
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    // Placeholder for balance
                    Color.clear
                        .frame(width: 24, height: 24)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Month Filter
                        VStack(spacing: 12) {
                            HStack {
                                Text("Chọn tháng")
                                    .font(.custom("SF Pro Text", size: 16))
                                    .fontWeight(.medium)
                                
                                Spacer()
                            }
                            
                            HStack {
                                Button(action: { changeMonth(-1) }) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 16))
                                        .foregroundColor(.blue)
                                }
                                
                                Spacer()
                                
                                Text("\(monthNames[selectedMonth - 1]) \(selectedYear)")
                                    .font(.custom("SF Pro Text", size: 20))
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                Button(action: { changeMonth(1) }) {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 16))
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(8)
                        .padding(.horizontal, 20)
                        
                        // Daily Spending Summary
                        VStack(spacing: 16) {
                            HStack {
                                Text("Tổng quan tháng \(selectedMonth)")
                                    .font(.custom("SF Pro Text", size: 18))
                                    .fontWeight(.semibold)
                                
                                Spacer()
                            }
                            
                            let monthTotal = dailyData.reduce(0) { $0 + $1.amount }
                            let dayCount = dailyData.filter { $0.amount > 0 }.count
                            let avgDaily = dayCount > 0 ? monthTotal / Decimal(dayCount) : 0
                            
                            HStack(spacing: 20) {
                                VStack {
                                    Text("Tổng chi tiêu")
                                        .font(.custom("SF Pro Text", size: 14))
                                        .foregroundColor(.secondary)
                                    Text(formatVND(monthTotal))
                                        .font(.custom("SF Pro Text", size: 20))
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                }
                                
                                Spacer()
                                
                                VStack {
                                    Text("Trung bình/ngày")
                                        .font(.custom("SF Pro Text", size: 14))
                                        .foregroundColor(.secondary)
                                    Text(formatVND(avgDaily))
                                        .font(.custom("SF Pro Text", size: 20))
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding(16)
                        .background(Color(hex: "2C2C2C"))
                        .cornerRadius(8)
                        .padding(.horizontal, 20)
                        
                        // Daily Chart
                        VStack(spacing: 16) {
                            HStack {
                                Text("Chi tiêu theo ngày")
                                    .font(.custom("SF Pro Text", size: 18))
                                    .fontWeight(.semibold)
                                
                                Spacer()
                            }
                            
                            // Chart Area
                            GeometryReader { geometry in
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(alignment: .bottom, spacing: 4) {
                                        ForEach(dailyData, id: \.day) { dayData in
                                            VStack(spacing: 4) {
                                                // Amount label
                                                Text(dayData.amount > 0 ? "\(formatAmount(dayData.amount))" : "")
                                                    .font(.custom("SF Pro Text", size: 8))
                                                    .foregroundColor(.secondary)
                                                    .frame(height: 10)
                                                
                                                // Bar
                                                let maxAmount = dailyData.map { $0.amount }.max() ?? 1
                                                let barHeight = dayData.amount > 0 ? 
                                                    max(Double(dayData.amount / maxAmount) * 140, 8) : 8
                                                let barColor = dayData.amount > avgDaily ? Color.red : Color.blue
                                                
                                                Rectangle()
                                                    .fill(dayData.amount > 0 ? barColor : Color.gray.opacity(0.3))
                                                    .frame(width: 16, height: barHeight)
                                                    .cornerRadius(2)
                                                
                                                // Day label
                                                Text("\(dayData.day)")
                                                    .font(.custom("SF Pro Text", size: 10))
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 8)
                                    .frame(minWidth: geometry.size.width)
                                }
                            }
                            .frame(height: 180)
                            
                            // Chart Legend
                            HStack {
                                Text("Ngày")
                                    .font(.custom("SF Pro Text", size: 12))
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                HStack(spacing: 16) {
                                    HStack(spacing: 4) {
                                        Rectangle()
                                            .fill(Color.blue)
                                            .frame(width: 12, height: 4)
                                            .cornerRadius(2)
                                        Text("Dưới TB")
                                            .font(.custom("SF Pro Text", size: 12))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    HStack(spacing: 4) {
                                        Rectangle()
                                            .fill(Color.red)
                                            .frame(width: 12, height: 4)
                                            .cornerRadius(2)
                                        Text("Trên TB")
                                            .font(.custom("SF Pro Text", size: 12))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(8)
                        .padding(.horizontal, 20)
                        
                        // Top Spending Days
                        VStack(spacing: 12) {
                            HStack {
                                Text("Ngày chi tiêu cao nhất")
                                    .font(.custom("SF Pro Text", size: 18))
                                    .fontWeight(.semibold)
                                
                                Spacer()
                            }
                            
                            let topDays = dailyData
                                .filter { $0.amount > 0 }
                                .sorted { $0.amount > $1.amount }
                                .prefix(5)
                            
                            ForEach(Array(topDays.enumerated()), id: \.element.day) { index, dayData in
                                HStack {
                                    Text("\(index + 1)")
                                        .font(.custom("SF Pro Text", size: 14))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(width: 24, height: 24)
                                        .background(Color.blue)
                                        .clipShape(Circle())
                                    
                                    Text("Ngày \(dayData.day)")
                                        .font(.custom("SF Pro Text", size: 16))
                                        .fontWeight(.medium)
                                    
                                    Spacer()
                                    
                                    Text(formatVND(dayData.amount))
                                        .font(.custom("SF Pro Text", size: 16))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                }
                                .padding(.vertical, 8)
                                
                                if index < topDays.count - 1 {
                                    Divider()
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(8)
                        .padding(.horizontal, 20)
                    }
                }
            }
            .background(Color(hex: "F5F6F7"))
            .navigationBarHidden(true)
            .onAppear {
                generateMockData()
            }
            .onChange(of: selectedMonth) { _ in
                generateMockData()
            }
            .onChange(of: selectedYear) { _ in
                generateMockData()
            }
        }
    }
    
    private func changeMonth(_ delta: Int) {
        let currentDate = calendar.date(from: DateComponents(year: selectedYear, month: selectedMonth)) ?? Date()
        if let newDate = calendar.date(byAdding: .month, value: delta, to: currentDate) {
            selectedMonth = calendar.component(.month, from: newDate)
            selectedYear = calendar.component(.year, from: newDate)
        }
    }
    
    private func generateMockData() {
        let daysInMonth = calendar.range(of: .day, in: .month, 
                                       for: calendar.date(from: DateComponents(year: selectedYear, month: selectedMonth)) ?? Date())?.count ?? 30
        
        dailyData = (1...daysInMonth).map { day in
            // Generate realistic daily spending data
            let baseAmount = Double.random(in: 0...500000) // 0 to 500k VND
            let hasSpending = Double.random(in: 0...1) > 0.3 // 70% chance of spending
            let amount = hasSpending ? Decimal(baseAmount) : 0
            
            return DailyExpense(day: day, amount: amount)
        }
    }
    
    private func formatVND(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "VND"
        formatter.currencySymbol = "₫"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "₫0"
    }
    
    private func formatAmount(_ amount: Decimal) -> String {
        let value = Double(truncating: amount as NSDecimalNumber)
        if value >= 1000000 {
            return String(format: "%.1fM", value / 1000000)
        } else if value >= 1000 {
            return String(format: "%.0fK", value / 1000)
        } else {
            return String(format: "%.0f", value)
        }
    }
}

struct DailyExpense {
    let day: Int
    let amount: Decimal
}

// Color extension for hex colors
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

struct DailyStatsDetailView_Previews: PreviewProvider {
    static var previews: some View {
        DailyStatsDetailView()
    }
}