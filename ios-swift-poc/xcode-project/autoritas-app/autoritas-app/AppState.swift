import Foundation
import Combine

class AppState: ObservableObject, @unchecked Sendable {
    @Published var currentScreen: AppScreen = .login
    @Published var token: String?
    @Published var url: String?
    
    enum AppScreen {
        case login
        case chat
    }
}
