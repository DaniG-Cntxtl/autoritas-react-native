import SwiftUI

struct ActionButtons: View {
    let data: [String: Any]
    let actions: [WidgetAction]
    let agentMessage: String?
    let selectedActionId: String?
    let themeVM: ThemeViewModel
    let onAction: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title = data["title"] as? String {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(themeVM.secondaryTextColor)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
            }
            if let msg = agentMessage {
                WidgetAgentMessage(text: msg, themeVM: themeVM)
            }
            if !actions.isEmpty {
                WidgetActionButtons(actions: actions, selectedActionId: selectedActionId,
                                    themeVM: themeVM, onAction: onAction)
                    .padding(.bottom, 8)
            }
        }
        .widgetCard(themeVM: themeVM)
        .padding(.horizontal, 16)
    }
}
