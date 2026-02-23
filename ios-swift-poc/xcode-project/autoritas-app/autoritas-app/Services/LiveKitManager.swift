import Foundation
import Combine
import LiveKit

// MARK: - LiveKitManager
// Full port of ChatBridge.tsx + ThemeHandler.tsx
// Publishes messages, agentState, sessionData, and theme updates.

class LiveKitManager: ObservableObject, RoomDelegate, @unchecked Sendable {
    @Published var room: Room?
    @Published var messages: [Message] = []
    @Published var isConnected: Bool = false
    @Published var agentState: AgentState = .disconnected
    @Published var isMicEnabled: Bool = false

    // Callbacks to push theme / session data to their owning ViewModels
    var onThemeUpdate: ((GeneratedTheme) -> Void)?
    var onSessionDataUpdate: (([String: Any]) -> Void)?

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Connect

    func connect(url: String, token: String) async throws {
        var connectUrl = url
        // ws:// → wss:// upgrade for non-localhost (mirrors AuthService.ts)
        if connectUrl.hasPrefix("ws://"),
           !connectUrl.contains("localhost"),
           !connectUrl.contains("127.0.0.1") {
            connectUrl = connectUrl.replacingOccurrences(of: "ws://", with: "wss://")
        }
        // Simulator: localhost points to simulator itself, fall back to production
        if connectUrl.contains("127.0.0.1") || connectUrl.contains("localhost") {
            print("[LKM] WARNING: Localhost detected – using wss://agent.artemisa-hb.cloud")
            connectUrl = "wss://agent.artemisa-hb.cloud"
        }

        let r = Room()
        r.add(delegate: self)
        await MainActor.run { self.room = r }

#if targetEnvironment(simulator)
        let audioOptions = AudioCaptureOptions(echoCancellation: false, autoGainControl: false, noiseSuppression: false)
#else
        let audioOptions = AudioCaptureOptions(echoCancellation: true, autoGainControl: true, noiseSuppression: true)
#endif
        let roomOptions = RoomOptions(defaultAudioCaptureOptions: audioOptions, adaptiveStream: true, dynacast: true)
        let connectOptions = ConnectOptions(autoSubscribe: true)

        do {
            try await r.connect(url: connectUrl, token: token, connectOptions: connectOptions, roomOptions: roomOptions)
            try? await Task.sleep(nanoseconds: 500_000_000)
            try await r.localParticipant.setMicrophone(enabled: true)

            await MainActor.run {
                self.isConnected = true
                self.agentState  = .listening
                self.isMicEnabled = true
            }

            // --- Register text stream handlers (agent replies via sendText) ---
            try await r.registerTextStreamHandler(for: "lk.chat") { [weak self] reader, identity in
                let msgId = UUID().uuidString
                await self?.addMessage(id: msgId, text: "", role: .agent)
                do {
                    for try await chunk in reader {
                        await self?.appendMessageText(id: msgId, chunk: chunk)
                    }
                } catch { print("[LKM] lk.chat stream error: \(error)") }
            }

            try await r.registerTextStreamHandler(for: "lk.transcription") { [weak self] reader, identity in
                let msgId = UUID().uuidString
                await self?.addMessage(id: msgId, text: "", role: .agent)
                do {
                    for try await chunk in reader {
                        await self?.appendMessageText(id: msgId, chunk: chunk)
                    }
                } catch { print("[LKM] lk.transcription stream error: \(error)") }
            }
        } catch {
            print("[LKM] Connection failed: \(error)")
            throw error
        }
    }

    // MARK: - Disconnect / Mic

    func disconnect() {
        Task {
            await room?.disconnect()
            room?.remove(delegate: self)
            await MainActor.run {
                self.isConnected  = false
                self.agentState   = .disconnected
                self.isMicEnabled = false
                self.room         = nil
            }
        }
    }

