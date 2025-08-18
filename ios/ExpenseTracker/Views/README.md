# Views Directory

This directory contains SwiftUI views organized by feature area.

## Planned View Structure

### Core Views
- `ContentView.swift` - Main app container (already created)
- `DashboardView.swift` - Main dashboard with expense summary
- `TabBarView.swift` - Main tab navigation

### Budget Views
- `BudgetView.swift` - Budget overview and management
- `BudgetEditView.swift` - Budget creation and editing
- `BudgetHistoryView.swift` - Historical budget data

### Expense Views
- `ExpenseListView.swift` - List of expenses with filtering
- `ExpenseDetailView.swift` - Individual expense details
- `AddExpenseView.swift` - Manual expense entry form
- `ExpenseRowView.swift` - Reusable expense list item

### Report Views
- `ReportsView.swift` - Report selection and overview
- `DailyReportView.swift` - Daily expense breakdown
- `MonthlyReportView.swift` - Monthly analysis with charts
- `YearlyReportView.swift` - Yearly trends and comparisons

### Receipt Scanning Views
- `ReceiptScannerView.swift` - Camera integration
- `ReceiptPreviewView.swift` - Scanned data verification
- `ReceiptEditView.swift` - Manual correction interface

### Supporting Views
- `AuthenticationView.swift` - Login and signup
- `SettingsView.swift` - App settings and preferences
- `CategoryPickerView.swift` - Category selection component
- `DatePickerView.swift` - Custom date selection
- `LoadingView.swift` - Loading state indicators
- `ErrorView.swift` - Error state handling

## Implementation Notes
- Keep views small and focused on single responsibilities
- Extract reusable components into separate view files
- Use view modifiers for consistent styling
- Implement proper navigation with NavigationStack
- Support accessibility with proper labels and hints
- Follow SwiftUI best practices for state management