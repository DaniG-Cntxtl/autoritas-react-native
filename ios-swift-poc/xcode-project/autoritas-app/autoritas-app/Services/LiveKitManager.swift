import Foundation
import Combine
import LiveKit

// Mocking LiveKit types if they are not available during this generation context, 
// but in a real project this would import LiveKit
// For this generation, I assume standard LiveKit SDK usage.

class LiveKitManager: ObservableObject, RoomDelegate, @unchecked Sendable {
    @Published var room: Room?
    @Published var messages: [Message] = []
    @Published var isConnected: Bool = false
    @Published var agentState: AgentState = .disconnected
    @Published var isMicEnabled: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    func connect(url: String, token: String) async throws {
        var connectUrl = url
        // Simulator workaround: Localhost (127.0.0.1) refers to the simulator itself.
        // If the backend returns localhost, force production URL or host IP.
        if connectUrl.contains("127.0.0.1") || connectUrl.contains("localhost") {
            print("WARNING: Localhost URL detected. Switching to wss://agent.autoritas.ai for Simulator compatibility.")
            connectUrl = "wss://agent.autoritas.ai"
        }

        let room = Room()
        room.add(delegate: self)
        
        await MainActor.run {
            self.room = room
        }
        
        // Explicit Audio Options
        #if targetEnvironment(simulator)
        let audioOptions = AudioCaptureOptions(
            echoCancellation: false,
            autoGainControl: false,
            noiseSuppression: false
        )
        #else
        let audioOptions = AudioCaptureOptions(
            echoCancellation: true,
            autoGainControl: true,
            noiseSuppression: true
        )
        #endif
        let roomOptions = RoomOptions(
            defaultAudioCaptureOptions: audioOptions,
            adaptiveStream: true,
            dynacast: true
        )
        
        // Connection Options to help with timeouts
        let connectOptions = ConnectOptions(
            autoSubscribe: true
        )

        do {
            print("DEBUG: Calling room.connect(url: \(connectUrl))...")
            try await room.connect(url: connectUrl, token: token, connectOptions: connectOptions, roomOptions: roomOptions)
            print("DEBUG: room.connect success")
            
            // Allow audio engine to stabilize to prevent Error 801
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s delay
            print("DEBUG: Waited 0.5s")
            
            // Enable microphone to allow voice interaction with the agent
            print("DEBUG: Enabling microphone...")
            try await room.localParticipant.setMicrophone(enabled: true)
            print("DEBUG: Microphone enabled")
            
            await MainActor.run {
                self.isConnected = true
                self.agentState = .listening
                self.isMicEnabled = true
            }
            
            // Register handler for Agent text responses (Stream based)
            // This is required because Agent uses sendText() which creates a stream, not a simple data packet.
            
            // 1. Listen on "lk.chat" (Standard)
            try await room.registerTextStreamHandler(for: "lk.chat") { [weak self] reader, identity in
                do {
                    // Create a new message ID for this stream
                    let messageId = UUID().uuidString
                    await self?.addMessage(id: messageId, text: "", role: .agent)
                    print("DEBUG: Stream STARTED on lk.chat (id: \(messageId))")
                    
                    for try await chunk in reader {
                        print("DEBUG: Chunk on lk.chat: \(chunk)")
                        await self?.appendMessageText(id: messageId, text: chunk)
                    }
                    print("DEBUG: Stream FINISHED on lk.chat")
                } catch {
                    print("Error reading lk.chat stream: \(error)")
                }
            }
            
            // 2. Listen on "lk.transcription" (Potential alternative mentioned in reference)
            try await room.registerTextStreamHandler(for: "lk.transcription") { [weak self] reader, identity in
                do {
                    let messageId = UUID().uuidString
                    await self?.addMessage(id: messageId, text: "", role: .agent)
                    print("DEBUG: Stream STARTED on lk.transcription (id: \(messageId))")
                    
                    for try await chunk in reader {
                        print("DEBUG: Chunk on lk.transcription: \(chunk)")
                        await self?.appendMessageText(id: messageId, text: chunk)
                    }
                    print("DEBUG: Stream FINISHED on lk.transcription")
                } catch {
                    print("Error reading lk.transcription stream: \(error)")
                }
            }
            
        } catch {
            print("Failed to connect or register handler: \(error)")
            throw error
        }
    }
    
    private func addMessage(id: String = UUID().uuidString, text: String, role: Message.MessageRole) async {
        let msg = Message(
            id: id,
            role: role,
            type: .text,
            text: text,
            widgetType: nil,
            widgetData: nil,
            actions: nil,
            selectedActionId: nil,
            timestamp: Date()
        )
        await MainActor.run {
            self.messages.append(msg)
        }
    }
    
