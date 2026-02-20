import Foundation
import Combine
import SwiftUI

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var inputText: String = ""
    @Published var isConnected: Bool = false
    @Published var agentState: AgentState = .disconnected
    @Published var isMicEnabled: Bool = false
    
    private var liveKitManager = LiveKitManager()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        liveKitManager.$messages
            .receive(on: DispatchQueue.main)
            .assign(to: \.messages, on: self)
            .store(in: &cancellables)
            
        liveKitManager.$isConnected
            .receive(on: DispatchQueue.main)
            .assign(to: \.isConnected, on: self)
            .store(in: &cancellables)
            
        liveKitManager.$agentState
            .receive(on: DispatchQueue.main)
            .assign(to: \.agentState, on: self)
            .store(in: &cancellables)
            
        liveKitManager.$isMicEnabled
            .receive(on: DispatchQueue.main)
            .assign(to: \.isMicEnabled, on: self)
            .store(in: &cancellables)
    }
    
    func connect(token: String, url: String) async {
        do {
            try await liveKitManager.connect(url: url, token: token)
        } catch {
            print("Connection failed: \(error)")
        }
    }
    
    func toggleMicrophone() {
        liveKitManager.toggleMicrophone()
    }
    
    func sendMessage() {
        guard !inputText.isEmpty else { return }
        liveKitManager.sendMessage(inputText)
        inputText = ""	
    }
    
    func sendAction(id: String) {
        liveKitManager.sendMessage(id)
    }
}
