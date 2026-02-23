import SwiftUI

// DocumentPreview: renders a rich "paper" invoice document with a header bar,
// BILLED TO / ISSUED meta section, line items table, totals, footer note.
// Data schema: { type, document_id, date, company_name, company_address,
//               billed_to: {name, details?}, items: [{description, amount?, value?}],
//               subtotal?, total?, footer_note? }
// Matches DocumentPreview.tsx exactly.

struct DocumentPreview: View {
    let data: [String: Any]
    let actions: [WidgetAction]
    let agentMessage: String?
    let themeVM: ThemeViewModel
    let onAction: (String) -> Void

    private var docType: String      { data["type"] as? String ?? "DOCUMENT" }
    private var docId: String        { data["document_id"] as? String ?? "" }
    private var docDate: String?     { data["date"] as? String }
    private var companyName: String  { data["company_name"] as? String ?? "Autoritas" }
    private var companyAddress: String? { data["company_address"] as? String }
    private var billedTo: [String: Any]? { data["billed_to"] as? [String: Any] }
    private var items: [[String: Any]] { data["items"] as? [[String: Any]] ?? [] }
    private var subtotal: String?    { data["subtotal"] as? String }
    private var total: String?       { data["total"] as? String }
    private var footerNote: String?  { data["footer_note"] as? String }

    var body: some View {
        VStack(spacing: 0) {
            // Top bar (filename + "PDF Document" label)
            HStack {
                Image(systemName: "doc.fill")
                    .font(.system(size: 13))
                    .foregroundColor(themeVM.textColor)
                Text("\(docId).pdf")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(themeVM.textColor)
                    .lineLimit(1)
                Spacer()
                Text("PDF Document")
                    .font(.system(size: 10))
                    .foregroundColor(themeVM.secondaryTextColor)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(themeVM.accentColor)
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: CGFloat(themeVM.borderRadius + 8),
                                              topTrailingRadius: CGFloat(themeVM.borderRadius + 8)))

            // Paper (white always, as per original)
            VStack(alignment: .leading, spacing: 0) {
                // Doc header: type + company
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(docType)
                            .font(.system(size: 20, weight: .black))
                            .foregroundColor(Color(hex: "#0f172a"))
                        Text("#\(docId)")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(Color(hex: "#64748b"))
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(companyName.uppercased())
                            .font(.system(size: 12, weight: .black))
                            .kerning(1)
                            .foregroundColor(themeVM.primaryColor)
                        if let addr = companyAddress {
                            Text(addr)
                                .font(.system(size: 9))
                                .foregroundColor(Color(hex: "#94a3b8"))
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }
                .padding(.bottom, 16)

                Divider().background(Color(hex: "#f1f5f9"))

                // BILLED TO / ISSUED row
                HStack(alignment: .top) {
                    if let bt = billedTo {
                        VStack(alignment: .leading, spacing: 4) {
                            metaLabel("BILLED TO")
                            Text(bt["name"] as? String ?? "")
                                .font(.system(size: 12, weight: .bold)).foregroundColor(Color(hex: "#0f172a"))
                            if let details = bt["details"] as? String {
                                Text(details).font(.system(size: 11)).foregroundColor(Color(hex: "#64748b"))
                            }
                        }
                        Spacer()
                    }
                    if let date = docDate {
                        VStack(alignment: .trailing, spacing: 4) {
                            metaLabel("ISSUED")
                            Text(date).font(.system(size: 12, weight: .bold)).foregroundColor(Color(hex: "#0f172a"))
                        }
                    }
                }
                .padding(.vertical, 16)

                // Table header
                HStack {
                    Text("DESCRIPTION")
                        .font(.system(size: 9, weight: .bold)).kerning(1).foregroundColor(Color(hex: "#94a3b8"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("AMOUNT")
                        .font(.system(size: 9, weight: .bold)).kerning(1).foregroundColor(Color(hex: "#94a3b8"))
                        .frame(width: 80, alignment: .trailing)
                }
                .padding(.bottom, 8)
                Divider().background(Color(hex: "#e2e8f0")).overlay(Divider(), alignment: .top)

                // Table rows
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    HStack {
                        Text(item["description"] as? String ?? "")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "#0f172a"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        let val = (item["amount"] as? String) ?? (item["value"] as? String) ?? ""
                        Text(val)
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#475569"))
                            .frame(width: 80, alignment: .trailing)
                    }
                    .padding(.vertical, 12)
                    Divider().background(Color(hex: "#f8fafc"))
                }

                // Totals
                if subtotal != nil || total != nil {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            if let s = subtotal {
                                HStack {
                                    Text("Subtotal").font(.system(size: 12)).foregroundColor(Color(hex: "#64748b"))
                                    Spacer()
                                    Text(s).font(.system(size: 12)).foregroundColor(Color(hex: "#64748b"))
                                }
                            }
                            if let t = total {
                                Divider().background(Color(hex: "#e2e8f0"))
                                HStack {
                                    Text("Total").font(.system(size: 14, weight: .black)).foregroundColor(themeVM.primaryColor)
                                    Spacer()
                                    Text(t).font(.system(size: 16, weight: .black)).foregroundColor(themeVM.primaryColor)
                                }
                            }
                        }
                        .frame(width: 200)
                    }
                    .padding(.top, 16)
                }

                // Footer note
                if let note = footerNote {
                    Divider().background(Color(hex: "#f1f5f9")).padding(.top, 20)
                    Text(note)
                        .font(.system(size: 9))
                        .foregroundColor(Color(hex: "#94a3b8"))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 12)
                }
            }
            .padding(20)
            .background(Color.white)
            .shadow(color: .black.opacity(0.12), radius: 12, y: 6)

            // Download / action bar
            if !actions.isEmpty {
                HStack(spacing: 0) {
                    ForEach(Array(actions.enumerated()), id: \.offset) { idx, action in
                        Button { onAction(action.id) } label: {
                            VStack(spacing: 4) {
                                Image(systemName: fileActionIcon(action.icon))
                                    .font(.system(size: 18))
                                    .foregroundColor(themeVM.secondaryTextColor)
                                Text(action.label)
                                    .font(.system(size: 9, weight: .bold)).kerning(1)
                                    .foregroundColor(themeVM.secondaryTextColor)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        }
                        if idx < actions.count - 1 {
                            Divider().background(themeVM.accentColor)
                        }
                    }
                }
                .background(themeVM.cardBgColor)
                .overlay(RoundedRectangle(cornerRadius: CGFloat(themeVM.borderRadius + 8))
                    .stroke(themeVM.accentColor, lineWidth: 1))
                .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: CGFloat(themeVM.borderRadius + 8),
                                                  bottomTrailingRadius: CGFloat(themeVM.borderRadius + 8)))
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
                .padding(.top, 12)
            }
        }
        .padding(.horizontal, 16)
    }

    private func metaLabel(_ t: String) -> some View {
        Text(t).font(.system(size: 9, weight: .bold)).kerning(1).foregroundColor(Color(hex: "#94a3b8"))
    }

    private func fileActionIcon(_ icon: String?) -> String {
        let map: [String: String] = [
            "file-download": "arrow.down.doc",
            "download": "arrow.down.circle",
            "print": "printer",
            "share": "square.and.arrow.up",
        ]
        return map[icon ?? ""] ?? "arrow.down.doc"
    }
}
