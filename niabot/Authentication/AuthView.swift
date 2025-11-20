import SwiftUI

struct AuthView: View {
    // IMPORTANT: these come from parent (ContentView)
    @Binding var needsOTP: Bool
    @Binding var isAuthenticated: Bool

    @State private var selectedTab = "Login"
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack {
                Text(selectedTab == "Login" ? "Welcome Back" : "Get Started Now")
                    .font(.title)
                    .bold()
                    .padding(.top, 50)

                Text(selectedTab == "Login" ? "Login to access your account" : "Create an account to explore our app")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)

                // Segmented control
                HStack {
                    Button(action: { withAnimation { selectedTab = "Login" } }) {
                        Text("Log In")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedTab == "Login" ? Color.purple : Color.clear)
                            .foregroundColor(selectedTab == "Login" ? .white : .gray)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                    }

                    Button(action: { withAnimation { selectedTab = "Sign Up" } }) {
                        Text("Sign Up")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedTab == "Sign Up" ? Color.purple : Color.clear)
                            .foregroundColor(selectedTab == "Sign Up" ? .white : .gray)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                    }
                }
                .padding(5)
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .padding(.horizontal, 40)
                .padding(.bottom, 20)

                if selectedTab == "Login" {
                    loginForm
                } else {
                    signUpForm
                }

                Spacer()
            }
            .padding()
            
            // 🔥 ADD THIS NAVIGATION LINK FOR OTP FLOW
            .background(
                NavigationLink(
                    destination: AuthFlowView(isAuthenticated: $isAuthenticated),
                    isActive: $needsOTP,
                    label: { EmptyView() }
                )
                .hidden()
            )
        }
    }

    // MARK: - Login Form
    private var loginForm: some View {
        VStack(spacing: 15) {
            CustomTextField(placeholder: "Email", text: $email)
            CustomSecureField(placeholder: "Password", text: $password)

            PurpleButton(title: "Log In", action: loginUser)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 3)
            }

            NavigationLink(destination: PasswordResetView()) {
                Text("Forgot Password?")
                    .font(.footnote)
                    .foregroundColor(.blue)
                    .padding(.top, 5)
            }

            SocialButtons()
        }
    }

    // MARK: - Sign Up Form
    private var signUpForm: some View {
        VStack(spacing: 15) {
            HStack {
                CustomTextField(placeholder: "First Name", text: $firstName)
                CustomTextField(placeholder: "Last Name", text: $lastName)
            }

            CustomTextField(placeholder: "Email", text: $email)
            CustomSecureField(placeholder: "Set Password", text: $password)
            CustomSecureField(placeholder: "Confirm Password", text: $confirmPassword)

            PurpleButton(title: "Sign Up", action: registerUser)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 5)
            }

            SocialButtons()
        }
    }

    // MARK: - Auth Functions
    private func loginUser() {
        Task {
            do {
                try await AuthenticationManager.shared.loginUser(email: email, password: password)
                // This will trigger the NavigationLink to AuthFlowView
                DispatchQueue.main.async {
                    needsOTP = true
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func registerUser() {
        if password != confirmPassword {
            errorMessage = "Passwords do not match"
            return
        }

        Task {
            do {
                try await AuthenticationManager.shared.createUser(email: email, password: password)
               
                DispatchQueue.main.async {
                    needsOTP = true
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - Reusable components (unchanged)
struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
    }
}

struct CustomSecureField: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        SecureField(placeholder, text: $text)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
    }
}

struct PurpleButton: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple)
                .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

struct SocialButtons: View {
    var body: some View {
        VStack {
            HStack {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray.opacity(0.5))

                Text("Or Sign In With")
                    .foregroundColor(.gray)
                    .font(.subheadline)

                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray.opacity(0.5))
            }
            .padding(.horizontal)
            .padding(.top, 20)

            HStack {
                Button(action: { print("Google login tapped") }) {
                    HStack {
                        Image(systemName: "globe")
                        Text("Google")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                }

                Button(action: { print("Facebook login tapped") }) {
                    HStack {
                        Image(systemName: "f.circle.fill")
                        Text("Facebook")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
        }
    }
}

// MARK: - Preview
struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        // pass constants so preview compiles
        AuthView(needsOTP: .constant(false), isAuthenticated: .constant(false))
    }
}
