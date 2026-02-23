import SwiftUI

struct RouterDiagnostics: View {
    let data: [String: Any]
    let actions: [WidgetAction]
    let agentMessage: String?
    let themeVM: ThemeViewModel
    let onAction: (String) -> Void

    private var metrics: [DiagnosticMetric] {
        let raw = data["metrics"] as? [[String: Any]] ?? []
        return raw.compactMap { dict in
            guard let jsonData = try? JSONSerialization.data(withJSONObject: dict),
                  let m = try? JSONDecoder().decode(DiagnosticMetric.self, from: jsonData) else { return nil }
            return m
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "wifi.router")
                    .font(.system(size: 18))
                    .foregroundColor(themeVM.primaryColor)
                Text(data["title"] as? String ?? "Diagnóstico del Router")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(themeVM.textColor)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)

            if let msg = agentMessage { WidgetAgentMessage(text: msg, themeVM: themeVM) }

            Divider().background(themeVM.accentColor).padding(.horizontal, 16)

            VStack(spacing: 0) {
                ForEach(metrics, id: \.stableId) { metric in
                    HStack {
                        // Status indicator
                        Circle()
                            .fill(statusColor(metric.status))
                            .frame(width: 8, height: 8)

                        Text(metric.label)
                            .font(.system(size: 14))
                            .foregroundColor(themeVM.textColor)

                        Spacer()

                        Text(metric.value)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(statusColor(metric.status))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)

                    if metric.stableId != metrics.last?.stableId {
                        Divider().background(themeVM.accentColor).padding(.horizontal, 16)
                    }
                }
            }

            WidgetActionButtons(actions: actions, selectedActionId: nil,
                                themeVM: themeVM, onAction: onAction)
                .padding(.bottom, 8)
        }
        .widgetCard(themeVM: themeVM)
        .padding(.horizontal, 16)
    }

    private func statusColor(_ status: String?) -> Color {
        switch status?.lowercased() {
        case "ok":       return Color(hex: "#22c55e")
        case "warning":  return Color(hex: "#f59e0b")
        case "critical": return Color(hex: "#ef4444")
        default:         return themeVM.secondaryTextColor
        }
    }
}
