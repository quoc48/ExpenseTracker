import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "dollarsign.circle")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("ExpenseTracker")
                    .font(.title)
                    .fontWeight(.semibold)
                
                Text("Personal expense tracking made simple")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Expense Tracker")
        }
    }
}

#Preview {
    ContentView()
}