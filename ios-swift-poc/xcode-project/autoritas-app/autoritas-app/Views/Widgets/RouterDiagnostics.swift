import SwiftUI

// RouterDiagnostics: router visualization (LED callouts) + quick_guide + diagnostics array
// Matches RouterDiagnostics.tsx exactly.

struct RouterDiagnostics: View {
    let data: [String: Any]
    let actions: [WidgetAction]
    let agentMessage: String?
    let themeVM: ThemeViewModel
    let onAction: (String) -> Void

    private var model: String   { data["model"] as? String ?? "" }
    private var status: String  { data["status"] as? String ?? "offline" }
    private var diagnostics: [[String: Any]] { data["diagnostics"] as? [[String: Any]] ?? [] }
    private var quickGuide: [String] { data["quick_guide"] as? [String] ?? [] }
    private var ipAddress: String?  { data["ip_address"] as? String }
    private var firmware: String?   { data["firmware_version"] as? String }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header: router icon + model + status
            HStack(spacing: 12) {
                Image(systemName: "wifi.router")
                    .font(.system(size: 26))
                    .foregroundColor(themeVM.textColor)
                VStack(alignment: .leading, spacing: 4) {
                    Text(model)
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(themeVM.textColor)
                    HStack(spacing: 6) {
                        Circle().fill(statusColor(status)).frame(width: 8, height: 8)
                        Text(statusLabel(status))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(statusColor(status))
                            .textCase(.uppercase)
                    }
                }
                Spacer()
                if let ip = ipAddress {
                    Text(ip)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(themeVM.secondaryTextColor)
                }
            }
            .padding(20)

            // Router LED visualization
            routerVisualization

            // Quick Guide
            if !quickGuide.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    sectionTitle("QUICK GUIDE")
                    ForEach(Array(quickGuide.enumerated()), id: \.offset) { _, item in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(themeVM.primaryColor)
                                .padding(.top, 1)
                            Text(item)
                                .font(.system(size: 13))
                                .foregroundColor(themeVM.textColor.opacity(0.8))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }

            // Diagnostics
            if !diagnostics.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    sectionTitle("DIAGNOSTICS")
                    ForEach(Array(diagnostics.enumerated()), id: \.offset) { _, diag in
                        let dStatus = diag["status"] as? String ?? ""
                        let name   = diag["name"]   as? String ?? ""
                        let value  = diag["value"]  as? String
                        HStack {
                            Image(systemName: statusIcon(dStatus))
                                .font(.system(size: 14))
                                .foregroundColor(statusColor(dStatus))
                            Text(name)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(themeVM.textColor)
                            Spacer()
                            if let v = value {
                                Text(v).font(.system(size: 13)).foregroundColor(themeVM.secondaryTextColor)
                            }
                        }
                        .padding(.vertical, 8)
                        if diag["name"] as? String != diagnostics.last?["name"] as? String {
                            Divider().background(themeVM.accentColor)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }

            // Actions bar (horizontal icon+label buttons on dark bg)
            if !actions.isEmpty {
                HStack(spacing: 0) {
                    ForEach(Array(actions.enumerated()), id: \.offset) { idx, action in
                        Button { onAction(action.id) } label: {
                            VStack(spacing: 4) {
                                Image(systemName: sfSymbol(action.icon) ?? "play.circle")
                                    .font(.system(size: 22))
                                    .foregroundColor(action.style == .primary ? themeVM.primaryColor : Color(hex: "#9ca3af"))
                                Text(action.label)
                                    .font(.system(size: 9, weight: .bold))
                                    .kerning(1)
                                    .foregroundColor(action.style == .primary ? .white : Color(hex: "#9ca3af"))
                            }
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                        }
                        if idx < actions.count - 1 {
                            Divider().background(Color.white.opacity(0.1))
                        }
                    }
                }
                .background(Color(hex: "#1c2936"))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            }

            // Agent message
            if let msg = agentMessage {
                HStack(alignment: .top, spacing: 0) {
                    Rectangle().fill(themeVM.primaryColor).frame(width: 3)
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: "brain").font(.caption).foregroundColor(themeVM.primaryColor)
                            Text("AI RECOMMENDATION").font(.system(size: 10, weight: .black)).kerning(1).foregroundColor(themeVM.primaryColor)
                        }
                        Text(msg).font(.system(size: 13)).foregroundColor(themeVM.textColor)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(themeVM.inputBgColor)
                .cornerRadius(8)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
        .widgetCard(themeVM: themeVM)
        .padding(.horizontal, 16)
    }

    // The LED router visualization
    private var routerVisualization: some View {
        HStack(spacing: 20) {
            // Router box with LEDs
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(themeVM.cardBgColor)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(themeVM.accentColor, lineWidth: 1))
                    .frame(width: 100, height: 100)
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                HStack(spacing: 10) {
                    ForEach([("#3b82f6", true), ("#22c55e", true), ("#475569", false), ("#ef4444", false)], id: \.0) { hex, glow in
                        Circle().fill(Color(hex: hex))
                            .frame(width: 10, height: 10)
                            .shadow(color: glow ? Color(hex: hex).opacity(0.6) : .clear, radius: 6)
                    }
                }
            }

            // LED callouts
            VStack(alignment: .leading, spacing: 10) {
                ForEach([("#3b82f6", "WPS"), ("#22c55e", "Internet"), ("#475569", "LAN"), ("#ef4444", "Power")], id: \.1) { hex, label in
                    HStack(spacing: 8) {
                        Circle().fill(Color(hex: hex)).frame(width: 8, height: 8)
                        Text(label).font(.system(size: 12, weight: .semibold)).foregroundColor(themeVM.textColor)
                    }
                }
            }
            Spacer()
        }
        .padding(16)
        .background(themeVM.isDark ? Color.black.opacity(0.2) : Color(hex: "#f8fafc"))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(themeVM.accentColor, lineWidth: 1))
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    private func sectionTitle(_ t: String) -> some View {
        Text(t)
            .font(.system(size: 10, weight: .black)).kerning(1.5)
            .foregroundColor(themeVM.secondaryTextColor)
            .padding(.bottom, 6)
            .overlay(Divider().background(themeVM.accentColor), alignment: .bottom)
    }

    private func statusColor(_ s: String) -> Color {
        switch s.lowercased() {
        case "online", "ok":       return Color(hex: "#10b981")
        case "offline", "error":   return Color(hex: "#ef4444")
        case "degraded", "warning": return Color(hex: "#f59e0b")
        default: return themeVM.secondaryTextColor
        }
    }
    private func statusLabel(_ s: String) -> String {
        switch s.lowercased() {
        case "online": return "Conectado"
        case "offline": return "Desconectado"
        default: return "Degradado"
        }
    }
    private func statusIcon(_ s: String) -> String {
        switch s.lowercased() {
        case "ok", "online":           return "checkmark.circle.fill"
        case "error", "offline":       return "xmark.circle.fill"
        case "warning", "degraded":    return "exclamationmark.triangle.fill"
        default:                        return "questionmark.circle.fill"
        }
    }
    private func sfSymbol(_ icon: String?) -> String? {
        guard let icon else { return nil }
        let map: [String: String] = [
            "restart_alt": "arrow.clockwise", "refresh": "arrow.clockwise",
            "wifi_find": "wifi", "play-circle-outline": "play.circle",
            "settings": "gearshape.fill", "info": "info.circle",
        ]
        return map[icon] ?? "play.circle"
    }
}
