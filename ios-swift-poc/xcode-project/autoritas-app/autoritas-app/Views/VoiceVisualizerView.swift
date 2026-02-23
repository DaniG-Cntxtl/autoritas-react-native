import SwiftUI

struct VoiceVisualizerView: View {
    let isActive: Bool

    @State private var ripple1: CGFloat = 0
    @State private var ripple2: CGFloat = 0
    @State private var ripple3: CGFloat = 0
    @State private var orbScale: CGFloat = 1.0

    private let orbSize: CGFloat = 100
    private let rippleColor = Color(hex: "#137fec")

    var body: some View {
        ZStack {
            rippleCircle(progress: ripple1)
            rippleCircle(progress: ripple2)
            rippleCircle(progress: ripple3)

            // Central orb
            ZStack {
                LinearGradient(colors: [Color(hex: "#137fec"), Color(hex: "#2563eb")],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                Image(systemName: "mic.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            .frame(width: orbSize, height: orbSize)
            .clipShape(Circle())
            .scaleEffect(orbScale)
            .shadow(color: rippleColor.opacity(0.5), radius: 12, y: 4)
        }
        .frame(width: orbSize * 3, height: orbSize * 3)
        .onChange(of: isActive) { _, active in
            if active { startAnimations() } else { stopAnimations() }
        }
        .onAppear { if isActive { startAnimations() } }
    }

    @ViewBuilder
    private func rippleCircle(progress: CGFloat) -> some View {
        Circle()
            .strokeBorder(rippleColor.opacity(0.3 * (1 - progress)), lineWidth: 2)
            .background(Circle().fill(rippleColor.opacity(0.1 * (1 - progress))))
            .frame(width: orbSize, height: orbSize)
            .scaleEffect(1 + progress * 2)
    }

    private func startAnimations() {
        // Orb pulse
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            orbScale = 1.1
        }
        // Staggered ripples
        withAnimation(.easeOut(duration: 2.0).repeatForever(autoreverses: false).delay(0.0)) {
            ripple1 = 1.0
        }
        withAnimation(.easeOut(duration: 2.0).repeatForever(autoreverses: false).delay(0.6)) {
            ripple2 = 1.0
        }
        withAnimation(.easeOut(duration: 2.0).repeatForever(autoreverses: false).delay(1.2)) {
            ripple3 = 1.0
        }
    }

    private func stopAnimations() {
        withAnimation { orbScale = 1.0; ripple1 = 0; ripple2 = 0; ripple3 = 0 }
    }
}
