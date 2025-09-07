import SwiftUI

struct DateRangePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var startDate: Date
    @Binding var endDate: Date
    @State private var tempStartDate: Date
    @State private var tempEndDate: Date
    @State private var selectedPreset: DatePreset = .custom
    
    enum DatePreset: String, CaseIterable {
        case today = "Hôm nay"
        case yesterday = "Hôm qua"
        case thisWeek = "Tuần này"
        case lastWeek = "Tuần trước"
        case thisMonth = "Tháng này"
        case lastMonth = "Tháng trước"
        case last30Days = "30 ngày qua"
        case last90Days = "90 ngày qua"
        case thisYear = "Năm này"
        case lastYear = "Năm trước"
        case custom = "Tùy chỉnh"
        
        func dateRange() -> (start: Date, end: Date) {
            let calendar = Calendar.current
            let now = Date()
            
            switch self {
            case .today:
                let start = calendar.startOfDay(for: now)
                let end = calendar.date(byAdding: .day, value: 1, to: start) ?? now
                return (start, end)
                
            case .yesterday:
                let yesterday = calendar.date(byAdding: .day, value: -1, to: now) ?? now
                let start = calendar.startOfDay(for: yesterday)
                let end = calendar.date(byAdding: .day, value: 1, to: start) ?? yesterday
                return (start, end)
                
            case .thisWeek:
                let start = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
                let end = calendar.date(byAdding: .weekOfYear, value: 1, to: start) ?? now
                return (start, end)
                
            case .lastWeek:
                let thisWeekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
                let lastWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: thisWeekStart) ?? now
                return (lastWeekStart, thisWeekStart)
                
            case .thisMonth:
                let start = calendar.dateInterval(of: .month, for: now)?.start ?? now
                let end = calendar.date(byAdding: .month, value: 1, to: start) ?? now
                return (start, end)
                
            case .lastMonth:
                let thisMonthStart = calendar.dateInterval(of: .month, for: now)?.start ?? now
                let lastMonthStart = calendar.date(byAdding: .month, value: -1, to: thisMonthStart) ?? now
                let lastMonthEnd = thisMonthStart
                return (lastMonthStart, lastMonthEnd)
                
            case .last30Days:
                let start = calendar.date(byAdding: .day, value: -30, to: now) ?? now
                return (start, now)
                
            case .last90Days:
                let start = calendar.date(byAdding: .day, value: -90, to: now) ?? now
                return (start, now)
                
            case .thisYear:
                let start = calendar.dateInterval(of: .year, for: now)?.start ?? now
                let end = calendar.date(byAdding: .year, value: 1, to: start) ?? now
                return (start, end)
                
            case .lastYear:
                let thisYearStart = calendar.dateInterval(of: .year, for: now)?.start ?? now
                let lastYearStart = calendar.date(byAdding: .year, value: -1, to: thisYearStart) ?? now
                return (lastYearStart, thisYearStart)
                
            case .custom:
                return (now, now) // Will be overridden by custom dates
            }
        }
    }
    
    init(startDate: Binding<Date>, endDate: Binding<Date>) {
        self._startDate = startDate
        self._endDate = endDate
        self._tempStartDate = State(initialValue: startDate.wrappedValue)
        self._tempEndDate = State(initialValue: endDate.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Quick presets section
                Section(header: Text("Khoảng Thời Gian Nhanh")) {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(DatePreset.allCases.filter { $0 != .custom }, id: \.rawValue) { preset in
                            PresetButton(
                                preset: preset,
                                isSelected: selectedPreset == preset,
                                action: {
                                    selectedPreset = preset
                                    let range = preset.dateRange()
                                    tempStartDate = range.start
                                    tempEndDate = range.end
                                }
                            )
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Custom date range section
                Section(header: Text("Tùy Chỉnh Khoảng Thời Gian")) {
                    DatePicker(
                        "Từ ngày",
                        selection: $tempStartDate,
                        displayedComponents: .date
                    )
                    .onChange(of: tempStartDate) { _, newValue in
                        selectedPreset = .custom
                        // Ensure end date is not before start date
                        if newValue > tempEndDate {
                            tempEndDate = newValue
                        }
                    }
                    
                    DatePicker(
                        "Đến ngày",
                        selection: $tempEndDate,
                        in: tempStartDate...,
                        displayedComponents: .date
                    )
                    .onChange(of: tempEndDate) { _, _ in
                        selectedPreset = .custom
                    }
                    
                    // Date range summary
                    HStack {
                        Text("Khoảng thời gian:")
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(dateRangeSummary)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                }
                
                // Statistics preview section
                Section(header: Text("Thông Tin Khoảng Thời Gian")) {
                    StatisticRow(
                        title: "Số ngày",
                        value: "\(dayCount) ngày"
                    )
                    
                    StatisticRow(
                        title: "Số tuần",
                        value: "\(weekCount) tuần"
                    )
                    
                    StatisticRow(
                        title: "Số tháng",
                        value: "\(monthCount) tháng"
                    )
                    
                    if dayCount > 365 {
                        StatisticRow(
                            title: "Cảnh báo",
                            value: "Khoảng thời gian quá dài"
                        )
                        .foregroundColor(.orange)
                    }
                }
            }
            .navigationTitle("Chọn Khoảng Thời Gian")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Hủy") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Áp Dụng") {
                        startDate = tempStartDate
                        endDate = tempEndDate
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var dateRangeSummary: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "vi_VN")
        
        let startString = formatter.string(from: tempStartDate)
        let endString = formatter.string(from: tempEndDate)
        
        return "\(startString) - \(endString)"
    }
    
    private var dayCount: Int {
        Calendar.current.dateComponents([.day], from: tempStartDate, to: tempEndDate).day ?? 0
    }
    
    private var weekCount: Int {
        max(dayCount / 7, 1)
    }
    
    private var monthCount: Int {
        Calendar.current.dateComponents([.month], from: tempStartDate, to: tempEndDate).month ?? 1
    }
}

// MARK: - Supporting Views

struct PresetButton: View {
    let preset: DateRangePickerView.DatePreset
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(preset.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                
                Text(presetDescription)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .foregroundColor(isSelected ? .blue : .primary)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var presetDescription: String {
        let range = preset.dateRange()
        let dayCount = Calendar.current.dateComponents([.day], from: range.start, to: range.end).day ?? 0
        
        switch preset {
        case .today, .yesterday:
            return "1 ngày"
        case .thisWeek, .lastWeek:
            return "7 ngày"
        case .last30Days:
            return "30 ngày"
        case .last90Days:
            return "90 ngày"
        default:
            return "\(dayCount) ngày"
        }
    }
}

struct StatisticRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Date Range Filter Components

struct DateRangeFilter: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    @State private var showingDatePicker = false
    
    var body: some View {
        Button(action: {
            showingDatePicker = true
        }) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                
                Text(dateRangeText)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .sheet(isPresented: $showingDatePicker) {
            DateRangePickerView(startDate: $startDate, endDate: $endDate)
        }
    }
    
    private var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "vi_VN")
        
        let calendar = Calendar.current
        
        // Check for common presets
        if calendar.isDate(startDate, inSameDayAs: Date()) && 
           calendar.isDate(endDate, inSameDayAs: calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()) {
            return "Hôm nay"
        }
        
        if calendar.isDateInThisWeek(startDate) && calendar.isDateInThisWeek(endDate) {
            return "Tuần này"
        }
        
        if calendar.isDateInThisMonth(startDate) && calendar.isDateInThisMonth(endDate) {
            return "Tháng này"
        }
        
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
}

