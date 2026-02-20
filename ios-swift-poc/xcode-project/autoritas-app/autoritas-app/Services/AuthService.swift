import Foundation
import Combine

class AuthService: ObservableObject, @unchecked Sendable {
    
    enum AuthError: Error {
        case invalidURL
        case invalidResponse
        case decodingError
    }
    
    @Published var token: String?
    @Published var url: String?
    
    func fetchLiveKitToken(roomName: String, participantName: String) async throws -> LiveKitAuthResponse {
        guard let url = URL(string: "https://agent.autoritas.ai/livekit/token") else {
            throw AuthError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "room_name": roomName,
            "participant_name": participantName
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw AuthError.invalidResponse
        }
        
        // Handle the possibility of { token: "...", url: "..." } or simple { "token": "..." }
        if let decoded = try? JSONDecoder().decode(LiveKitAuthResponse.self, from: data) {
            print("DEBUG: Auth URL (decoded): \(decoded.url)")
            return decoded
        } else if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let token = json["token"] as? String {
             // Fallback for different response format if any
             let url = json["url"] as? String ?? "wss://agent.autoritas.ai"
             print("DEBUG: Auth URL (fallback): \(url)")
             return LiveKitAuthResponse(token: token, url: url)
        }
        
        throw AuthError.decodingError
    }
}
