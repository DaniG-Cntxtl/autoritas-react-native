import SwiftUI

struct DeviceGrid: View {
    let data: [String: Any]
    let actions: [WidgetAction]
    let agentMessage: String?
    let selectedActionId: String?
    let themeVM: ThemeViewModel
    let onAction: (String) -> Void

    private var devices: [DeviceItem] {
        guard let raw = data["devices"] as? [[String: Any]],
              let jsonData = try? JSONSerialization.data(withJSONObject: raw),
              let items = try? JSONDecoder().decode([DeviceItem].self, from: jsonData)
        else { return [] }
        return items
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
                ForEach(devices, id: \.stableId) { device in
                    deviceCell(device)
                }
            }
            .padding(.horizontal, 16)

            if !actions.isEmpty {
                WidgetActionButtons(actions: actions, selectedActionId: selectedActionId,
                                    themeVM: themeVM, onAction: onAction)
                    .padding(.bottom, 8)
            }
        }
        .widgetCard(themeVM: themeVM)
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func deviceCell(_ device: DeviceItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: deviceIcon(device.name))
                    .font(.system(size: 22))
                    .foregroundColor(themeVM.primaryColor)
                Spacer()
                Circle()
                    .fill(device.inStock == true ? Color(hex: "#22c55e") : Color.gray)
                    .frame(width: 8, height: 8)
            }

            Text(device.name)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(themeVM.textColor)
                .lineLimit(2)

            if let brand = device.brand {
                Text(brand)
                    .font(.caption)
                    .foregroundColor(themeVM.secondaryTextColor)
            }

            if let monthly = device.monthly {
                Text(String(format: "%.2f€/mes", monthly))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(themeVM.primaryColor)
            } else if let full = device.fullPrice {
                Text(String(format: "%.2f€", full))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(themeVM.primaryColor)
            }

            if let storage = device.storage {
                Text(storage)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(themeVM.secondaryTextColor)
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(themeVM.accentColor)
                    .cornerRadius(4)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(themeVM.inputBgColor)
        .cornerRadius(CGFloat(themeVM.borderRadius + 4))
        .overlay(RoundedRectangle(cornerRadius: CGFloat(themeVM.borderRadius + 4))
            .stroke(themeVM.accentColor, lineWidth: 1))
    }

    private func deviceIcon(_ name: String) -> String {
        let n = name.lowercased()
        if n.contains("iphone") || n.contains("samsung") || n.contains("pixel") { return "iphone" }
        if n.contains("ipad") || n.contains("tablet") { return "ipad" }
        if n.contains("mac") || n.contains("laptop") { return "laptopcomputer" }
        if n.contains("watch") { return "applewatch" }
        return "iphone"
    }
}
