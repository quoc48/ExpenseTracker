# Views Directory

This directory contains SwiftUI views organized by feature area.

## ✅ Implemented Views

### Core Views
- **ContentView.swift** - Main app container with authentication routing
- **MainTabView.swift** - Tab navigation for authenticated users
- **TestConnectionView.swift** - Database connection testing interface

### Authentication Views
- **AuthenticationView.swift** - Login/signup with Vietnamese UI
  - Demo account support
  - Form validation and error handling
  - Supabase integration

### Expense Views
- **ExpenseListView.swift** - Complete expense management interface
  - Vietnamese categories integration
  - Period filtering (hôm nay, tuần này, tháng này)
  - Category filtering with chips
  - Summary statistics with VND formatting
  - Swipe-to-delete functionality

- **AddExpenseView.swift** - Manual expense entry form
  - VND currency input with formatting
  - Real-time category selection from database
  - Date picker with Vietnamese localization
  - Form validation and error handling

- **CategoryPickerView.swift** - Category selection interface
  - Grid layout with Vietnamese categories
  - Search functionality
  - Real database integration (14 existing categories)
  - Default vs custom category distinction

### Supporting Views
- **SettingsView.swift** - User account management
  - User info display
  - Sign out functionality
  - Account details

## 🔄 Planned Views

### Report Views
- `ReportsView.swift` - Analytics dashboard
- `MonthlyReportView.swift` - Budget vs actual comparison
- `CategoryReportView.swift` - Spending by category

### Budget Views
- `BudgetView.swift` - Monthly budget management
- `BudgetEditView.swift` - Budget creation and editing

## Implementation Features

### Vietnamese Localization
- All UI text in Vietnamese
- VND currency formatting (₫)
- Vietnamese date formatting
- Category names in Vietnamese

### Real Database Integration
- Live connection to existing Supabase categories
- Real-time expense CRUD operations
- Authentication state management
- Error handling with Vietnamese messages

### Modern SwiftUI Patterns
- NavigationStack for iOS 16+
- @StateObject for view model management
- Task/async for data loading
- Sheet presentations for modal views
- Refreshable for pull-to-refresh