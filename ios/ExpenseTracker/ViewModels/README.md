# ViewModels Directory

This directory contains MVVM view models for managing UI state and business logic.

## Planned ViewModels

### Core ViewModels
- `BudgetViewModel.swift` - Budget management state
- `ExpenseViewModel.swift` - Expense entry and listing
- `CategoryViewModel.swift` - Category management
- `ReportViewModel.swift` - Report generation and filtering

### Feature ViewModels
- `AuthViewModel.swift` - Authentication state management
- `ReceiptScanViewModel.swift` - Receipt scanning workflow
- `SettingsViewModel.swift` - App settings and preferences
- `DashboardViewModel.swift` - Main dashboard state

## Implementation Notes
- All ViewModels inherit from `ObservableObject`
- Use `@Published` for properties that trigger UI updates
- Implement proper loading states (`isLoading`, `isSubmitting`)
- Include error handling with user-friendly error messages
- Support async operations with proper cancellation
- Follow single responsibility principle - one feature per ViewModel