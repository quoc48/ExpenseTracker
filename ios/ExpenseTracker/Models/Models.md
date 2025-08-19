# Data Models

This directory contains the iOS data models that match the existing Supabase database schema.

## ✅ Implemented Models

### Category.swift
- **Purpose**: Expense categorization matching existing Vietnamese categories
- **Database Table**: `categories` (14 records)
- **Key Features**:
  - Vietnamese localization support
  - Icon and color support for UI
  - Default vs custom category distinction
  - Sample data for testing

### Expense.swift  
- **Purpose**: Individual expense entries with rich metadata
- **Database Table**: `expenses`
- **Key Features**:
  - Vietnamese currency formatting (VND)
  - Advanced features (AI embeddings, metadata)
  - Denormalized category data for performance
  - Date/time helpers for filtering
  - Sample Vietnamese expense data

## 🔄 Future Models

### UserSettings.swift (Planned)
- **Status**: Deferred - table structure unknown
- **Plan**: Add when we understand the user_settings table schema

## 📊 Model Features

- All models conform to `Codable`, `Identifiable`, and `Hashable`
- Proper `CodingKeys` mapping for snake_case database fields
- Vietnamese localization and currency support
- Sample data for UI testing and development
- Display helpers for formatting amounts and dates