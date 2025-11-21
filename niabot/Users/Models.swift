import Foundation



struct UserProfile: Identifiable {
    let id = UUID()
    var name: String = "User"
    var email: String = "user@example.com"
    var plan = "Free Plan"
    var totalChats = 24
    var totalMessages = 156
    var daysActive = 12
    var notificationsEnabled = true
    var darkModeEnabled = false
    var soundEnabled = true
}


