import SwiftUI

struct PlanCard: View {
    let data: [String: Any]
    let actions: [WidgetAction]
    let agentMessage: String?
    let themeVM: ThemeViewModel
    let onAction: (String) -> Void

    private var name: String        { data["name"] as? String ?? "" }
    private var price: Double       { data["price"] as? Double ?? 0.0 }
    private var period: String?     { data["period"] as? String }
    private var features: [String]  { data["features"] as? [String] ?? [] }
    private var dataGb: Double?     { data["data_gb"] as? Double }
    private var calls: String?      { (data["calls_minutes"] as? Double)?.stringValue ?? data["calls_minutes"] as? String }
    private var sms: String?        { (data["sms"] as? Double)?.stringValue ?? data["sms"] as? String }
    private var badge: String?      { data["badge"] as? String }
    private var highlighted: Bool   { data["highlighted"] as? Bool ?? false }

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 8) {
                        Text(name)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(themeVM.textColor)
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("€\(Int(price))")
                                .font(.system(size: 36, weight: .black))
                                .foregroundColor(themeVM.textColor)
                            Text(period ?? "/mes")
                                .font(.system(size: 16))
                                .foregroundColor(themeVM.secondaryTextColor)
                        }
                    }
                    .padding(.bottom, 24)

                    // Highlights box
                    if dataGb != nil || calls != nil || sms != nil {
                        HStack(spacing: 24) {
                            if let gb = dataGb {
                                planHighlight(value: "\(Int(gb))GB", label: "Datos")
                            }
                            if let c = calls {
                                planHighlight(value: c, label: "Minutos")
                            }
                            if let s = sms {
                                planHighlight(value: s, label: "SMS")
                            }
                        }
                        .padding(16)
                        .background(themeVM.inputBgColor)
                        .cornerRadius(12)
                        .padding(.bottom, 24)
                    }

                    // Features
                    if !features.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(features, id: \.self) { f in
                                HStack(alignment: .top, spacing: 12) {
                                    Text("✓")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(Color(hex: "#10b981"))
                                    Text(f)
                                        .font(.system(size: 14))
                                        .foregroundColor(themeVM.textColor.opacity(0.9))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        .padding(.bottom, 24)
                    }

                    // Actions
                    if !actions.isEmpty {
                        HStack(spacing: 12) {
                            ForEach(actions) { action in
                                Button { onAction(action.id) } label: {
                                    Text(action.label)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(action.style == .secondary ? themeVM.textColor : .white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(actionGradient(action.style))
                                        .cornerRadius(12)
                                        .overlay(
                                            action.style == .secondary
                                                ? RoundedRectangle(cornerRadius: 12).stroke(themeVM.accentColor, lineWidth: 1)
                                                : nil
                                        )
                                        .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                                }
                                .disabled(action.disabled == true)
                                .opacity(action.disabled == true ? 0.5 : 1.0)
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
                        .cornerRadius(12)
                        .padding(.top, 16)
                    }
                }
                .padding(24)

                // Badge
                if let b = badge {
                    Text(b)
                        .font(.system(size: 12, weight: .bold))
                        .textCase(.uppercase)
                        .padding(.horizontal, 12).padding(.vertical, 4)
                        .background(LinearGradient(colors: [Color(hex: "#f59e0b"), Color(hex: "#d97706")],
                                                   startPoint: .topLeading, endPoint: .bottomTrailing))
                        .foregroundColor(.black)
                        .cornerRadius(20)
                        .padding(.top, 16).padding(.trailing, 16)
                }

                // Highlight Top Border
                if highlighted {
                    VStack {
                        LinearGradient(colors: [themeVM.primaryColor, themeVM.primaryColor.opacity(0.53)],
                                       startPoint: .leading, endPoint: .trailing)
                            .frame(height: 4)
                        Spacer()
                    }
                }
            }
        }
        .background(themeVM.cardBgColor)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(highlighted ? themeVM.primaryColor : themeVM.accentColor, lineWidth: 1))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }

    private func planHighlight(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.system(size: 20, weight: .bold)).foregroundColor(themeVM.primaryColor)
            Text(label).font(.system(size: 12)).textCase(.uppercase).foregroundColor(themeVM.secondaryTextColor)
        }
    }

    private func actionGradient(_ style: WidgetAction.ActionStyle?) -> LinearGradient {
        let colors: [Color]
        if style == .primary {
            colors = [themeVM.primaryColor, themeVM.primaryColor.opacity(0.8)]
        } else {
            colors = [themeVM.accentColor, themeVM.accentColor]
        }
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

extension Double {
    var stringValue: String {
        truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(self))" : String(self)
    }
}
