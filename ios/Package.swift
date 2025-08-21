// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ExpenseTracker",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .executable(
            name: "ExpenseTrackerApp",
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
        .executableTarget(
            name: "ExpenseTracker",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift")
            ],
            path: "ExpenseTracker"
        )
    ]
)