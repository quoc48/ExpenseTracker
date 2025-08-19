// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ExpenseTracker",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "ExpenseTracker",
            targets: ["ExpenseTracker"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/supabase/supabase-swift",
            from: "2.5.1"
        )
    ],
    targets: [
        .target(
            name: "ExpenseTracker",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift")
            ],
            path: "ExpenseTracker"
        )
    ]
)