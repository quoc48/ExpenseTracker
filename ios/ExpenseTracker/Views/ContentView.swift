import SwiftUI

struct ContentView: View {
    @StateObject private var supabaseService = SupabaseService.shared
    
    var body: some View {
        Group {
            if supabaseService.isAuthenticated {
                MainTabView()
            } else {
                AuthenticationView()
            }
        }
        .task {
            await supabaseService.checkAuthState()
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            ExpenseListView()
                .tabItem {
                    Image(systemName: "creditcard")
                    Text("Chi Tiêu")
                }
            
            TestConnectionView()
                .tabItem {
                    Image(systemName: "network")
                    Text("Test")
                }
            
            Text("Báo cáo")
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Báo Cáo")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Cài Đặt")
                }
        }
    }
}

struct SettingsView: View {
    @StateObject private var supabaseService = SupabaseService.shared
    
    var body: some View {
        NavigationStack {
            List {
                Section("Tài khoản") {
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(supabaseService.currentUser?.email ?? "N/A")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("User ID")
                        Spacer()
                        Text(supabaseService.userId?.uuidString.prefix(8) ?? "N/A")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                
                Section {
                    Button("Đăng xuất") {
                        Task {
                            try await supabaseService.signOut()
                        }
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Cài Đặt")
        }
    }
}

#Preview {
    ContentView()
}