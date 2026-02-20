import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let authService = AuthService()
    
    init() {
        print("DEBUG: LoginView init")
        if let path = Bundle.main.path(forResource: "background", ofType: "png") {
            print("DEBUG: background.png found at \(path)")
        } else {
            print("DEBUG: background.png NOT found in Bundle.main")
        }
    }
    
    var body: some View {
        let _ = print("DEBUG: LoginView body")
        ZStack {
            // Background Image
            Image("background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            // Dark Overlay Gradient
            LinearGradient(
                colors: [Color.black.opacity(0.3), Color.black.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                Spacer()
                
                // Logo
                Image("contextualLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 280, height: 80)
                    .padding(.bottom, 20)
                
                // Title
                Text("Talk with your data")
                    .font(.system(size: 32, weight: .regular))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 48)
                
                // Login Button
                VStack(spacing: 16) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Button(action: handleLogin) {
                            HStack(spacing: 12) {
                                // Google Icon Container
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 32, height: 32)
                                    
                                    Image("google")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 18, height: 18)
                                }
                                
                                Text("Sign in with Google")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .frame(maxWidth: 280)
                            .background(Color(red: 1.0, green: 0.3, blue: 0.3)) // NagareRed approx
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 4)
                        }
                    }
                    
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 8)
                    }
                }
                
                Spacer()
            }
            .padding(32)
        }
    }
    
    func handleLogin() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let randomUser = "user-\(Int.random(in: 0...1000))"
                // Use a dynamic room name to ensure a fresh session (Triage start)
                let roomName = "voice-room-\(UUID().uuidString)"
                let response = try await authService.fetchLiveKitToken(roomName: roomName, participantName: randomUser)
                
                await MainActor.run {
                    appState.token = response.token
                    appState.url = response.url
                    appState.currentScreen = .chat
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Login failed: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
}
