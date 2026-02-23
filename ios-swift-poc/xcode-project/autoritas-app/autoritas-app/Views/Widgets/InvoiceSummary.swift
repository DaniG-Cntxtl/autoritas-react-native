import SwiftUI

struct InvoiceSummary: View {
    let data: [String: Any]
    let actions: [WidgetAction]
    let agentMessage: String?
    let themeVM: ThemeViewModel
    let onAction: (String) -> Void

    private var invoice: InvoiceData? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data),
              let i = try? JSONDecoder().decode(InvoiceData.self, from: jsonData) else { return nil }
        return i
    }

    var body: some View {
        if let inv = invoice {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Factura")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(themeVM.textColor)
                        if let period = inv.period {
                            Text(period).font(.caption).foregroundColor(themeVM.secondaryTextColor)
                        }
                    }
                    Spacer()
                    if let status = inv.status {
                        Text(status.uppercased())
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(statusColor(status).opacity(0.15))
                            .foregroundColor(statusColor(status))
                            .cornerRadius(4)
                    }
                }

                Divider().background(themeVM.accentColor)

                // Line items
                if let items = inv.lineItems {
                    VStack(spacing: 10) {
                        ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                            HStack {
                                Text(item.description)
                                    .font(.subheadline)
                                    .foregroundColor(themeVM.textColor.opacity(0.8))
                                Spacer()
                                Text(String(format: "€%.2f", item.amount))
                                    .font(.subheadline)
                                    .foregroundColor(themeVM.textColor)
                            }
                        }
                    }
                }

                Divider().background(themeVM.accentColor)

                // Total
                HStack {
                    Text("Total").font(.headline).foregroundColor(themeVM.textColor)
                    Spacer()
                    Text(String(format: "€%.2f", inv.total))
                        .font(.title3.bold())
                        .foregroundColor(themeVM.primaryColor)
                }

                if let due = inv.dueDate {
                    Text("Vence: \(due)").font(.caption).foregroundColor(themeVM.secondaryTextColor)
                }

                if let msg = agentMessage { WidgetAgentMessage(text: msg, themeVM: themeVM) }

                WidgetActionButtons(actions: actions, selectedActionId: nil,
                                    themeVM: themeVM, onAction: onAction)
            }
            .padding(16)
            .widgetCard(themeVM: themeVM)
            .padding(.horizontal, 16)
        }
    }

    private func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "paid":    return Color(hex: "#22c55e")
        case "overdue": return Color(hex: "#ef4444")
        default:        return Color(hex: "#f59e0b")
        }
    }
}
