import SwiftUI

struct PlanCard: View {
    let data: [String: Any]
    let actions: [WidgetAction]
    let agentMessage: String?
    let themeVM: ThemeViewModel
    let onAction: (String) -> Void

    private var plan: PlanData? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data),
              let p = try? JSONDecoder().decode(PlanData.self, from: jsonData) else { return nil }
        return p
    }

    var body: some View {
        if let p = plan {
            ZStack(alignment: .top) {
                LinearGradient(
                    colors: [themeVM.primaryColor.opacity(0.15), themeVM.cardBgColor],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(p.highlighted == true ? themeVM.primaryColor : themeVM.accentColor,
                                lineWidth: p.highlighted == true ? 2 : 1)
                )

                // Highlighted accent top bar
                if p.highlighted == true {
                    LinearGradient(colors: [themeVM.primaryColor, themeVM.primaryColor.opacity(0.6)],
                                   startPoint: .leading, endPoint: .trailing)
                    .frame(height: 3)
                    .clipShape(UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20))
                }

                VStack(spacing: 20) {
                    // Badge
                    if let badge = p.badge {
                        HStack {
                            Spacer()
                            Text(badge)
                                .font(.system(size: 11, weight: .bold))
                                .padding(.horizontal, 12).padding(.vertical, 4)
                                .background(LinearGradient(colors: [.orange, .yellow], startPoint: .leading, endPoint: .trailing))
                                .foregroundColor(.black)
                                .cornerRadius(20)
                        }
                    }

                    // Name + Price
                    VStack(spacing: 6) {
                        Text(p.name)
                            .font(.title2.bold())
                            .foregroundColor(themeVM.textColor)
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("€\(Int(p.price))")
                                .font(.system(size: 40, weight: .black))
                                .foregroundColor(themeVM.textColor)
                            Text(p.period ?? "/mes")
                                .font(.subheadline)
                                .foregroundColor(themeVM.secondaryTextColor)
                        }
                    }

                    // Data / Minutes / SMS highlights
                    HStack(spacing: 24) {
                        if let gb = p.dataGb {
                            planHighlight(value: "\(gb)GB", label: "DATOS")
                        }
                        if let mins = p.callsMinutes {
                            planHighlight(value: mins.stringValue, label: "MINUTOS")
                        }
                        if let sms = p.sms {
                            planHighlight(value: sms.stringValue, label: "SMS")
                        }
                    }
                    .padding(14)
                    .background(themeVM.primaryColor.opacity(0.08))
                    .cornerRadius(10)

                    // Features
                    if let features = p.features {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(features, id: \.self) { f in
                                Label(f, systemImage: "checkmark")
                                    .font(.system(size: 13))
                                    .foregroundColor(themeVM.textColor)
                                    .labelStyle(.titleAndIcon)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Actions
                    WidgetActionButtons(actions: actions, selectedActionId: nil,
                                        themeVM: themeVM, onAction: onAction)
                        .padding(.horizontal, -16)
                }
                .padding(24)
            }
            .padding(.horizontal, 16)

            if let msg = agentMessage {
                WidgetAgentMessage(text: msg, themeVM: themeVM)
            }
        }
    }

    private func planHighlight(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.system(size: 15, weight: .bold)).foregroundColor(themeVM.primaryColor)
            Text(label).font(.system(size: 9, weight: .semibold)).foregroundColor(themeVM.secondaryTextColor)
        }
    }
}
