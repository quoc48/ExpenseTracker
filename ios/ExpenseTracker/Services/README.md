# Services Directory

This directory contains service classes for Supabase integration and business logic.

## ✅ Implemented Services

### SupabaseService.swift
- **Purpose**: Main Supabase client and authentication management
- **Features**:
  - Singleton pattern for app-wide access
  - Authentication state management
  - Sign in/up/out functionality
  - Vietnamese error messages
  - Observable object for SwiftUI integration

### CategoryService.swift
- **Purpose**: Vietnamese category management
- **Features**:
  - Fetch 14 existing Vietnamese categories
  - Support for default vs custom categories
  - CRUD operations with proper user isolation
  - Vietnamese error messages and validation
  - Real-time local state updates

### ExpenseService.swift
- **Purpose**: Expense CRUD operations with advanced features
- **Features**:
  - Full expense lifecycle management
  - Vietnamese currency formatting (VND)
  - Date range filtering and statistics
  - Category-based filtering
  - Metadata and embedding support
  - Optimistic UI updates

## 🔄 Planned Services

### ReportService.swift
- Data aggregation and analytics
- Chart data preparation
- Export functionality

### ReceiptScanningService.swift
- Vision framework integration
- AI-powered receipt parsing

## Implementation Features
- All services use `@MainActor` for UI thread safety
- Comprehensive error handling with Vietnamese messages
- Observable objects for SwiftUI reactivity
- Proper user authentication checks
- Real-time local state management