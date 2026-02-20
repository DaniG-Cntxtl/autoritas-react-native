import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @EnvironmentObject var appState: AppState
    
    let token: String
    let url: String
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Custom Header
                HStack {
                    Button(action: {
                        appState.currentScreen = .login
                        appState.token = nil
                        appState.url = nil
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Exit")
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text("Autoritas AI")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Connection Status
                    Circle()
                        .fill(viewModel.isConnected ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    
                    if viewModel.isConnected {
                        Button(action: {
                            viewModel.toggleMicrophone()
                        }) {
                            Image(systemName: viewModel.isMicEnabled ? "mic.fill" : "mic.slash.fill")
                                .font(.system(size: 14))
                                .foregroundColor(viewModel.isMicEnabled ? .white : .red)
                                .padding(8)
                                .background(Color.white.opacity(0.15))
                                .clipShape(Circle())
                        }
                        .padding(.leading, 8)
                    }
                }
                .padding()
                .background(Color.black)
                
                // Messages Area
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 16) {
                            if viewModel.messages.isEmpty {
                                Spacer()
                                    .frame(height: 100)
                                Text("Say \"Hello\" to start...")
                                    .foregroundColor(.white.opacity(0.5))
                                    .font(.system(size: 16))
                            } else {
                                LazyVStack(spacing: 16) {
                                    ForEach(viewModel.messages) { message in
                                        MessageRow(message: message) { actionId in
                                            viewModel.sendAction(id: actionId)
                                        }
                                        .id(message.id)
                                    }
                                }
                                .padding(.top, 20)
                                .padding(.bottom, 20)
                            }
                        }
                    }
                    .onChange(of: viewModel.messages) { _, _ in
                        if let lastId = viewModel.messages.last?.id {
                            withAnimation {
                                proxy.scrollTo(lastId, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Status Indicator
                HStack {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 6, height: 6)
                        .scaleEffect(viewModel.agentState == .speaking ? 1.4 : 1.0)
                        .animation(viewModel.agentState == .speaking ? .easeInOut(duration: 0.6).repeatForever(autoreverses: true) : .default, value: viewModel.agentState)
                    
                    Text(statusText)
                        .font(.system(size: 11, weight: .semibold))
                        .kerning(0.5)
                        .foregroundColor(.white.opacity(0.6))
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
                
                // Input Bar
                InputBar(text: $viewModel.inputText, onSend: viewModel.sendMessage)
            }
        }
        .onAppear {
            Task {
                await viewModel.connect(token: token, url: url)
            }
        }
    }
    
    private var statusColor: Color {
        switch viewModel.agentState {
        case .speaking: return .purple
        case .thinking: return .orange
        case .listening: return Color(red: 0.19, green: 0.82, blue: 0.35)
        default: return .gray
        }
    }
    
    private var statusText: String {
        switch viewModel.agentState {
        case .disconnected: return "DISCONNECTED"
        case .connecting: return "CONNECTING..."
        case .listening: return "VOICE ACTIVE • LISTENING"
        case .thinking: return "VOICE ACTIVE • THINKING..."
        case .speaking: return "VOICE ACTIVE • SPEAKING"
        }
    }
}

struct MessageRow: View {
    let message: Message
    let onAction: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if message.type == .text {
                GeometricMessageBubble(message: message)
            } else if let widgetType = message.widgetType {
                VStack(spacing: 16) {
                    switch widgetType {
                    case .actionButtons:
                        ActionButtons(message: message, onAction: onAction)
                    case .deviceGrid:
                        DeviceGrid(message: message, onAction: onAction)
                    case .planCard:
                        PlanCard(message: message, onAction: onAction)
                    case .invoiceSummary:
                        InvoiceSummary(message: message, onAction: onAction)
                    }
                }
                .padding(.bottom, 16)
            }
        }
    }
}
