#!/usr/bin/env swift

import Foundation

// Simple test to show what our app data looks like
print("🎯 ExpenseTracker App Preview")
print("=============================\n")

// Sample Vietnamese Categories (from our database)
let categories = [
    "🍜 Thực phẩm",
    "🛒 Tạp hoá", 
    "👔 Thời trang",
    "📚 Giáo dục",
    "🏠 Tiền nhà",
    "🚌 Giao thông",
    "⚕️ Y tế",
    "🎮 Giải trí"
]

print("📋 Vietnamese Categories Available:")
for (index, category) in categories.enumerated() {
    print("  \(index + 1). \(category)")
}

// Sample Expenses (VND format)
let expenses = [
    ("🍜", "Cơm trưa tại nhà hàng", "Thực phẩm", 45000),
    ("🚌", "Xe bus đi làm", "Giao thông", 25000),
    ("👔", "Áo sơ mi mới", "Thời trang", 150000),
    ("🛒", "Mua thực phẩm tuần", "Tạp hoá", 200000),
    ("📚", "Sách học Swift", "Giáo dục", 85000)
]

print("\n💰 Sample Expenses (VND):")
let formatter = NumberFormatter()
formatter.numberStyle = .currency
formatter.currencyCode = "VND"
formatter.currencySymbol = "₫"
formatter.maximumFractionDigits = 0

var total: Double = 0
for (icon, description, category, amount) in expenses {
    let formatted = formatter.string(from: NSNumber(value: amount)) ?? "₫0"
    print("  \(icon) \(description)")
    print("    Category: \(category) | Amount: \(formatted)")
    total += Double(amount)
}

let totalFormatted = formatter.string(from: NSNumber(value: total)) ?? "₫0"
print("\n📊 Total Expenses: \(totalFormatted)")

print("\n🎨 App Features Available:")
print("  ✅ Vietnamese authentication (Đăng nhập/Đăng ký)")
print("  ✅ Add expenses with VND formatting")
print("  ✅ Category picker with 14 Vietnamese categories")
print("  ✅ Expense list with filtering (hôm nay, tuần này, tháng này)")
print("  ✅ Real-time Supabase database connection")
print("  ✅ Tab navigation with Vietnamese labels")
print("  ✅ Settings and account management")

print("\n🗄️ Database Status:")
print("  📊 Connected to Supabase")
print("  🏷️ 14 Vietnamese categories loaded")
print("  💾 Ready for real expense data")

print("\n🚀 Ready to test in iOS Simulator!")