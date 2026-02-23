import SwiftUI

struct ContentView: View {
    @StateObject private var appState    = AppState()
    @StateObject private var themeVM     = ThemeViewModel()
    @StateObject private var sessionVM   = SessionViewModel()

    var body: some View {
        Group {
            switch appState.currentScreen {
            case .login:
                LoginView()
                    .environmentObject(appState)
                    .environmentObject(themeVM)
            case .chat:
                if let token = appState.token, let url = appState.url {
                    LiveSessionView(token: token, url: url)
                        .environmentObject(appState)
                        .environmentObject(themeVM)
                        .environmentObject(sessionVM)
                } else {
                    LoginView()
                        .environmentObject(appState)
                        .environmentObject(themeVM)
                }
            }
        }
    }
}
