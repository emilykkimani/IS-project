import Foundation
import Combine

protocol ForgotPasswordViewModel {
    var email: String { get set }
    var message: String? { get }
    var isSuccess: Bool { get }
    func sendPasswordResetRequest()
}

final class ForgotPasswordViewModelImpl: ObservableObject, ForgotPasswordViewModel {
    private let service: ForgotPasswordService
    private var subscriptions = Set<AnyCancellable>()

    @Published var email: String = ""
    @Published var message: String?
    @Published var isSuccess: Bool = false

    init(service: ForgotPasswordService) {
        self.service = service
    }
    
    func sendPasswordResetRequest() {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        service.sendPasswordResetRequest(to: normalizedEmail)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let err):
                    self?.message = "\(err.localizedDescription)"
                    self?.isSuccess = false
                case .finished:
                    break
                }
            } receiveValue: { [weak self] in
                self?.message = "Reset link sent to \(normalizedEmail)"
                self?.isSuccess = true
            }
            .store(in: &subscriptions)
    }
}

