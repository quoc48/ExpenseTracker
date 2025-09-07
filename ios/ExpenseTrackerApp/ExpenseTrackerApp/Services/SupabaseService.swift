import Foundation
import Supabase

@MainActor
class SupabaseService: ObservableObject {
    static let shared = SupabaseService()
    
    private let client: SupabaseClient
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {
        // Initialize Supabase client with configuration
        self.client = SupabaseClient(
            supabaseURL: URL(string: AppConfig.supabaseURL)!,
            supabaseKey: AppConfig.supabaseAnonKey
        )
        
        // Check initial auth state
        Task {
            await checkAuthState()
        }
    }
    
    // MARK: - Authentication
    
    func checkAuthState() async {
        do {
            let session = try await client.auth.session
            self.currentUser = session.user
            self.isAuthenticated = true
        } catch {
            self.currentUser = nil
            self.isAuthenticated = false
        }
    }
    
    func signIn(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let session = try await client.auth.signIn(
                email: email,
                password: password
            )
            
            self.currentUser = session.user
            self.isAuthenticated = true
            
        } catch {
            self.errorMessage = error.localizedDescription
            throw error
        }
        
        isLoading = false
    }
    
    func signUp(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let session = try await client.auth.signUp(
                email: email,
                password: password
            )
            
            self.currentUser = session.user
            self.isAuthenticated = true
            
        } catch {
            self.errorMessage = error.localizedDescription
            throw error
        }
        
        isLoading = false
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
        self.currentUser = nil
        self.isAuthenticated = false
    }
    
    // MARK: - Database Access
    
    var database: SupabaseClient {
        return client
    }
    
    // MARK: - Error Handling
    
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Helper Extensions
extension SupabaseService {
    var userId: UUID? {
        guard let user = currentUser else { return nil }
        return UUID(uuidString: user.id.uuidString)
    }
    
    var isSignedIn: Bool {
        return currentUser != nil && isAuthenticated
    }
}