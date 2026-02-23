import SwiftUI

struct MessageBubble: View {
    let message: Message
    let themeVM: ThemeViewModel

    private var isUser: Bool { message.role == .user }
    private var isInterim: Bool { !message.isFinal }

    // Fade-in for agent messages (mirrors GeometricMessageBubble / MessageBubble.tsx)
    @State private var opacity: Double = 0

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isUser {
                Spacer(minLength: 60)
            } else {
                // Agent avatar — ✨ sparkles icon
                ZStack {
                    Circle()
                        .fill(themeVM.cardBgColor)
                        .frame(width: 32, height: 32)
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundColor(themeVM.primaryColor)
                }
                .overlay(Circle().stroke(themeVM.accentColor, lineWidth: 1))
            }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                HStack(spacing: 0) {
                    // 4px left accent border for agent messages
                    if !isUser {
                        Rectangle()
                            .fill(themeVM.primaryColor)
                            .frame(width: 4)
                            .cornerRadius(2)
                    }

                    Text(message.text ?? "")
                        .font(.system(size: 15))
                        .lineSpacing(4)
                        .foregroundColor(isUser ? .white : themeVM.textColor)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .italic(isInterim)
                        .opacity(isInterim ? 0.7 : 1.0)
                }
                .background(isUser ? themeVM.bubbleUserColor : themeVM.bubbleAgentColor)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius:     isUser ? 12 : 2,
                        bottomLeadingRadius:  isUser ? 12 : 2,
                        bottomTrailingRadius: isUser ? 2  : 12,
                        topTrailingRadius:    isUser ? 2  : 12
                    )
                )
                .shadow(color: .black.opacity(0.05), radius: 2, y: 1)

                // Interim indicator
                if isInterim {
                    Text("transcribiendo…")
                        .font(.system(size: 10))
                        .foregroundColor(themeVM.secondaryTextColor)
                }
            }

            if isUser {
                // User avatar — person icon
                ZStack {
                    Circle()
                        .fill(themeVM.bubbleUserColor)
                        .frame(width: 32, height: 32)
                    Image(systemName: "person.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }
            } else {
                Spacer(minLength: 60)
            }
        }
        .opacity(opacity)
        .onAppear {
            if isUser {
                opacity = 1.0  // instant for user
            } else {
                withAnimation(.easeIn(duration: 0.3)) { opacity = 1.0 }
            }
        }
    }
}
