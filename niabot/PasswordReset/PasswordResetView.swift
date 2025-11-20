import SwiftUI

struct PasswordResetView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = ForgotPasswordViewModelImpl(service: ForgotPasswordServiceImpl())
    
    var body: some View {
        VStack(spacing: 30) {
            
            // Title
            VStack(spacing: 8) {
                Text("Forgot Password?")
                    .font(.largeTitle).bold()
                    .foregroundColor(.purple)
                Text("Enter your email and we’ll send you a link to reset your password.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // Email field
            TextField("Email address", text: $vm.email)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding(.horizontal)

            // Reset button
            Button(action: {
                vm.sendPasswordResetRequest()
                
                // Auto-dismiss on success
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    if vm.isSuccess {
                        dismiss()
                    }
                }
            }) {
                Text("Send Reset Link")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(radius: 4)
            }
            .padding(.horizontal)

            // Feedback message
            if let message = vm.message {
                Text(message)
                    .foregroundColor(vm.isSuccess ? .green : .red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .padding(.top, 50)
    }
}

