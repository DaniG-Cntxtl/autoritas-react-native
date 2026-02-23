import SwiftUI

enum SessionViewMode { case chat, voice }

struct LiveSessionView: View {
    @StateObject private var chatVM = ChatViewModel()
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var themeVM: ThemeViewModel
    @EnvironmentObject var sessionVM: SessionViewModel

    let token: String
    let url: String

    @State private var viewMode: SessionViewMode = .chat
    @State private var isMuted: Bool = false

    var body: some View {
        ZStack {
            themeVM.backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                Divider().background(themeVM.accentColor)

                if viewMode == .chat {
                    ChatInterface(chatVM: chatVM)
                } else {
                    VoiceVisualizerView(isActive: !isMuted)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                if viewMode == .voice {
                    voiceFooter
                }
            }
        }
        .onAppear {
            // Wire callbacks before connecting
            chatVM.liveKitManager.onThemeUpdate = { theme in
                themeVM.applyTheme(theme)
            }
            chatVM.liveKitManager.onSessionDataUpdate = { data in
                sessionVM.updateData(data)
            }
            Task { await chatVM.connect(token: token, url: url) }
        }
        .onDisappear { chatVM.disconnect() }
        .ignoresSafeArea(edges: [])
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            iconButton(systemImage: "arrow.left") {
                chatVM.disconnect()
                sessionVM.clearData()
                appState.token = nil
                appState.url   = nil
                appState.currentScreen = .login
            }

            Spacer()

            VStack(spacing: 2) {
                Text("Support")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(themeVM.textColor)
                HStack(spacing: 4) {
                    Circle().fill(Color(hex: "#22c55e")).frame(width: 6, height: 6)
                    Text("LIVE CALL")
                        .font(.system(size: 10, weight: .semibold))
                        .kerning(1)
                        .foregroundColor(Color(hex: "#16a34a"))
                }
            }

            Spacer()

            iconButton(systemImage: themeVM.isDark ? "sun.max" : "moon") {
                themeVM.toggleTheme()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            themeVM.isDark
                ? Color(hex: "#101922").opacity(0.9)
                : Color.white.opacity(0.9)
        )
    }

    // MARK: - Voice Footer

    private var voiceFooter: some View {
        HStack {
            iconButton(systemImage: "keyboard") { viewMode = .chat }
                .frame(width: 56, height: 56)

            Spacer()

            Button(action: {
                chatVM.disconnect()
                appState.token = nil
                appState.url   = nil
                appState.currentScreen = .login
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "phone.down.fill")
                    Text("End Call")
                        .font(.system(size: 14, weight: .bold))
                        .kerning(1)
                }
                .foregroundColor(.white)
                .frame(height: 56)
                .frame(maxWidth: .infinity)
                .background(Color(hex: "#dc2626"))
                .clipShape(Capsule())
                .shadow(color: Color(hex: "#fca5a5").opacity(0.5), radius: 10, y: 4)
            }
            .padding(.horizontal, 16)

            Spacer()

            iconButton(systemImage: isMuted ? "mic.slash.fill" : "mic.fill",
                       tintOverride: isMuted ? Color(hex: "#ef4444") : nil) {
                chatVM.toggleMicrophone()
                isMuted = chatVM.liveKitManager.isMicEnabled == false
            }
            .frame(width: 56, height: 56)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(
            themeVM.isDark
                ? Color(hex: "#101922").opacity(0.95)
                : Color(hex: "#f8f9fa").opacity(0.95)
        )
        .overlay(Divider().background(themeVM.accentColor), alignment: .top)
    }

    // MARK: - Helper

    private func iconButton(systemImage: String, tintOverride: Color? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 18))
                .foregroundColor(tintOverride ?? themeVM.textColor)
                .frame(width: 40, height: 40)
                .background(themeVM.accentColor)
                .clipShape(Circle())
        }
    }
}
