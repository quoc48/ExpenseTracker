import Foundation

enum AppConfig {
    private static let configPlist: [String: Any] = {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            fatalError("Config.plist not found or invalid format")
        }
        return plist
    }()
    
    static var supabaseURL: String {
        guard let url = configPlist["SupabaseURL"] as? String else {
            fatalError("SupabaseURL not found in Config.plist")
        }
        return url
    }
    
    static var supabaseAnonKey: String {
        guard let key = configPlist["SupabaseAnonKey"] as? String else {
            fatalError("SupabaseAnonKey not found in Config.plist")
        }
        return key
    }
    
    static var appVersion: String {
        return configPlist["AppVersion"] as? String ?? "1.0.0"
    }
    
    static var environment: String {
        return configPlist["Environment"] as? String ?? "Development"
    }
}