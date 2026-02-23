import SwiftUI

struct InvoiceSummary: View {
    let data: [String: Any]
    let actions: [WidgetAction]
    let agentMessage: String?
    let themeVM: ThemeViewModel
    let onAction: (String) -> Void

    private var invoiceId: String { data["invoice_id"] as? String ?? "" }
    private var period: String    { data["period"] as? String ?? "" }
    private var total: Double     { data["total"] as? Double ?? 0.0 }
    private var dueDate: String?  { data["due_date"] as? String }
    private var status: String?   { data["status"] as? String }
    private var lineItems: [[String: Any]] { data["line_items"] as? [[String: Any]] ?? [] }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Factura")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(themeVM.textColor)
                    Text("#\(invoiceId)")
                        .font(.system(size: 14))
                        .foregroundColor(themeVM.secondaryTextColor)
                }
                Spacer()
                if let s = status {
                    Text(statusLabel(s))
                        .font(.system(size: 12, weight: .semibold))
                        .textCase(.uppercase)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(statusColor(s))
                        .cornerRadius(20)
                }
            }
            .padding(.bottom, 24)

            // Body
            VStack(spacing: 0) {
                // Period row
                HStack {
                    Text("Período").font(.system(size: 14)).foregroundColor(themeVM.secondaryTextColor)
                    Spacer()
                    Text(period).font(.system(size: 14, weight: .medium)).foregroundColor(themeVM.textColor)
                }
                .padding(.vertical, 12)
                Divider().background(themeVM.accentColor)

                // Due date row
                if let due = dueDate {
                    HStack {
                        Text("Vencimiento").font(.system(size: 14)).foregroundColor(themeVM.secondaryTextColor)
                        Spacer()
                        Text(due).font(.system(size: 14, weight: .medium)).foregroundColor(themeVM.textColor)
                    }
                    .padding(.vertical, 12)
                    Divider().background(themeVM.accentColor)
                }

                // Line items
                if !lineItems.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(Array(lineItems.enumerated()), id: \.offset) { _, item in
                            HStack {
                                Text(item["description"] as? String ?? "")
                                    .font(.system(size: 14))
                                    .foregroundColor(themeVM.textColor.opacity(0.8))
                                Spacer()
                                let amt = item["amount"] as? Double ?? 0
                                Text(String(format: "€%.2f", amt))
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(themeVM.textColor)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .padding(.vertical, 12)
                }

                // Total row
                VStack(spacing: 0) {
                    Rectangle().fill(themeVM.accentColor).frame(height: 2)
                    HStack {
                        Text("Total").font(.system(size: 18, weight: .semibold)).foregroundColor(themeVM.textColor)
                        Spacer()
                        Text(String(format: "€%.2f", total))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(themeVM.primaryColor)
                    }
                    .padding(.top, 16)
                }
                .padding(.top, 8)
            }
            .padding(.bottom, 24)

            // Actions
            if !actions.isEmpty {
                HStack(spacing: 12) {
                    ForEach(actions) { action in
                        Button { onAction(action.id) } label: {
                            Text(action.label)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(action.style == .secondary ? themeVM.textColor : .white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(actionGradient(action.style))
                                .cornerRadius(10)
                                .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                        }
                    }
                }
            }

            // Agent Message
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
        .background(themeVM.cardBgColor)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(themeVM.accentColor, lineWidth: 1))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }

    private func statusColor(_ s: String) -> Color {
        switch s.lowercased() {
        case "paid":    return Color(hex: "#10b981")
        case "overdue": return Color(hex: "#ef4444")
        default:        return Color(hex: "#f59e0b")
        }
    }

    private func statusLabel(_ s: String) -> String {
        switch s.lowercased() {
        case "paid":    return "Pagada"
        case "overdue": return "Vencida"
        default:        return "Pendiente"
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
