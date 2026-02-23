import SwiftUI

// TelemetryDashboard: 2-column card grid with:
//   - Data Usage card: circular progress ring + used/total
//   - Network Status card: animated signal bars + status
//   Plus a horizontal "QUICK ACTIONS" scroll of action cards.
// Data schema: { data_usage?: {used, total, unit, percentage},
//               network_status?: {status, network_type, location, signal_level 1-4} }
// Matches TelemetryDashboard.tsx exactly.

struct TelemetryDashboard: View {
    let data: [String: Any]
    let actions: [WidgetAction]
    let agentMessage: String?
    let themeVM: ThemeViewModel
    let onAction: (String) -> Void

    private var dataUsage: [String: Any]?     { data["data_usage"]     as? [String: Any] }
    private var networkStatus: [String: Any]? { data["network_status"] as? [String: Any] }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 2-column cards grid
            if dataUsage != nil || networkStatus != nil {
                HStack(spacing: 12) {
                    if let du = dataUsage    { dataUsageCard(du).frame(maxWidth: .infinity) }
                    if let ns = networkStatus { networkCard(ns).frame(maxWidth: .infinity) }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }

            // Quick Actions carousel
            if !actions.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("QUICK ACTIONS")
                        .font(.system(size: 10, weight: .black)).kerning(1)
                        .foregroundColor(themeVM.secondaryTextColor)
                        .padding(.leading, 16)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(actions) { action in
                                Button { onAction(action.id) } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: sfSymbol(action.icon) ?? "star.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(actionColor(action.style))
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(action.label)
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(themeVM.textColor)
                                            // description from WidgetAction is not in our model, use label fallback
                                        }
                                    }
                                    .padding(.horizontal, 16).padding(.vertical, 12)
                                    .frame(minWidth: 160, alignment: .leading)
                                    .background(themeVM.cardBgColor)
                                    .cornerRadius(14)
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(themeVM.accentColor, lineWidth: 1))
                                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                    }
                }
            }

            // Agent message
            if let msg = agentMessage {
                HStack(alignment: .top, spacing: 0) {
                    Rectangle().fill(themeVM.primaryColor).frame(width: 3)
                    Text(msg).font(.system(size: 14)).foregroundColor(themeVM.textColor)
                        .padding(14).frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(themeVM.inputBgColor)
                .cornerRadius(8)
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            } else {
                Spacer().frame(height: 12)
            }
        }
        .widgetCard(themeVM: themeVM)
        .padding(.horizontal, 16)
    }

    // Data Usage: circular ring with percentage
    @ViewBuilder
    private func dataUsageCard(_ du: [String: Any]) -> some View {
        let pct    = du["percentage"] as? Int ?? 0
        let used   = du["used"]  as? Double ?? 0
        let total  = du["total"] as? Double ?? 0
        let unit   = du["unit"]  as? String ?? "GB"

        VStack(spacing: 0) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10).fill(themeVM.primaryColor.opacity(0.1))
                        .frame(width: 34, height: 34)
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 18)).foregroundColor(themeVM.primaryColor)
                }
                Spacer()
                Image(systemName: "arrow.up.right").font(.system(size: 14)).foregroundColor(themeVM.secondaryTextColor)
            }
            .padding(.bottom, 12)

            // Ring (approximated with overlapping stroked circle)
            ZStack {
                Circle()
                    .stroke(themeVM.accentColor, lineWidth: 6)
                    .frame(width: 78, height: 78)
                Circle()
                    .trim(from: 0, to: CGFloat(pct) / 100)
                    .stroke(themeVM.primaryColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 78, height: 78)
                    .rotationEffect(.degrees(-90))
                Text("\(pct)%")
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(themeVM.textColor)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 12)

            VStack(spacing: 2) {
                Text("Data Usage").font(.system(size: 11, weight: .medium)).foregroundColor(themeVM.secondaryTextColor)
                Text("\(formatNum(used)) / \(formatNum(total)) \(unit)")
                    .font(.system(size: 12, weight: .bold)).foregroundColor(themeVM.textColor)
            }
        }
        .padding(14)
        .background(themeVM.cardBgColor)
        .cornerRadius(22)
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(themeVM.accentColor, lineWidth: 1))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
    }

    // Network Status: 4 signal bars + status label
    @ViewBuilder
    private func networkCard(_ ns: [String: Any]) -> some View {
        let status      = ns["status"]       as? String ?? ""
        let netType     = ns["network_type"] as? String ?? ""
        let location    = ns["location"]     as? String ?? ""
        let signalLevel = ns["signal_level"] as? Int ?? 0

        let sigColor: Color = signalLevel >= 3 ? Color(hex: "#22c55e")
                            : signalLevel == 2 ? Color(hex: "#f59e0b")
                            : Color(hex: "#ef4444")

        VStack(spacing: 0) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10).fill(Color(hex: "#22c55e").opacity(0.1))
                        .frame(width: 34, height: 34)
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 16)).foregroundColor(Color(hex: "#22c55e"))
                }
                Spacer()
                Image(systemName: "arrow.clockwise").font(.system(size: 14)).foregroundColor(themeVM.secondaryTextColor)
            }
            .padding(.bottom, 12)

            // Signal bars
            VStack(spacing: 8) {
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(1...4, id: \.self) { bar in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(bar <= signalLevel ? sigColor : themeVM.accentColor)
                            .frame(width: 9, height: CGFloat(12 + bar * 8))
                    }
                }
                .frame(maxWidth: .infinity)

                Text(status.uppercased())
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(sigColor)
            }
            .padding(.bottom, 12)

            VStack(spacing: 2) {
                Text("Network Status").font(.system(size: 11, weight: .medium)).foregroundColor(themeVM.secondaryTextColor)
                Text("\(netType) • \(location)")
                    .font(.system(size: 12, weight: .bold)).foregroundColor(themeVM.textColor)
            }
        }
        .padding(14)
        .background(themeVM.cardBgColor)
        .cornerRadius(22)
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(themeVM.accentColor, lineWidth: 1))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
    }

    private func actionColor(_ style: WidgetAction.ActionStyle?) -> Color {
        switch style {
        case .success:   return Color(hex: "#22c55e")
        case .danger:    return Color(hex: "#ef4444")
        case .secondary: return themeVM.textColor
        default:         return themeVM.primaryColor
        }
    }

    private func sfSymbol(_ icon: String?) -> String? {
        guard let icon else { return nil }
        let map: [String: String] = [
            "speed": "gauge.with.needle",
            "wifi": "wifi",
            "signal_cellular_alt": "antenna.radiowaves.left.and.right",
            "data-usage": "chart.bar.fill",
            "star": "star.fill",
            "refresh": "arrow.clockwise",
            "restart_alt": "arrow.clockwise",
        ]
        return map[icon] ?? "star.fill"
    }

    private func formatNum(_ n: Double) -> String {
        n.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(n))" : String(format: "%.1f", n)
    }
}
