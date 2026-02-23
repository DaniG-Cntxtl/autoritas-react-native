import SwiftUI

struct DocumentPreview: View {
    let data: [String: Any]
    let actions: [WidgetAction]
    let agentMessage: String?
    let themeVM: ThemeViewModel
    let onAction: (String) -> Void

    private var doc: DocumentData? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data),
              let d = try? JSONDecoder().decode(DocumentData.self, from: jsonData) else { return nil }
        return d
    }

    var body: some View {
        if let d = doc {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 14) {
                    // Thumbnail / icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(themeVM.primaryColor.opacity(0.12))
                            .frame(width: 56, height: 70)
                        Image(systemName: fileIcon(d.fileType))
                            .font(.system(size: 26))
                            .foregroundColor(themeVM.primaryColor)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(d.title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(themeVM.textColor)
                            .lineLimit(2)

                        if let type = d.fileType {
                            Text(type.uppercased())
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(themeVM.primaryColor)
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(themeVM.primaryColor.opacity(0.12))
                                .cornerRadius(4)
                        }

                        if let size = d.sizeLabel {
                            Text(size)
                                .font(.caption)
                                .foregroundColor(themeVM.secondaryTextColor)
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)

                if let msg = agentMessage { WidgetAgentMessage(text: msg, themeVM: themeVM) }

                WidgetActionButtons(actions: actions, selectedActionId: nil,
                                    themeVM: themeVM, onAction: onAction)
                    .padding(.bottom, 8)
            }
            .widgetCard(themeVM: themeVM)
            .padding(.horizontal, 16)
        }
    }

    private func fileIcon(_ type: String?) -> String {
        switch type?.lowercased() {
        case "pdf":                          return "doc.richtext"
        case "docx", "doc":                  return "doc.text"
        case "xlsx", "xls", "csv":           return "tablecells"
        case "pptx", "ppt":                  return "rectangle.on.rectangle"
        case "jpg", "jpeg", "png", "webp":   return "photo"
        default:                             return "doc"
        }
    }
}