    func toggleMicrophone() {
        guard let r = room else { return }
        Task {
            let next = !isMicEnabled
            do {
                try await r.localParticipant.setMicrophone(enabled: next)
            } catch {
                print("[LKM] Mic toggle error: \(error)")
            }
            await MainActor.run { self.isMicEnabled = next }
        }
    }

    // MARK: - Send

    func sendMessage(_ text: String) {
        guard let r = room else { return }
        Task {
            // 1. Text stream (preferred)
            do {
                _ = try await r.localParticipant.sendText(text, for: "lk.chat")
            } catch {
                // 2. Data packet fallback
                if let data = text.data(using: .utf8) {
                    let opts = DataPublishOptions(topic: "lk.chat", reliable: true)
                    try? await r.localParticipant.publish(data: data, options: opts)
                }
            }
            // Add local echo
            let msg = Message(id: UUID().uuidString, role: .user, text: text, widgetType: nil,
                              rawData: nil, actions: nil, selectedActionId: nil, timestamp: Date())
            await MainActor.run { self.messages.append(msg) }
        }
    }

    // MARK: - RoomDelegate: Data Received
    // Full port of ChatBridge.tsx onDataReceived

    nonisolated public func room(_ room: Room,
                                  participant: RemoteParticipant?,
                                  didReceiveData data: Data,
                                  forTopic topic: String,
                                  encryptionType: EncryptionType) {
        print("[LKM] Data received – topic: \(topic)  size: \(data.count)B")
        Task { @MainActor in
            self.handleData(data, topic: topic)
        }
    }

    @MainActor
    private func handleData(_ data: Data, topic: String) {
        // --- Theme update ---
        if topic == "ui_theme_update" {
            if let theme = try? JSONDecoder().decode(GeneratedTheme.self, from: data) {
                print("[LKM] Applying theme: \(theme.meta.name)")
                onThemeUpdate?(theme)
            }
            return
        }

        let rawStr = String(data: data, encoding: .utf8) ?? ""

        // --- Plain text on chat topic ---
        if topic == "chat" {
            if (try? JSONSerialization.jsonObject(with: data)) == nil {
                addMessageSync(id: UUID().uuidString, text: rawStr, role: .agent)
                return
            }
        }

        // --- JSON parsing ---
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return
        }
        let type = json["type"] as? String

