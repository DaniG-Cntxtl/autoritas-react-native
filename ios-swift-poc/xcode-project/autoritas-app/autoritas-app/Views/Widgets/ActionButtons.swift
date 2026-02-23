import SwiftUI

// ActionButtons: gradient buttons, selection locking, "Seleccionado ✓" feedback
// Matches ActionButtons.tsx exactly.

struct ActionButtons: View {
    let data: [String: Any]
    let actions: [WidgetAction]
    let agentMessage: String?
    let selectedActionId: String?
    let themeVM: ThemeViewModel
    let onAction: (String) -> Void

    private var hasSelection: Bool { selectedActionId != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Optional title + description header
            if let title = data["title"] as? String {
                VStack(spacing: 6) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(themeVM.textColor)
                    if let desc = data["description"] as? String {
                        Text(desc)
                            .font(.system(size: 14))
                            .foregroundColor(themeVM.secondaryTextColor)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 8)
            }

            // Buttons (wrapped row)
            let rows = chunked(actions, by: 2)
            VStack(spacing: 12) {
                ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                    HStack(spacing: 12) {
                        ForEach(row) { action in
                            actionButton(action)
                        }
                    }
                }
            }
            .padding(16)

            // Agent message (left-border style)
            if let msg = agentMessage {
                HStack(alignment: .top, spacing: 0) {
                    Rectangle().fill(themeVM.primaryColor).frame(width: 3)
                    Text(msg)
                        .font(.system(size: 14))
                        .foregroundColor(themeVM.textColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(themeVM.inputBgColor)
                .cornerRadius(8)
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }

            // Selection feedback
            if hasSelection {
                Text("Seleccionado ✓")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "#10b981"))
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 12)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeVM.cardBgColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(hasSelection ? Color(hex: "#10b981") : themeVM.accentColor, lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func actionButton(_ action: WidgetAction) -> some View {
        let isSelected = selectedActionId == action.id
        let isDisabledBySelection = hasSelection && !isSelected
        let isSecondary = action.style == .secondary && !isSelected

        Button {
            if !hasSelection && action.disabled != true { onAction(action.id) }
        } label: {
            HStack(spacing: 8) {
                if isSelected {
                    Text("✓").font(.system(size: 16)).foregroundColor(.white)
                } else if let icon = action.icon {
                    Text(icon).font(.system(size: 16))
                        .foregroundColor(isSecondary ? themeVM.secondaryTextColor : .white)
                }
                Text(action.label)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isSecondary ? themeVM.textColor : .white)
            }
            .padding(.horizontal, 24).padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(gradient(for: action, isSelected: isSelected))
            .cornerRadius(12)
            .overlay(
                isSecondary
                    ? RoundedRectangle(cornerRadius: 12).stroke(themeVM.accentColor, lineWidth: 1)
                    : nil
            )
        }
        .opacity(isDisabledBySelection ? 0.4 : 1.0)
        .scaleEffect(isSelected ? 1.02 : (isDisabledBySelection ? 0.95 : 1.0))
        .animation(.easeInOut(duration: 0.15), value: selectedActionId)
        .disabled(action.disabled == true || (hasSelection && !isSelected))
    }

    private func gradient(for action: WidgetAction, isSelected: Bool) -> LinearGradient {
        let colors: [Color]
        if isSelected {
            colors = [Color(hex: "#10b981"), Color(hex: "#059669")]
        } else {
            switch action.style {
            case .success:  colors = [Color(hex: "#10b981"), Color(hex: "#059669")]
            case .danger:   colors = [Color(hex: "#ef4444"), Color(hex: "#dc2626")]
            case .secondary: colors = [themeVM.accentColor, themeVM.accentColor]
            default:        colors = [themeVM.primaryColor, themeVM.primaryColor.opacity(0.8)]
            }
        }
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private func chunked(_ arr: [WidgetAction], by size: Int) -> [[WidgetAction]] {
        stride(from: 0, to: arr.count, by: size).map { Array(arr[$0..<min($0+size, arr.count)]) }
    }
}
