import SwiftUI

struct GeometricMessageBubble: View {
    let message: Message
    
    var isUser: Bool {
        return message.role == .user
    }
    
    var body: some View {
        HStack {
            if isUser { Spacer() }
            
            VStack(alignment: isUser ? .trailing : .leading) {
                if let text = message.text {
                    Text(text)
                        .font(.system(size: 16))
                        .lineSpacing(4)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            isUser ? Color.blue : Color.white.opacity(0.15)
                        )
                        .clipShape(
                            UnevenRoundedRectangle(
                                topLeadingRadius: 20,
                                bottomLeadingRadius: isUser ? 20 : 4,
                                bottomTrailingRadius: isUser ? 4 : 20,
                                topTrailingRadius: 20
                            )
                        )
                }
            }
            .frame(maxWidth: 300, alignment: isUser ? .trailing : .leading)
            
            if !isUser { Spacer() }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}
