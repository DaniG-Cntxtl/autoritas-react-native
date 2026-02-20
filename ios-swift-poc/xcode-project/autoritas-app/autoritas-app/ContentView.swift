import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()
    
    init() {
        print("DEBUG: ContentView init")
    }
    
    var body: some View {
        let _ = print("DEBUG: ContentView body")
        Group {
            switch appState.currentScreen {
            case .login:
                LoginView()
                    .environmentObject(appState)
            case .chat:
                if let token = appState.token, let url = appState.url {
                    ChatView(token: token, url: url)
                        .environmentObject(appState)
                } else {
                    LoginView()
                        .environmentObject(appState)
                }
            }
        }
    }
}
