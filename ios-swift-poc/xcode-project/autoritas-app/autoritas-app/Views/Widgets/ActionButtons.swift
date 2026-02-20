import SwiftUI

struct ActionButtons: View {
    let message: Message
    let onAction: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let agentMessage = message.widgetData?.agentMessage {
                Text(agentMessage)
                    .font(.body)
                    .foregroundColor(.white)
                    .padding(.horizontal)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    if let actions = message.actions {
                        ForEach(actions) { action in
                            Button(action: {
                                onAction(action.id)
                            }) {
                                Text(action.label)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(message.selectedActionId == action.id ? .white : .indigo)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(
                                        message.selectedActionId == action.id 
                                            ? Color.indigo 
                                            : Color.indigo.opacity(0.1)
                                    )
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.indigo.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
        }
    }
}