    private func appendMessageText(id: String, text: String) async {
        await MainActor.run {
            if let index = self.messages.firstIndex(where: { $0.id == id }) {
                var updatedMsg = self.messages[index]
                updatedMsg.text = (updatedMsg.text ?? "") + text
                self.messages[index] = updatedMsg
            }
        }
    }
    
    // MARK: - Audio handling & Debugging
    
    nonisolated public func room(_ room: Room, participant: RemoteParticipant, didSubscribe publication: RemoteTrackPublication, track: RemoteTrack) {
        print("DEBUG: Subscribed to track: \(track.kind) from \(String(describing: participant.identity))")
        if track.kind == .audio {
            print("DEBUG: Audio track subscribed and should be playing automatically")
        }
    }
    
    func disconnect() {
        Task {
            await room?.disconnect()
            room?.remove(delegate: self)
            DispatchQueue.main.async {
                self.isConnected = false
                self.agentState = .disconnected
                self.room = nil
            }
        }
    }
    
    func toggleMicrophone() {
        guard let room = room else { return }
        let localParticipant = room.localParticipant
        
        Task {
            let newState = !self.isMicEnabled
            do {
                try await localParticipant.setMicrophone(enabled: newState)
                print("DEBUG: Microphone set to \(newState)")
            } catch {
                print("DEBUG: Failed to toggle microphone: \(error)")
            }
            await MainActor.run {
                self.isMicEnabled = newState
            }
        }
    }
    
    // MARK: - Active Speaker Tracking
    
    nonisolated public func room(_ room: Room, didUpdateActiveSpeakers speakers: [Participant]) {
        let isAgentSpeaking = speakers.contains { 
            let identity = String(describing: $0.identity)
            return identity.lowercased().contains("agent") 
        }
        
        Task { @MainActor in
            if isAgentSpeaking {
                self.agentState = .speaking
            } else if self.isConnected {
                self.agentState = .listening
            }
        }
    }
    
    func sendMessage(_ text: String) {
        // Send message via DataChannel
        guard let localParticipant = room?.localParticipant else { return }
        
        let webTopic = "lk.chat"
        let legacyTopic = "lk-chat-topic"
        
        Task {
            // 1. Send via Text Stream (Unified/Web)
            do {
                _ = try await localParticipant.sendText(text, for: webTopic)
                print("DEBUG: Sent text stream to \(webTopic): \(text)")
            } catch {
                print("Failed to send text stream: \(error)")
            }
            
            // 2. Send via Data Packet (Legacy/RN) - "Shotgun" backup
            do {
                struct AgentChatMessage: Codable {
                    let message: String
                    let timestamp: Int64
                }
                let payload = AgentChatMessage(message: text, timestamp: Int64(Date().timeIntervalSince1970 * 1000))
                let data = try JSONEncoder().encode(payload)
                let options = DataPublishOptions(topic: legacyTopic, reliable: true)
                try await localParticipant.publish(data: data, options: options)
                print("DEBUG: Sent JSON packet to \(legacyTopic)")
            } catch {
                print("Failed to send JSON packet: \(error)")
            }
            
            // Add local message
            let msg = Message(
                id: UUID().uuidString,
                role: .user,
                type: .text,
                text: text,
                widgetType: nil,
                widgetData: nil,
                actions: nil,
                selectedActionId: nil,
                timestamp: Date()
            )
            await MainActor.run {
                self.messages.append(msg)
            }
        }
    }
    
