import SwiftUI

struct WelcomeMenu: View {
    let data: [String: Any]
    let themeVM: ThemeViewModel
    let onAction: (String) -> Void

    // Matches the real backend schema: { greeting, options: [{ id, title, description, icon, color_theme }] }
    private var options: [[String: Any]] {
        data["options"] as? [[String: Any]] ?? []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Big greeting header
            Text(data["greeting"] as? String ?? "Hola,\n¿qué quieres\nhacer hoy?")
                .font(.system(size: 28, weight: .black))
                .foregroundColor(themeVM.textColor)
                .lineSpacing(2)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 20)

            // Vertical list of menu tiles (not a grid — matches original)
            VStack(spacing: 4) {
                ForEach(Array(options.enumerated()), id: \.offset) { _, opt in
                    optionTile(opt)
                }
            }
            .padding(.bottom, 12)
        }
        .widgetCard(themeVM: themeVM)
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func optionTile(_ opt: [String: Any]) -> some View {
        let id    = opt["id"]          as? String ?? ""
        let title = opt["title"]       as? String ?? ""
        let desc  = opt["description"] as? String ?? ""
        let icon  = opt["icon"]        as? String ?? "circle"
        let ct    = opt["color_theme"] as? String ?? "blue"
        let accent = accentColor(ct)
        let category = categoryLabel(ct)

        Button { onAction(id) } label: {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(category)
                        .font(.system(size: 10, weight: .black))
                        .kerning(1.5)
                        .foregroundColor(accent)

                    Text(title)
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(themeVM.textColor)
                        .multilineTextAlignment(.leading)

                    Text(desc)
                        .font(.system(size: 13))
                        .foregroundColor(themeVM.secondaryTextColor)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: sfSymbol(icon))
                    .font(.system(size: 26))
                    .foregroundColor(accent.opacity(0.5))
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(themeVM.cardBgColor)
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(accent)
                    .frame(width: 4)
            }
            .cornerRadius(CGFloat(themeVM.borderRadius + 2))
            .clipped()
        }
        .buttonStyle(.plain)
    }

    private func accentColor(_ ct: String) -> Color {
        switch ct {
        case "blue":    return Color(hex: "#3b82f6")
        case "purple":  return Color(hex: "#a855f7")
        case "emerald": return Color(hex: "#10b981")
        case "amber":   return Color(hex: "#f59e0b")
        default:        return themeVM.primaryColor
        }
    }

    private func categoryLabel(_ ct: String) -> String {
        switch ct {
        case "blue":    return "SUPPORT"
        case "purple":  return "OFFERS"
        case "emerald": return "FINANCE"
        case "amber":   return "ACCOUNT"
        default:        return ct.uppercased()
        }
    }

    private func sfSymbol(_ icon: String) -> String {
        let map: [String: String] = [
            "wifi":              "wifi",
            "wifi_off":          "wifi.slash",
            "phone":             "phone.fill",
            "router":            "wifi.router",
            "receipt":           "doc.text.fill",
            "receipt_long":      "doc.richtext",
            "payment":           "banknote",
            "devices":           "iphone",
            "phone_android":     "iphone",
            "local_offer":       "tag.fill",
            "discount":          "percent",
            "settings":          "gearshape.fill",
            "manage_accounts":   "person.badge.gear",
            "support_agent":     "headphones",
            "help":              "questionmark.circle.fill",
            "build":             "wrench.and.screwdriver",
            "speed":             "gauge.with.needle",
            "signal_cellular_alt": "antenna.radiowaves.left.and.right",
        ]
        return map[icon] ?? "circle.grid.2x2.fill"
    }
}
