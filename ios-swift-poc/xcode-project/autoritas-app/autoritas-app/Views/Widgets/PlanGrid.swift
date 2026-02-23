import SwiftUI

// PlanGrid: horizontally scrollable plan cards with tap-to-select + confirm flow.
// First tap selects (green highlight), second tap or confirm button sends the action.
// Matches PlanGrid.tsx exactly.

struct PlanGrid: View {
    let data: [String: Any]
    let actions: [WidgetAction]
    let agentMessage: String?
    let selectedActionId: String?
    let themeVM: ThemeViewModel
    let onAction: (String) -> Void

    @State private var selectedPlanId: String?

    private var plans: [PlanData] {
        (data["plans"] as? [[String: Any]] ?? []).compactMap { dict in
            guard let jsonData = try? JSONSerialization.data(withJSONObject: dict),
                  let p = try? JSONDecoder().decode(PlanData.self, from: jsonData) else { return nil }
            return p
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let title = data["title"] as? String {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(themeVM.textColor)
                    .padding(.horizontal, 16).padding(.top, 14).padding(.bottom, 12)
            }

            // Horizontal scrollable plan cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(plans, id: \.stableId) { plan in
                        planCard(plan).frame(width: 260)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }

            // Confirm button (appears when a plan is selected)
            if let selId = selectedPlanId, let plan = plans.first(where: { $0.stableId == selId }) {
                Button { onAction(plan.stableId) } label: {
                    Text("Confirmar \(plan.name)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(LinearGradient(colors: [Color(hex: "#10b981"), Color(hex: "#059669")],
                                                   startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
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
                .padding(.horizontal, 16).padding(.bottom, 12)
            }
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func planCard(_ plan: PlanData) -> some View {
        let isSelected = selectedPlanId == plan.stableId

        Button {
            if selectedPlanId == plan.stableId {
                onAction(plan.stableId)  // Second tap → confirm
            } else {
                selectedPlanId = plan.stableId
            }
        } label: {
            ZStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text(plan.name)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(themeVM.textColor)
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("€\(Int(plan.price))")
                                .font(.system(size: 32, weight: .black))
                                .foregroundColor(themeVM.textColor)
                            Text(plan.period ?? "/mes")
                                .font(.system(size: 14))
                                .foregroundColor(themeVM.secondaryTextColor)
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                    // Data GB highlight
                    if let gb = plan.dataGb {
                        VStack(spacing: 2) {
                            Text("\(gb)GB")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(themeVM.primaryColor)
                            Text("DATOS")
                                .font(.system(size: 10)).foregroundColor(themeVM.secondaryTextColor)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(themeVM.inputBgColor)
                        .cornerRadius(8)
                        .padding(.bottom, 12)
                    }

                    // Features (max 3 + "+N more...")
                    if let features = plan.features {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(features.prefix(3), id: \.self) { f in
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(isSelected ? Color(hex: "#10b981") : themeVM.primaryColor)
                                    Text(f)
                                        .font(.system(size: 13))
                                        .foregroundColor(themeVM.textColor.opacity(0.9))
                                        .lineLimit(2)
                                }
                            }
                            if features.count > 3 {
                                Text("+\(features.count - 3) more...")
                                    .font(.system(size: 12).italic())
                                    .foregroundColor(themeVM.secondaryTextColor)
                            }
                        }
                    }

                    Spacer()
                }
                .padding(20)

                // Selection top border
                if isSelected {
                    LinearGradient(colors: [Color(hex: "#10b981"), Color(hex: "#34d399")],
                                   startPoint: .leading, endPoint: .trailing)
                    .frame(height: 4)
                } else if plan.highlighted == true {
                    LinearGradient(colors: [themeVM.primaryColor, themeVM.primaryColor.opacity(0.5)],
                                   startPoint: .leading, endPoint: .trailing)
                    .frame(height: 4)
                }

                // Badge
                if let badge = plan.badge {
                    HStack {
                        Spacer()
                        Text(isSelected ? "Selected" : badge)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 10).padding(.vertical, 4)
                            .background(
                                LinearGradient(
                                    colors: isSelected ? [Color(hex: "#10b981"), Color(hex: "#34d399")]
                                                       : [Color(hex: "#f59e0b"), Color(hex: "#d97706")],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                    }
                    .padding(.top, 12).padding(.trailing, 12)
                }

                // Selected checkmark (bottom-right)
                if isSelected {
                    VStack { Spacer(); HStack { Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color(hex: "#10b981"))
                            .padding(16)
                    }}
                }
            }
            .frame(minHeight: 280)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected
                          ? (themeVM.isDark ? Color(hex: "#1a3a2a") : Color(hex: "#ecfdf5"))
                          : themeVM.cardBgColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color(hex: "#10b981")
                            : (plan.highlighted == true ? themeVM.primaryColor : themeVM.accentColor),
                            lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
        }
        .buttonStyle(.plain)
    }
}
