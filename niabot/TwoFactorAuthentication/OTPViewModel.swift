import SwiftUI

@MainActor
class OTPViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var otpCode: String = ""
    @Published var resendCooldown: Int = 0
    @Published var isVerifying: Bool = false
    @Published var isSending: Bool = false
    @Published var message: String?

    private var timer: Timer?

    // MARK: - Send OTP
    func sendOTP() async {
        guard !email.isEmpty else {
            message = "Please enter your email"
            return
        }

        isSending = true
        defer { isSending = false }
        
        do {
            try await OTPService.sendOTP(to: email)
            message = "OTP sent to \(email)"
            startCooldown()
        } catch let error as OTPServiceError {
            message = "\(error.localizedDescription)"
        } catch {
            message = "Error: \(error.localizedDescription)"
        }
    }

    // MARK: - Verify OTP
    func verifyOTP() async {
        guard !email.isEmpty, !otpCode.isEmpty else {
            message = "Please enter email & OTP"
            return
        }

        isVerifying = true
        defer { isVerifying = false }

        do {
            let success = try await OTPService.verifyOTP(email: email, code: otpCode)
            if success {
                message = "OTP verified successfully!"
                otpCode = ""
                stopCooldown() // Stop cooldown on successful verification
            } else {
                message = "Invalid or expired OTP"
            }
        } catch let error as OTPServiceError {
            message = "\(error.localizedDescription)"
        } catch {
            message = "Error: \(error.localizedDescription)"
        }
    }

    // MARK: - Cooldown logic
    private func startCooldown() {
        resendCooldown = 60 // Reasonable resend cooldown (1 minute)
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                if self.resendCooldown > 0 {
                    self.resendCooldown -= 1
                } else {
                    self.timer?.invalidate()
                    self.timer = nil
                }
            }
        }
    }
    
    private func stopCooldown() {
        timer?.invalidate()
        resendCooldown = 0
    }
    
    func reset() {
        email = ""
        otpCode = ""
        message = nil
        stopCooldown()
    }
    
    deinit {
        timer?.invalidate()
    }
}
