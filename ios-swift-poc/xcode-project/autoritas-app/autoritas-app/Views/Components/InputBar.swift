import SwiftUI

struct InputBar: View {
    @Binding var text: String
    let themeVM: ThemeViewModel
    let onSend: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            TextField("Type a message...", text: $text, axis: .vertical)
                .font(.system(size: 16))
                .foregroundColor(themeVM.textColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(themeVM.inputBgColor)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(themeVM.accentColor, lineWidth: 1))
                .lineLimit(1...4)
                .onSubmit { onSend() }

            Button(action: onSend) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        ? themeVM.primaryColor.opacity(0.4)
                        : themeVM.primaryColor)
                    .clipShape(Circle())
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .animation(.easeInOut(duration: 0.15), value: text.isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .background(themeVM.cardBgColor)
        .overlay(Divider().background(themeVM.accentColor), alignment: .top)
    }
}
