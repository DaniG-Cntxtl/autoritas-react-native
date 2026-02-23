import SwiftUI

struct WelcomeMenu: View {
    let data: [String: Any]
    let themeVM: ThemeViewModel
    let onAction: (String) -> Void

    private var categories: [WelcomeCategory] {
        let raw = data["categories"] as? [[String: Any]] ?? []
        return raw.compactMap { dict in
            guard let id = dict["id"] as? String,
                  let label = dict["label"] as? String else { return nil }
            return WelcomeCategory(id: id, label: label, icon: dict["icon"] as? String)
        }
    }

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Greeting
            if let greeting = data["greeting"] as? String {
                VStack(alignment: .leading, spacing: 4) {
                    Image(systemName: "hand.wave.fill")
                        .font(.system(size: 28))
                        .foregroundColor(themeVM.primaryColor)
                    Text(greeting)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(themeVM.textColor)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }

            Text("¿En qué puedo ayudarte?")
                .font(.system(size: 13))
                .foregroundColor(themeVM.secondaryTextColor)
                .padding(.horizontal, 16)

            // Category grid
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(categories) { category in
                    Button { onAction(category.id) } label: {
                        HStack(spacing: 10) {
                            if let iconName = sfSymbol(category.icon) {
                                Image(systemName: iconName)
                                    .font(.system(size: 18))
                                    .foregroundColor(themeVM.primaryColor)
                                    .frame(width: 28)
                            }
                            Text(category.label)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(themeVM.textColor)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(themeVM.inputBgColor)
                        .cornerRadius(CGFloat(themeVM.borderRadius + 4))
                        .overlay(
                            RoundedRectangle(cornerRadius: CGFloat(themeVM.borderRadius + 4))
                                .stroke(themeVM.accentColor, lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .widgetCard(themeVM: themeVM)
        .padding(.horizontal, 16)
    }

    private func sfSymbol(_ icon: String?) -> String? {
        guard let icon else { return "questionmark.circle" }
        // Map common icon names to SF Symbols
        let mapping: [String: String] = [
            "phone": "phone.fill",
            "wifi": "wifi",
            "invoice": "doc.text.fill",
            "bill": "banknote",
            "device": "iphone",
            "plan": "antenna.radiowaves.left.and.right",
            "support": "headphones",
            "chat": "bubble.left.fill",
            "settings": "gearshape.fill",
            "help": "questionmark.circle.fill",
            "outage": "exclamationmark.triangle.fill",
            "contract": "doc.badge.clock",
        ]
        return mapping[icon.lowercased()] ?? "circle.grid.2x2.fill"
    }
}
