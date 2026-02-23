import SwiftUI

// Shared helper for rendering themed action buttons at the bottom of any widget
struct WidgetActionButtons: View {
    let actions: [WidgetAction]
    let selectedActionId: String?
    let themeVM: ThemeViewModel
    let onAction: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(actions) { action in
                    let isSelected = selectedActionId == action.id
                    let isPrimary  = action.style == .primary || action.style == nil
                    Button { onAction(action.id) } label: {
                        HStack(spacing: 6) {
                            if let icon = action.icon {
                                Image(systemName: icon).font(.system(size: 12))
                            }
                            Text(action.label)
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(isSelected || isPrimary ? .white : themeVM.primaryColor)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(isSelected || isPrimary ? themeVM.primaryColor : themeVM.accentColor)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(themeVM.primaryColor.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .disabled(action.disabled == true)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}

// Shared agent message header used by several widgets
struct WidgetAgentMessage: View {
    let text: String
    let themeVM: ThemeViewModel
    var body: some View {
        Text(text)
            .font(.system(size: 15))
            .foregroundColor(themeVM.textColor)
            .padding(.horizontal, 16)
            .padding(.bottom, 4)
    }
}

// Widget card background helper
extension View {
    func widgetCard(themeVM: ThemeViewModel) -> some View {
        self
            .background(themeVM.cardBgColor)
            .cornerRadius(CGFloat(themeVM.borderRadius + 8))
            .overlay(
                RoundedRectangle(cornerRadius: CGFloat(themeVM.borderRadius + 8))
                    .stroke(themeVM.accentColor, lineWidth: CGFloat(themeVM.theme.styles.layout.borderWidth))
            )
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}
