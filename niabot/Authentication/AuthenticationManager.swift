import Foundation
import FirebaseAuth

final class AuthenticationManager {
    
    struct AuthDataResultModel {
        let uid: String
        let email: String?
        let photoURL: URL?

        init(user: User) {
            self.uid = user.uid
            self.email = user.email
            self.photoURL = user.photoURL
        }
    }
    
    static let shared = AuthenticationManager()
    private init() {}

    func createUser(email: String, password: String) async throws {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let result = AuthDataResultModel(user: authDataResult.user)
        print("User created: \(result)")
    }

    func loginUser(email: String, password: String) async throws {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        let result = AuthDataResultModel(user: authDataResult.user)
        print("User logged in: \(result)")
    }
}

