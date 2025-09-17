import SwiftUI

// MARK: - Flow Controller
struct AuthFlowView: View {
    @Binding var isAuthenticated: Bool
    
    @StateObject private var viewModel = OTPViewModel()
    @State private var step: Step = .send
    @State private var email = ""
    @State private var otpDigits: [String] = Array(repeating: "", count: 6)
    
    // Cooldowns
    @State private var buttonCooldown = 0
    @State private var cooldownTimer: Timer?
    @State private var otpExpiryCountdown = 120
    @State private var expiryTimer: Timer?
    
    // Focus for OTP input
    @FocusState private var focusedIndex: Int?
    
    // 🔥 ADD THIS - Navigation control
    @State private var navigateToChatbot = false
    
    enum Step {
        case send, verify
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    switch step {
                    case .send:
                        sendOTPView
                    case .verify:
                        verifyOTPView
                    }
                }
                .padding()
                .navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
                
                // 🔥 ADD THIS NAVIGATION LINK (HIDDEN)
                NavigationLink(
                    destination: ChatbotView(),
                    isActive: $navigateToChatbot,
                    label: { EmptyView() }
                )
                .hidden()
            }
        }
        .onDisappear {
            cooldownTimer?.invalidate()
            expiryTimer?.invalidate()
        }
    }
}

// MARK: - SEND OTP Screen
extension AuthFlowView {
    private var sendOTPView: some View {
        VStack {
            Text("Two-Factor Authentication")
                .font(.title.bold())
                .padding(.top, 50)
            
            Text("Enter your email to receive a verification code")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 20)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 15) {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .onChange(of: email) { newValue in
                        email = newValue.lowercased()
                    }
                
                Button(action: sendOTP) {
                    Text(sendButtonTitle)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(sendButtonDisabled)
                .padding(.horizontal)
                
                if let errorMessage = viewModel.message, !errorMessage.lowercased().contains("sent") {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.top, 5)
                }
            }
            Spacer()
        }
    }
    
    private var sendButtonTitle: String {
        if viewModel.isSending {
            return "Sending..."
        } else if buttonCooldown > 0 {
            return "Wait \(formatTime(buttonCooldown))"
        } else {
            return "Send OTP"
        }
    }
    
    private var sendButtonDisabled: Bool {
        email.isEmpty || viewModel.isSending || buttonCooldown > 0
    }
    
    private func sendOTP() {
        Task {
            viewModel.email = email
            await viewModel.sendOTP()
            
            if let message = viewModel.message, message.lowercased().contains("sent") {
                otpDigits = Array(repeating: "", count: 6)
                otpExpiryCountdown = 120
                startExpiryCountdown()
                focusedIndex = 0
                step = .verify
            }
            startButtonCooldown()
        }
    }
    
    private func startButtonCooldown() {
        buttonCooldown = 120 // 2 minutes
        cooldownTimer?.invalidate()
        cooldownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if buttonCooldown > 0 {
                buttonCooldown -= 1
            } else {
                cooldownTimer?.invalidate()
                cooldownTimer = nil
            }
        }
    }
}

// MARK: - VERIFY OTP Screen
extension AuthFlowView {
    private var verifyOTPView: some View {
        VStack(spacing: 30) {
            Text("Enter Code")
                .font(.title.bold())
                .padding(.top, 50)
            
            VStack(spacing: 8) {
                Text("Code sent to")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(email)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.purple)
                
                if otpExpiryCountdown > 0 {
                    Text("Expires in \(formatTime(otpExpiryCountdown))")
                        .font(.caption)
                        .foregroundColor(.orange)
                } else {
                    Text("Code expired")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            HStack(spacing: 12) {
                ForEach(0..<6, id: \.self) { index in
                    OTPDigitBox(text: $otpDigits[index])
                        .focused($focusedIndex, equals: index)
                        .onChange(of: otpDigits[index]) { newValue in
                            handleDigitChange(newValue, at: index)
                        }
                }
            }
            
            Button(action: verifyOTP) {
                Text(viewModel.isVerifying ? "Verifying..." : "Verify")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(enteredCode.count != 6 || viewModel.isVerifying || otpExpiryCountdown <= 0 ? Color.gray : Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(enteredCode.count != 6 || viewModel.isVerifying || otpExpiryCountdown <= 0)
            .padding(.horizontal)
            
            if let message = viewModel.message {
                Text(message)
                    .foregroundColor(message.lowercased().contains("successfully") ? .green : .red)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
    }
    
    private var enteredCode: String {
        otpDigits.joined()
    }
    
    private func verifyOTP() {
        Task {
            viewModel.email = email
            viewModel.otpCode = enteredCode
            await viewModel.verifyOTP()
            
            if let message = viewModel.message, message.lowercased().contains("successfully") {
                // 🔥 NAVIGATE TO CHATBOT VIEW
                DispatchQueue.main.async {
                    navigateToChatbot = true
                    isAuthenticated = true
                }
            }
        }
    }
    
    private func startExpiryCountdown() {
        expiryTimer?.invalidate()
        expiryTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if otpExpiryCountdown > 0 {
                otpExpiryCountdown -= 1
            } else {
                expiryTimer?.invalidate()
            }
        }
    }
    
    private func handleDigitChange(_ newValue: String, at index: Int) {
        if newValue.count > 1 { otpDigits[index] = String(newValue.last!) }
        if !newValue.isEmpty && index < 5 { focusedIndex = index + 1 }
        if newValue.isEmpty && index > 0 { focusedIndex = index - 1 }
        if enteredCode.count == 6 && !viewModel.isVerifying { verifyOTP() }
    }
}

// MARK: - OTP Digit Box
struct OTPDigitBox: View {
    @Binding var text: String
    
    var body: some View {
        TextField("", text: $text)
            .frame(width: 45, height: 55)
            .font(.title2)
            .multilineTextAlignment(.center)
            .keyboardType(.numberPad)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(text.isEmpty ? Color.gray.opacity(0.3) : Color.purple, lineWidth: 1)
            )
    }
}

// MARK: - Helpers
extension AuthFlowView {
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}



// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