struct QuickDateFilters: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    @State private var selectedFilter: String = "Tháng này"
    
    private let quickFilters = [
        "Hôm nay", "Tuần này", "Tháng này", "3 tháng", "Năm này", "Tùy chỉnh"
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(quickFilters, id: \.self) { filter in
                    QuickFilterButton(
                        title: filter,
                        isSelected: selectedFilter == filter,
                        action: {
                            selectedFilter = filter
                            applyQuickFilter(filter)
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func applyQuickFilter(_ filter: String) {
        let calendar = Calendar.current
        let now = Date()
        
        switch filter {
        case "Hôm nay":
            startDate = calendar.startOfDay(for: now)
            endDate = calendar.date(byAdding: .day, value: 1, to: startDate) ?? now
            
        case "Tuần này":
            startDate = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            endDate = calendar.date(byAdding: .weekOfYear, value: 1, to: startDate) ?? now
            
        case "Tháng này":
            startDate = calendar.dateInterval(of: .month, for: now)?.start ?? now
            endDate = calendar.date(byAdding: .month, value: 1, to: startDate) ?? now
            
        case "3 tháng":
            startDate = calendar.date(byAdding: .month, value: -3, to: now) ?? now
            endDate = now
            
        case "Năm này":
            startDate = calendar.dateInterval(of: .year, for: now)?.start ?? now
            endDate = calendar.date(byAdding: .year, value: 1, to: startDate) ?? now
            
        default:
            break
        }
    }
}

struct QuickFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

// MARK: - Enhanced Expense List with Date Filtering

struct EnhancedExpenseListView: View {
    @StateObject private var expenseService = ExpenseService.shared
    @State private var expenses: [Expense] = []
    @State private var startDate = Calendar.current.dateInterval(of: .month, for: Date())?.start ?? Date()
    @State private var endDate = Date()
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Date range filter
                VStack(spacing: 12) {
                    QuickDateFilters(startDate: $startDate, endDate: $endDate)
                        .onChange(of: startDate) { _, _ in loadExpenses() }
                        .onChange(of: endDate) { _, _ in loadExpenses() }
                    
                    DateRangeFilter(startDate: $startDate, endDate: $endDate)
                }
                .padding()
                
                // Expense list
                if isLoading {
                    Spacer()
                    ProgressView("Đang tải...")
                    Spacer()
                } else {
                    List {
                        Section(header: Text("Chi Tiêu (\(expenses.count) giao dịch)")) {
                            ForEach(expenses) { expense in
                                ExpenseRowView(expense: expense)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Chi Tiêu Nâng Cao")
            .refreshable {
                loadExpenses()
            }
        }
        .task {
            loadExpenses()
        }
    }
    
    private func loadExpenses() {
        Task {
            isLoading = true
            do {
                let loadedExpenses = try await expenseService.getExpenses(
                    startDate: startDate,
                    endDate: endDate
                )
                await MainActor.run {
                    self.expenses = loadedExpenses
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
}

#Preview {
    DateRangePickerView(
        startDate: .constant(Date()),
        endDate: .constant(Date())
    )
}