        switch type {
        case "voice_interaction":
            if let t = json["transcript"] as? String {
                addMessageSync(id: UUID().uuidString + "_user", text: t, role: .user)
            }
            if let r = json["response"] as? String {
                addMessageSync(id: UUID().uuidString + "_agent", text: r, role: .agent)
            }

        case "final_structured_data":
            if let d = json["data"] as? [String: Any] {
                print("[LKM] Session data: \(d)")
                onSessionDataUpdate?(d)
            }

        case "transcription":
            if let text = json["text"] as? String {
                addMessageSync(id: UUID().uuidString, text: text, role: .agent)
            }

        case "widget", "ui_directive":
            handleWidgetMessage(json: json, type: type ?? "")

        case "agent_text_response", "agent_message":
            let text = (json["text"] as? String) ?? (json["message"] as? String) ?? ""
            if !text.isEmpty { addMessageSync(id: UUID().uuidString, text: text, role: .agent) }

        default:
            // Generic session object (status / session_id / context_summary)
            if type == nil,
               let _ = (json["status"] ?? json["session_id"] ?? json["context_summary"]) {
                onSessionDataUpdate?(json)
            }
        }
    }

    @MainActor
    private func handleWidgetMessage(json: [String: Any], type: String) {
        // Normalise: ui_directive wraps payload under "directive"
        let payload = (type == "ui_directive") ? (json["directive"] as? [String: Any] ?? [:]) : json
        guard let widgetStr = payload["widget"] as? String,
              let widgetType = WidgetType(rawValue: widgetStr) else {
            print("[LKM] Unknown widget type: \(String(describing: json["widget"]))")
            return
        }

        let rawData   = payload["data"] as? [String: Any]
        let actionsRaw = payload["actions"] as? [[String: Any]] ?? []
        let actions   = actionsRaw.compactMap { a -> WidgetAction? in
            guard let id = a["id"] as? String, let label = a["label"] as? String else { return nil }
            let style  = (a["style"] as? String).flatMap { WidgetAction.ActionStyle(rawValue: $0) }
            let icon   = a["icon"] as? String
            return WidgetAction(id: id, label: label, style: style, icon: icon, disabled: nil)
        }
        let agentMsg = payload["agentMessage"] as? String

        let msg = Message(
            id: UUID().uuidString,
            role: .agent,
            text: agentMsg,
            widgetType: widgetType,
            rawData: rawData,
            actions: actions,
            selectedActionId: nil,
            timestamp: Date()
        )
        messages.append(msg)
    }

    // MARK: - RoomDelegate: Transcription (STT)

    nonisolated public func room(_ room: Room,
                                  participant: RemoteParticipant?,
                                  publication: TrackPublication,
                                  didUpdateTranscription segments: [TranscriptionSegment]) {
        Task { @MainActor in
            for seg in segments {
                let role: MessageRole = (participant?.identity == room.localParticipant.identity) ? .user : .agent
                print("[LKM] Transcription (\(role)) – \(seg.text) final:\(seg.isFinal)")
                self.upsertMessageSync(
                    id: seg.id,
                    role: role,
                    text: seg.text,
                    isFinal: seg.isFinal,
                    timestamp: Date(timeIntervalSince1970: TimeInterval(seg.firstReceivedTime) / 1000)
                )
            }
        }
    }

    // MARK: - RoomDelegate: Connection

    nonisolated public func room(_ room: Room,
                                  didUpdateConnectionState state: ConnectionState,
                                  from old: ConnectionState) {
        Task { @MainActor in self.isConnected = (state == .connected) }
    }

    // MARK: - RoomDelegate: Active Speakers

    nonisolated public func room(_ room: Room, didUpdateActiveSpeakers speakers: [Participant]) {
        let agentSpeaking = speakers.contains {
            String(describing: $0.identity).lowercased().contains("agent")
        }
        Task { @MainActor in
            self.agentState = agentSpeaking ? .speaking : (self.isConnected ? .listening : .disconnected)
        }
    }

    // MARK: - RoomDelegate: Track subscribed

    nonisolated public func room(_ room: Room,
                                  participant: RemoteParticipant,
                                  didSubscribe publication: RemoteTrackPublication,
                                  track: RemoteTrack) {
        print("[LKM] Subscribed: \(track.kind) from \(String(describing: participant.identity))")
    }

    // MARK: - Helpers

    private func addMessage(id: String, text: String, role: MessageRole) async {
        let msg = Message(id: id, role: role, text: text, widgetType: nil,
                          rawData: nil, actions: nil, selectedActionId: nil, timestamp: Date())
        await MainActor.run { self.messages.append(msg) }
    }

    @MainActor
    private func addMessageSync(id: String, text: String, role: MessageRole) {
        let msg = Message(id: id, role: role, text: text, widgetType: nil,
                          rawData: nil, actions: nil, selectedActionId: nil, timestamp: Date())
        messages.append(msg)
    }

    private func appendMessageText(id: String, chunk: String) async {
        await MainActor.run {
            if let idx = self.messages.firstIndex(where: { $0.id == id }) {
                var m = self.messages[idx]
                m.text = (m.text ?? "") + chunk
                self.messages[idx] = m
            }
        }
    }

    @MainActor
    private func upsertMessageSync(id: String, role: MessageRole, text: String, isFinal: Bool, timestamp: Date) {
        if let idx = messages.firstIndex(where: { $0.id == id }) {
            var m = messages[idx]
            m.text = text
            m.isFinal = isFinal
            messages[idx] = m
        } else {
            let msg = Message(id: id, role: role, text: text, widgetType: nil,
                              rawData: nil, actions: nil, selectedActionId: nil,
                              timestamp: timestamp, isFinal: isFinal)
            messages.append(msg)
        }
    }
}
