import SwiftUI

struct TelemetryDashboard: View {
    let data: [String: Any]
    let actions: [WidgetAction]
    let agentMessage: String?
    let themeVM: ThemeViewModel
    let onAction: (String) -> Void

    private var metrics: [TelemetryMetric] {
        let raw = data["metrics"] as? [[String: Any]] ?? []
        return raw.compactMap { dict in
            guard let jsonData = try? JSONSerialization.data(withJSONObject: dict),
                  let m = try? JSONDecoder().decode(TelemetryMetric.self, from: jsonData) else { return nil }
            return m
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 16))
                    .foregroundColor(themeVM.primaryColor)
                Text(data["title"] as? String ?? "Telemetría")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(themeVM.textColor)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)

            if let msg = agentMessage {
                WidgetAgentMessage(text: msg, themeVM: themeVM).padding(.bottom, 6)
            }

            Divider().background(themeVM.accentColor).padding(.horizontal, 16)

            ForEach(metrics, id: \.stableId) { metric in
                VStack(spacing: 4) {
                    HStack {
                        Text(metric.label)
                            .font(.system(size: 13))
                            .foregroundColor(themeVM.textColor.opacity(0.8))
                        Spacer()
                        HStack(spacing: 4) {
                            Text(metric.value)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(statusColor(metric.status))
                            if let unit = metric.unit {
                                Text(unit)
                                    .font(.system(size: 11))
                                    .foregroundColor(themeVM.secondaryTextColor)
                            }
                        }
                    }

                    // Optional thin bar chart
                    if let chartVal = metric.chartValue {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(themeVM.accentColor)
                                    .frame(height: 4)
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(statusColor(metric.status))
                                    .frame(width: geo.size.width * CGFloat(min(chartVal, 1.0)), height: 4)
                            }
                        }
                        .frame(height: 4)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

                if metric.stableId != metrics.last?.stableId {
                    Divider().background(themeVM.accentColor).padding(.horizontal, 16)
                }
            }

            WidgetActionButtons(actions: actions, selectedActionId: nil,
                                themeVM: themeVM, onAction: onAction)
                .padding(.vertical, 8)
        }
        .widgetCard(themeVM: themeVM)
        .padding(.horizontal, 16)
    }

    private func statusColor(_ status: String?) -> Color {
        switch status?.lowercased() {
        case "active":   return themeVM.primaryColor
        case "warning":  return Color(hex: "#f59e0b")
        case "critical": return Color(hex: "#ef4444")
        default:         return themeVM.textColor
        }
    }
}
