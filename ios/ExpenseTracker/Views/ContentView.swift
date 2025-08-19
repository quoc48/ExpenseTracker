import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TestConnectionView()
                .tabItem {
                    Image(systemName: "network")
                    Text("Test")
                }
            
            Text("Expense Entry")
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("Add")
                }
            
            Text("Reports")
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Reports")
                }
            
            Text("Settings")
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

#Preview {
    ContentView()
}