    // MARK: - RoomDelegate
    // Updated signature for recent LiveKit versions
    nonisolated public func room(_ room: Room, participant: RemoteParticipant?, didReceiveData data: Data, forTopic topic: String, encryptionType: EncryptionType) {
        print("DEBUG: [RECEIVED DATA] topic: \(topic) size: \(data.count) bytes")
        
        Task { @MainActor in
            // 1. Handle "lk.chat" or "chat" topic as raw text (if that's how agent sends replies)
            // Web impl uses 'agent_text_response' packet usually, but let's be safe.
            if topic == "lk.chat" || topic == "chat" {
                if let text = String(data: data, encoding: .utf8) {
                    // Check if it's actually JSON first (some agents send JSON on chat topic)
                    if (try? JSONSerialization.jsonObject(with: data)) == nil {
                        let msg = Message(
                            id: UUID().uuidString,
                            role: .agent,
                            type: .text,
                            text: text,
                            widgetType: nil,
                            widgetData: nil,
                            actions: nil,
                            selectedActionId: nil,
                            timestamp: Date()
                        )
                        self.messages.append(msg)
                        return
                    }
                }
            }
            
            // 2. Parse JSON for structured messages
            guard let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return
            }
            
            let type = jsonObject["type"] as? String
            
            // Web alignment: agent_text_response / agent_message
            if type == "agent_text_response" || type == "agent_message" {
                if let text = (jsonObject["text"] as? String) ?? (jsonObject["message"] as? String) {
                    let msg = Message(
                        id: UUID().uuidString,
                        role: .agent,
                        type: .text,
                        text: text,
                        widgetType: nil,
                        widgetData: nil,
                        timestamp: Date()
                    )
                    self.messages.append(msg)
                }
            }
            // Web alignment: ui_directive
            else if type == "ui_directive" {
                // The actual widget data is inside 'directive'
                if let directive = jsonObject["directive"] as? [String: Any],
                   let directiveData = try? JSONSerialization.data(withJSONObject: directive),
                   let widgetData = try? JSONDecoder().decode(WidgetData.self, from: directiveData) {
                    
                    // Manually map 'widget' field from directive if needed, or rely on content
                    var widgetType: WidgetType? = nil
                    // Check specific fields
                    if widgetData.plan != nil { widgetType = .planCard }
                    else if widgetData.invoice != nil { widgetType = .invoiceSummary }
                    else if widgetData.devices != nil { widgetType = .deviceGrid }
                    else if widgetData.genericItems != nil { widgetType = .actionButtons }
                    
                    // Check 'widget' string in directive if not found
                    if widgetType == nil, let widgetStr = directive["widget"] as? String {
                         widgetType = WidgetType(rawValue: widgetStr)
                    }

                    let msg = Message(
                        id: UUID().uuidString,
                        role: .agent,
                        type: .widget,
                        text: widgetData.agentMessage,
                        widgetType: widgetType,
                        widgetData: widgetData,
                        actions: nil, // TODO: map actions
                        selectedActionId: nil,
                        timestamp: Date()
                    )
                    self.messages.append(msg)
                }
            }
            // Transcription packet
            else if type == "transcription", let text = jsonObject["text"] as? String {
                let isFinal = (jsonObject["is_final"] as? Bool) ?? true
                if isFinal {
                    let msg = Message(
                        id: UUID().uuidString,
                        role: .agent,
                        type: .text,
                        text: text,
                        widgetType: nil,
                        widgetData: nil,
                        timestamp: Date()
                    )
                    self.messages.append(msg)
                }
            }
            // React Native / Legacy fallback
            else if type == "widget" || (jsonObject["widget"] != nil && jsonObject["data"] != nil) {
                 if let widgetData = try? JSONDecoder().decode(WidgetData.self, from: data) {
                    // ... (existing fallback logic)
                    var widgetType: WidgetType? = nil
                    if widgetData.plan != nil { widgetType = .planCard }
                    else if widgetData.invoice != nil { widgetType = .invoiceSummary }
                    else if widgetData.devices != nil { widgetType = .deviceGrid }
                    else if widgetData.genericItems != nil { widgetType = .actionButtons }
                    
                    let msg = Message(
                        id: UUID().uuidString,
                        role: .agent,
                        type: .widget,
                        text: widgetData.agentMessage,
                        widgetType: widgetType,
                        widgetData: widgetData,
                        actions: nil,
                        selectedActionId: nil,
                        timestamp: Date()
                    )
                    self.messages.append(msg)
                 }
            }
        }
    }
    
    // Handle Transcriptions (STT)
    nonisolated public func room(_ room: Room, participant: RemoteParticipant?, publication: TrackPublication, didUpdateTranscription segments: [TranscriptionSegment]) {
        // Find the last final segment or accumulate partials
        // For this POC, let's just show the latest segment text as a message or update a "typing" indicator
        // Ideally, you'd update a "pending" message.
        
        for segment in segments {
            print("DEBUG: Transcription: \(segment.text) (final: \(segment.isFinal))")
            
            if segment.isFinal {
                let msg = Message(
                    id: segment.id, // Use segment ID to avoid dupes if possible, or UUID
                    role: .agent, // Or user if participant is local? Usually agent/remote
                    type: .text,
                    text: segment.text,
                    widgetType: nil,
                    widgetData: nil,
                    actions: nil,
                    selectedActionId: nil,
                    timestamp: Date()
                )
                
                Task {
                    await MainActor.run {
                        self.messages.append(msg)
                    }
                }
            }
        }
    }
    
    nonisolated public func room(_ room: Room, didUpdateConnectionState connectionState: LiveKit.ConnectionState, from oldValue: LiveKit.ConnectionState) {
        DispatchQueue.main.async {
            self.isConnected = (connectionState == .connected)
        }
    }
}

