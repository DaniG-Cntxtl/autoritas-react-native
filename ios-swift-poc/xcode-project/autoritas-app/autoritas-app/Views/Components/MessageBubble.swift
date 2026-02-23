import SwiftUI

struct MessageBubble: View {
    let message: Message
    let themeVM: ThemeViewModel

    private var isUser: Bool { message.role == .user }
    private var isInterim: Bool { !message.isFinal }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isUser { Spacer(minLength: 60) }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                Text(message.text ?? "")
                    .font(.system(size: 15))
                    .foregroundColor(isUser ? .white : themeVM.textColor)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(isUser ? themeVM.bubbleUserColor : themeVM.bubbleAgentColor)
                    .cornerRadius(CGFloat(themeVM.borderRadius == 4 ? 18 : themeVM.borderRadius))
                    .opacity(isInterim ? 0.6 : 1.0)

                if isInterim {
                    Text("…")
                        .font(.caption2)
                        .foregroundColor(themeVM.secondaryTextColor)
                }
            }

            if !isUser { Spacer(minLength: 60) }
        }
    }
}
