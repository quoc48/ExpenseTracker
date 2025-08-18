# Models Directory

This directory contains the data models for the ExpenseTracker app.

## Planned Models

### Core Data Models
- `Budget.swift` - Monthly budget management
- `Expense.swift` - Individual expense entries  
- `Category.swift` - Expense categorization
- `User.swift` - User profile and settings

### Supporting Models
- `ExpenseFilter.swift` - Filtering and search criteria
- `ReportData.swift` - Aggregated data for reports
- `ReceiptData.swift` - Parsed receipt information

## Implementation Notes
- All models will conform to `Codable` for Supabase integration
- Use `UUID` for primary keys to match PostgreSQL
- Include proper date handling for timezone considerations
- Add validation logic for required fields