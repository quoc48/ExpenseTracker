# Services Directory

This directory contains service classes for external integrations and business logic.

## Planned Services

### Core Services
- `SupabaseService.swift` - Main Supabase client and configuration
- `AuthService.swift` - User authentication and session management
- `DatabaseService.swift` - Database operations and caching
- `SyncService.swift` - Real-time synchronization logic

### Feature Services  
- `BudgetService.swift` - Budget management operations
- `ExpenseService.swift` - Expense CRUD operations
- `CategoryService.swift` - Category management
- `ReportService.swift` - Data aggregation and reporting
- `ReceiptScanningService.swift` - Vision framework integration

### Utility Services
- `NetworkService.swift` - Network connectivity monitoring
- `ErrorService.swift` - Centralized error handling
- `ValidationService.swift` - Data validation logic

## Implementation Notes
- Use `async/await` for all network operations
- Implement proper error handling with user-friendly messages
- Include retry logic for failed network requests
- Support offline mode with local caching
- Follow repository pattern for data access