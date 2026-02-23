import Foundation
import Combine

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var inputText: String = ""
    @Published var isConnected: Bool = false
    @Published var agentState: AgentState = .disconnected
    @Published var isMicEnabled: Bool = false

    let liveKitManager: LiveKitManager
    private var cancellables = Set<AnyCancellable>()

    init() {
        liveKitManager = LiveKitManager()

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
            print("[ChatVM] Connection failed: \(error)")
        }
    }

    func disconnect() {
        liveKitManager.disconnect()
    }

    func toggleMicrophone() {
        liveKitManager.toggleMicrophone()
    }

    /// Called from InputBar / keyboard return
    func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputText = ""
        liveKitManager.sendMessage(text)
    }

    /// Called when the user taps a widget action button
    func sendAction(messageId: String, actionId: String) {
        // Mark the action as selected in state
        upsertMessage(id: messageId, updates: { $0.selectedActionId = actionId })
        // Send it to the agent
        liveKitManager.sendMessage(actionId)
    }

    // MARK: - Upsert (interim → final transcription)

    func upsertMessage(id: String, updates: (inout Message) -> Void) {
        DispatchQueue.main.async {
            if let idx = self.messages.firstIndex(where: { $0.id == id }) {
                var m = self.messages[idx]
                updates(&m)
                self.messages[idx] = m
            }
        }
    }
}
