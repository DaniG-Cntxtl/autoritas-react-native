import SwiftUI

struct PlanGrid: View {
    let data: [String: Any]
    let actions: [WidgetAction]
    let agentMessage: String?
    let selectedActionId: String?
    let themeVM: ThemeViewModel
    let onAction: (String) -> Void

    private var plans: [PlanData] {
        let rawPlans = data["plans"] as? [[String: Any]] ?? []
        return rawPlans.compactMap { dict in
            guard let jsonData = try? JSONSerialization.data(withJSONObject: dict),
                  let p = try? JSONDecoder().decode(PlanData.self, from: jsonData) else { return nil }
            return p
        }
    }

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title = data["title"] as? String {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(themeVM.textColor)
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
            }
            if let msg = agentMessage {
                WidgetAgentMessage(text: msg, themeVM: themeVM)
            }

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(plans, id: \.stableId) { plan in
                    planCell(plan)
                }
            }
            .padding(.horizontal, 16)

            WidgetActionButtons(actions: actions, selectedActionId: selectedActionId,
                                themeVM: themeVM, onAction: onAction)
                .padding(.bottom, 8)
        }
        .widgetCard(themeVM: themeVM)
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func planCell(_ plan: PlanData) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if plan.highlighted == true {
                Text(plan.badge ?? "Recomendado")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(themeVM.primaryColor)
                    .cornerRadius(4)
            }

            Text(plan.name)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(themeVM.textColor)
                .lineLimit(2)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("€\(Int(plan.price))")
                    .font(.system(size: 22, weight: .black))
                    .foregroundColor(themeVM.primaryColor)
                Text(plan.period ?? "/mes")
                    .font(.caption)
                    .foregroundColor(themeVM.secondaryTextColor)
            }

            if let gb = plan.dataGb {
                Label("\(gb) GB", systemImage: "antenna.radiowaves.left.and.right")
                    .font(.caption)
                    .foregroundColor(themeVM.secondaryTextColor)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(plan.highlighted == true
            ? themeVM.primaryColor.opacity(0.08)
            : themeVM.inputBgColor)
        .cornerRadius(CGFloat(themeVM.borderRadius + 4))
        .overlay(
            RoundedRectangle(cornerRadius: CGFloat(themeVM.borderRadius + 4))
                .stroke(plan.highlighted == true ? themeVM.primaryColor : themeVM.accentColor, lineWidth: 1)
        )
    }
}
