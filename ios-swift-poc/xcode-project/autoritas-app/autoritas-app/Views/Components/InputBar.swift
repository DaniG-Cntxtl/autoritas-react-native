import SwiftUI

struct InputBar: View {
    @Binding var text: String
    let onSend: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                HStack {
                    TextField("iMessage", text: $text)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                        .padding(.horizontal, 12)
                        .frame(height: 40)
                    
                    if !text.isEmpty {
                        Button(action: { text = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .padding(.trailing, 8)
                    }
                }
                .background(Color.white.opacity(0.15))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                
                Button(action: onSend) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color(red: 0.19, green: 0.82, blue: 0.35)) // #30d158
                        .clipShape(Circle())
                        .scaleEffect(text.isEmpty ? 0.8 : 1.0)
                        .opacity(text.isEmpty ? 0.5 : 1.0)
                }
                .disabled(text.isEmpty)
                .animation(.spring(), value: text.isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 20)
            .background(Color.clear)
        }
    }
}
