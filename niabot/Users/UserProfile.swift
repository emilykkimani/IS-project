import SwiftUI

struct UserProfileView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var profileVM = UserProfileViewModel()
    @State private var showingEditName = false
    @State private var showingEditEmail = false
    @State private var showingLogoutAlert = false
    @State private var showingResourcesView = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                    .navigationBarBackButtonHidden(true)
                ScrollView {
                    VStack(spacing: 24) {
                        ProfileHeader(user: profileVM.user)
                        StatsSection(user: profileVM.user)
                        AccountSettingsSection(
                            profileVM: profileVM,
                            showingEditName: $showingEditName,
                            showingEditEmail: $showingEditEmail
                        )
                        PreferencesSection(profileVM: profileVM)
                        SupportSection(showingResourcesView: $showingResourcesView)
                        LogoutButton(action: { showingLogoutAlert = true })
                    }
                    .padding()
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.purple)
                    }
                }
            }
            .alert("Edit Name", isPresented: $showingEditName) {
                TextField("Your name", text: $profileVM.editingName)
                Button("Cancel", role: .cancel) { }
                Button("Save") { profileVM.updateName() }
            }
            .alert("Edit Email", isPresented: $showingEditEmail) {
                TextField("Your email", text: $profileVM.editingEmail)
                Button("Cancel", role: .cancel) { }
                Button("Save") { profileVM.updateEmail() }
            }
            .alert("Logout", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    profileVM.logout()
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
            .navigationDestination(isPresented: $showingResourcesView) {
                NearbyResourcesView()
            }
        }
    }
}

// MARK: - Profile Components

struct ProfileHeader: View {
    let user: UserProfile
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.purple, Color.purple.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Text(String(user.name.prefix(1)).uppercased())
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text(user.name)
                .font(.title2.bold())
            
            Text(user.email)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
                
                Text(user.plan)
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct StatsSection: View {
    let user: UserProfile
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Usage Statistics")
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 12) {
                StatCard(icon: "bubble.left.and.bubble.right", title: "Total Chats", value: "\(user.totalChats)")
                StatCard(icon: "message.fill", title: "Messages", value: "\(user.totalMessages)")
                StatCard(icon: "calendar", title: "Days Active", value: "\(user.daysActive)")
            }
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.purple)
            
            Text(value)
                .font(.title3.bold())
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct AccountSettingsSection: View {
    @ObservedObject var profileVM: UserProfileViewModel
    @Binding var showingEditName: Bool
    @Binding var showingEditEmail: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Account Settings")
            
            SettingRow(
                icon: "person.fill",
                title: "Name",
                value: profileVM.user.name,
                action: {
                    profileVM.editingName = profileVM.user.name
                    showingEditName = true
                }
            )
            
            Divider().padding(.horizontal)
            
            SettingRow(
                icon: "envelope.fill",
                title: "Email",
                value: profileVM.user.email,
                action: {
                    profileVM.editingEmail = profileVM.user.email
                    showingEditEmail = true
                }
            )
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct PreferencesSection: View {
    @ObservedObject var profileVM: UserProfileViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Preferences")
            
            Toggle(isOn: $profileVM.user.notificationsEnabled) {
                HStack(spacing: 12) {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.purple)
                        .frame(width: 24)
                    
                    Text("Notifications")
                        .font(.subheadline.weight(.medium))
                }
            }
            .padding()
            .onChange(of: profileVM.user.notificationsEnabled) { _ in
                profileVM.savePreferences()
            }
            
            Divider().padding(.horizontal)
            
            Toggle(isOn: $profileVM.user.darkModeEnabled) {
                HStack(spacing: 12) {
                    Image(systemName: "moon.fill")
                        .foregroundColor(.purple)
                        .frame(width: 24)
                    
                    Text("Dark Mode")
                        .font(.subheadline.weight(.medium))
                }
            }
            .padding()
            .onChange(of: profileVM.user.darkModeEnabled) { _ in
                profileVM.applyDarkMode()
            }
            
            Divider().padding(.horizontal)
            
            Toggle(isOn: $profileVM.user.soundEnabled) {
                HStack(spacing: 12) {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundColor(.purple)
                        .frame(width: 24)
                    
                    Text("Sound Effects")
                        .font(.subheadline.weight(.medium))
                }
            }
            .padding()
            .onChange(of: profileVM.user.soundEnabled) { _ in
                profileVM.savePreferences()
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct SupportSection: View {
    @Binding var showingResourcesView: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Support & Resources")
            
            Button(action: { showingResourcesView = true }) {
                HStack(spacing: 12) {
                    Image(systemName: "location.fill")
                        .foregroundColor(.red)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Nearby Resources")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.primary)
                        Text("Find help centers near you")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .padding()
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
        }
        .padding()
        .padding(.bottom, -12)
    }
}

struct SettingRow: View {
    let icon: String
    let title: String
    let value: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.purple)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.primary)
                    Text(value)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding()
        }
    }
}

struct LogoutButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Logout")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.8))
                .cornerRadius(10)
        }
        .padding(.top, 8)
    }
}

#Preview {
    UserProfileView()
}

