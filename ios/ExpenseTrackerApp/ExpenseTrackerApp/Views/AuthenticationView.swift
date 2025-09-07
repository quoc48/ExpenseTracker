import SwiftUI

struct AuthenticationView: View {
    @StateObject private var supabaseService = SupabaseService.shared
    
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var showingError = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("ExpenseTracker")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Quản lý chi tiêu cá nhân")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Auth Form
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    SecureField("Mật khẩu", text: $password)
                        .textFieldStyle(.roundedBorder)
                    
                    Button(action: authenticate) {
                        HStack {
                            if supabaseService.isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .tint(.white)
                            }
                            
                            Text(isSignUp ? "Đăng ký" : "Đăng nhập")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .disabled(email.isEmpty || password.isEmpty || supabaseService.isLoading)
                    
                    // Toggle Sign Up/Sign In
                    Button(action: {
                        isSignUp.toggle()
                        supabaseService.clearError()
                    }) {
                        Text(isSignUp ? "Đã có tài khoản? Đăng nhập" : "Chưa có tài khoản? Đăng ký")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 32)
                
                // Demo Account
                VStack(spacing: 8) {
                    Text("Hoặc sử dụng tài khoản demo:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button("Đăng nhập Demo") {
                        email = "demo@expensetracker.com"
                        password = "demo123456"
                        Task {
                            try await supabaseService.signIn(email: email, password: password)
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                .padding(.top, 16)
                
                Spacer()
            }
            .navigationBarHidden(true)
            .alert("Lỗi", isPresented: $showingError) {
                Button("OK") {
                    supabaseService.clearError()
                }
            } message: {
                Text(supabaseService.errorMessage ?? "Đã xảy ra lỗi")
            }
            .onChange(of: supabaseService.errorMessage) { _, newValue in
                showingError = newValue != nil
            }
        }
    }
    
    private func authenticate() {
        Task {
            do {
                if isSignUp {
                    try await supabaseService.signUp(email: email, password: password)
                } else {
                    try await supabaseService.signIn(email: email, password: password)
                }
            } catch {
                // Error handling is managed by SupabaseService
            }
        }
    }
}

#Preview {
    AuthenticationView()
}