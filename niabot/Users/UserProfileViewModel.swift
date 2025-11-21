import SwiftUI

class UserProfileViewModel: ObservableObject {
    @Published var user = UserProfile()
    @Published var editingName = ""
    @Published var editingEmail = ""
    
    init() {
        loadUserData()
    }
    
    private func loadUserData() {
        // Load email first
        if let savedEmail = UserDefaults.standard.string(forKey: "userEmail") {
            user.email = savedEmail
            
            // Check if user has a custom name saved
            if let savedName = UserDefaults.standard.string(forKey: "userName") {
                user.name = savedName
            } else {
                // Extract name from email if no custom name is set
                user.name = extractNameFromEmail(savedEmail)
            }
        }
        
        user.darkModeEnabled = UserDefaults.standard.bool(forKey: "darkModeEnabled")
        user.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        user.soundEnabled = UserDefaults.standard.bool(forKey: "soundEnabled")
    }
    
    // Extract name from email (e.g., "john.doe@example.com" -> "John Doe")
    private func extractNameFromEmail(_ email: String) -> String {
        // Get the part before @
        let username = email.components(separatedBy: "@").first ?? email
        
        // Split by common separators (., _, -)
        let nameParts = username.components(separatedBy: CharacterSet(charactersIn: "._-"))
        
        // Capitalize each part and join with space
        let formattedName = nameParts
            .map { $0.capitalized }
            .joined(separator: " ")
        
        return formattedName.isEmpty ? "User" : formattedName
    }
    
    func updateName() {
        user.name = editingName
        UserDefaults.standard.set(editingName, forKey: "userName")
    }
    
    func updateEmail() {
        user.email = editingEmail
        UserDefaults.standard.set(editingEmail, forKey: "userEmail")
        
        // If user changes email, update the name extraction
        if UserDefaults.standard.string(forKey: "userName") == nil {
            user.name = extractNameFromEmail(editingEmail)
        }
    }
    
    func applyDarkMode() {
        UserDefaults.standard.set(user.darkModeEnabled, forKey: "darkModeEnabled")
    }
    
    func savePreferences() {
        UserDefaults.standard.set(user.notificationsEnabled, forKey: "notificationsEnabled")
        UserDefaults.standard.set(user.soundEnabled, forKey: "soundEnabled")
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "darkModeEnabled")
        UserDefaults.standard.removeObject(forKey: "notificationsEnabled")
        UserDefaults.standard.removeObject(forKey: "soundEnabled")
    }
}
