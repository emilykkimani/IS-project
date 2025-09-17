import Foundation

enum OTPConfig {
    // Use your deployed URL in production:
    static let baseURL = URL(string: "https://emily-qqqcx1off-emilys-projects-6573ca71.vercel.app")!
    
    // For local dev on Simulator only:
    // static let baseURL = URL(string: "http://localhost:3000")!
}

enum OTPServiceError: Error, LocalizedError {
    case invalidURL
    case badResponse(Int)
    case decoding
    case message(String)
    case missingEmail
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL."
        case .badResponse(let code): return "Server error (\(code))."
        case .decoding: return "Response decoding failed."
        case .message(let m): return m
        case .missingEmail: return "No email on file."
        }
    }
}

struct OTPServerResponse: Decodable {
    let success: Bool
    let message: String?
    let error: String?
}

struct OTPService {
    private static func request(path: String, query: [URLQueryItem]) async throws -> OTPServerResponse {
        var comps = URLComponents(url: OTPConfig.baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        comps?.queryItems = query
        guard let url = comps?.url else { throw OTPServiceError.invalidURL }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse else { throw OTPServiceError.badResponse(-1) }
        guard (200..<300).contains(http.statusCode) else {
            // Try to read server error payload
            if let obj = try? JSONDecoder().decode(OTPServerResponse.self, from: data),
               let msg = obj.error ?? obj.message {
                throw OTPServiceError.message(msg)
            }
            throw OTPServiceError.badResponse(http.statusCode)
        }
        guard let obj = try? JSONDecoder().decode(OTPServerResponse.self, from: data) else {
            throw OTPServiceError.decoding
        }
        return obj
    }
    
    static func sendOTP(to email: String) async throws {
        _ = try await request(path: "send-otp", query: [.init(name: "email", value: email)])
    }
    
    static func verifyOTP(email: String, code: String) async throws -> Bool {
        let res = try await request(path: "verify-otp", query: [
            .init(name: "email", value: email),
            .init(name: "otp", value: code)
        ])
        return res.success
    }
}
