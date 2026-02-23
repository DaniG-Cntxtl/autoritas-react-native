import SwiftUI

struct ChatInterface: View {
    @ObservedObject var chatVM: ChatViewModel
    @EnvironmentObject var themeVM: ThemeViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Status bar (mirrors "VOICE ACTIVE • LISTENING")
            HStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 6, height: 6)
                Text(statusText)
                    .font(.system(size: 11, weight: .bold))
                    .kerning(1)
                    .foregroundColor(themeVM.secondaryTextColor)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(themeVM.backgroundColor)
            .overlay(Divider().background(themeVM.accentColor), alignment: .bottom)

            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    if chatVM.messages.isEmpty {
                        emptyState
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(chatVM.messages) { msg in
                                MessageRow(message: msg,
                                           themeVM: themeVM,
                                           onAction: { chatVM.sendAction(messageId: msg.id, actionId: $0) })
                                    .id(msg.id)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                    }
                }
                .onChange(of: chatVM.messages) { _, _ in
                    if let last = chatVM.messages.last?.id {
                        withAnimation { proxy.scrollTo(last, anchor: .bottom) }
                    }
                }
            }

            // Input bar
            InputBar(text: $chatVM.inputText, themeVM: themeVM, onSend: chatVM.sendMessage)
        }
        .background(themeVM.backgroundColor)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 48))
                .foregroundColor(themeVM.secondaryTextColor.opacity(0.5))
            Text("Start a conversation...")
                .font(.system(size: 16))
                .foregroundColor(themeVM.secondaryTextColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 80)
    }

    private var statusColor: Color {
        switch chatVM.agentState {
        case .speaking:  return .purple
        case .thinking:  return .orange
        case .listening: return Color(hex: "#30d158")
        default:         return .gray
        }
    }

    private var statusText: String {
        switch chatVM.agentState {
        case .disconnected: return "DISCONNECTED"
        case .connecting:   return "CONNECTING..."
        case .listening:    return "VOICE ACTIVE • LISTENING"
        case .thinking:     return "VOICE ACTIVE • THINKING..."
        case .speaking:     return "VOICE ACTIVE • SPEAKING"
        }
    }
}

// MARK: - MessageRow (routes to text bubble or widget)

struct MessageRow: View {
    let message: Message
    let themeVM: ThemeViewModel
    let onAction: (String) -> Void

    var body: some View {
        if message.isWidget, let wt = message.widgetType {
            widgetView(for: wt)
                .padding(.bottom, 8)
        } else {
            MessageBubble(message: message, themeVM: themeVM)
        }
    }

    @ViewBuilder
    private func widgetView(for type: WidgetType) -> some View {
        let data = message.rawData ?? [:]
        let actions = message.actions ?? []
        let agentMsg = message.text
        let selId = message.selectedActionId

        switch type {
        case .actionButtons:
            ActionButtons(data: data, actions: actions, agentMessage: agentMsg,
                          selectedActionId: selId, themeVM: themeVM, onAction: onAction)
        case .deviceGrid:
            DeviceGrid(data: data, actions: actions, agentMessage: agentMsg,
                       selectedActionId: selId, themeVM: themeVM, onAction: onAction)
        case .planCard:
            PlanCard(data: data, actions: actions, agentMessage: agentMsg,
                     themeVM: themeVM, onAction: onAction)
        case .planGrid:
            PlanGrid(data: data, actions: actions, agentMessage: agentMsg,
                     selectedActionId: selId, themeVM: themeVM, onAction: onAction)
        case .invoiceSummary:
            InvoiceSummary(data: data, actions: actions, agentMessage: agentMsg,
                           themeVM: themeVM, onAction: onAction)
        case .routerDiagnostics:
            RouterDiagnostics(data: data, actions: actions, agentMessage: agentMsg,
                              themeVM: themeVM, onAction: onAction)
        case .documentPreview:
            DocumentPreview(data: data, actions: actions, agentMessage: agentMsg,
                            themeVM: themeVM, onAction: onAction)
        case .telemetryDashboard:
            TelemetryDashboard(data: data, actions: actions, agentMessage: agentMsg,
                               themeVM: themeVM, onAction: onAction)
        case .welcomeMenu:
            WelcomeMenu(data: data, themeVM: themeVM, onAction: onAction)
        }
    }
}
