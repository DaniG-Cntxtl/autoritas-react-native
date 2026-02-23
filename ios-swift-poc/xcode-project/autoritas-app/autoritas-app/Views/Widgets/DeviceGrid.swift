import SwiftUI

// DeviceGrid: 2-column grid of device cards with image, brand, name, specs,
// pricing breakdown (Total + Desde monthly), tap-to-select with green confirm.
// Matches DeviceGrid.tsx exactly.

struct DeviceGrid: View {
    let data: [String: Any]
    let actions: [WidgetAction]
    let agentMessage: String?
    let selectedActionId: String?
    let themeVM: ThemeViewModel
    let onAction: (String) -> Void

    @State private var selectedDeviceName: String?

    private var devices: [DeviceItem] {
        (data["devices"] as? [[String: Any]] ?? []).compactMap { dict in
            guard let jsonData = try? JSONSerialization.data(withJSONObject: dict),
                  let d = try? JSONDecoder().decode(DeviceItem.self, from: jsonData) else { return nil }
            return d
        }
    }

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let title = data["title"] as? String {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(themeVM.textColor)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16).padding(.bottom, 12)
            }

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(devices, id: \.stableId) { device in
                    deviceCard(device)
                }
            }
            .padding(.horizontal, 16)

            // Confirm button
            if let selName = selectedDeviceName, let dev = devices.first(where: { $0.name == selName }) {
                Button { onAction(dev.name) } label: {
                    Text("Confirmar \(dev.name)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 12)
                        .background(LinearGradient(colors: [Color(hex: "#10b981"), Color(hex: "#059669")],
                                                   startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 16).padding(.top, 16)
            }

            // Actions row
            if !actions.isEmpty {
                HStack(spacing: 10) {
                    ForEach(actions) { action in
                        Button { onAction(action.id) } label: {
                            Text(action.label)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(action.style == .primary ? .white : themeVM.textColor)
                                .padding(.vertical, 10).padding(.horizontal, 20)
                                .background(action.style == .primary
                                    ? AnyShapeStyle(themeVM.primaryColor)
                                    : AnyShapeStyle(themeVM.accentColor))
                                .cornerRadius(12)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 16).padding(.horizontal, 16)
            }

            // Agent message
            if let msg = agentMessage {
                HStack(alignment: .top, spacing: 0) {
                    Rectangle().fill(themeVM.primaryColor).frame(width: 3)
                    Text(msg).font(.system(size: 14)).foregroundColor(themeVM.textColor)
                        .padding(14).frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(themeVM.inputBgColor).cornerRadius(8)
                .padding(.horizontal, 16).padding(.top, 12)
            }

            Spacer().frame(height: 16)
        }
        .widgetCard(themeVM: themeVM)
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func deviceCard(_ device: DeviceItem) -> some View {
        let isSelected    = selectedDeviceName == device.name
        let isOutOfStock  = device.inStock == false
        let fullPrice     = device.fullPrice ?? 0
        let monthlyPrice  = device.monthly ?? device.priceWithPlan

        Button {
            guard !isOutOfStock else { return }
            if selectedDeviceName == device.name {
                onAction(device.name)  // Second tap → confirm
            } else {
                selectedDeviceName = device.name
            }
        } label: {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 0) {
                    // Device image
                    AsyncImage(url: deviceImageURL(device)) { image in
                        image.resizable().aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Image(systemName: "iphone")
                            .font(.system(size: 48))
                            .foregroundColor(themeVM.secondaryTextColor.opacity(0.5))
                    }
                    .frame(height: 110)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8).padding(.bottom, 8)

                    // Info
                    VStack(spacing: 4) {
                        if let brand = device.brand {
                            Text(brand.uppercased())
                                .font(.system(size: 10, weight: .semibold)).kerning(1)
                                .foregroundColor(themeVM.secondaryTextColor)
                        }
                        Text(device.name)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(themeVM.textColor)
                            .multilineTextAlignment(.center).lineLimit(2)

                        // Spec badges
                        if device.storage != nil || device.color != nil {
                            HStack(spacing: 4) {
                                if let s = device.storage { specBadge(s) }
                                if let c = device.color { specBadge(c) }
                            }.padding(.top, 4)
                        }

                        // Pricing
                        Divider().background(themeVM.accentColor).padding(.vertical, 6)

                        HStack {
                            Text("Total").font(.system(size: 11)).foregroundColor(themeVM.secondaryTextColor)
                            Spacer()
                            Text("\(Int(fullPrice))€").font(.system(size: 14, weight: .bold)).foregroundColor(themeVM.textColor)
                        }

                        if let mp = monthlyPrice {
                            HStack {
                                Text("Desde").font(.system(size: 11)).foregroundColor(Color(hex: "#059669"))
                                Spacer()
                                HStack(spacing: 0) {
                                    Text(String(format: "%.2f€", mp))
                                        .font(.system(size: 13, weight: .bold)).foregroundColor(Color(hex: "#10b981"))
                                    Text("/mes")
                                        .font(.system(size: 10)).foregroundColor(Color(hex: "#10b981").opacity(0.8))
                                }
                            }
                            .padding(6)
                            .background(themeVM.isDark ? Color(hex: "#10b981").opacity(0.1) : Color(hex: "#ecfdf5"))
                            .cornerRadius(8)
                        }

                        Text("24 meses sin intereses")
                            .font(.system(size: 9)).foregroundColor(themeVM.secondaryTextColor)
                            .padding(.top, 2)
                    }
                    .padding(.horizontal, 10).padding(.bottom, 12)
                }

                // Selected / Out of stock badges
                if isSelected {
                    Text("✓ Seleccionado")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color(hex: "#10b981")).cornerRadius(12)
                        .padding(.top, 10).padding(.trailing, 10)
                }
                if isOutOfStock {
                    Text("Sin stock")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color(hex: "#ef4444")).cornerRadius(4)
                        .padding(.top, 10).padding(.trailing, 10)
                }

                // Green selection top border
                if isSelected {
                    VStack { LinearGradient(colors: [Color(hex: "#10b981"), Color(hex: "#34d399")],
                                            startPoint: .leading, endPoint: .trailing)
                        .frame(height: 3); Spacer() }
                }
            }
            .frame(minHeight: 320)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(isSelected
                        ? (themeVM.isDark ? Color(hex: "#1a3a2a") : Color(hex: "#ecfdf5"))
                        : themeVM.cardBgColor)
            )
            .overlay(RoundedRectangle(cornerRadius: 18)
                .stroke(isSelected ? Color(hex: "#10b981") : themeVM.accentColor, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
            .opacity(isOutOfStock ? 0.5 : 1.0)
        }
        .buttonStyle(.plain)
    }

    private func specBadge(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10))
            .foregroundColor(themeVM.secondaryTextColor)
            .padding(.horizontal, 6).padding(.vertical, 3)
            .background(themeVM.inputBgColor)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(themeVM.accentColor, lineWidth: 1))
            .cornerRadius(10)
    }

    // Hardcoded device image URLs (matches deviceImages map in RN)
    private func deviceImageURL(_ device: DeviceItem) -> URL? {
        if let url = device.imageUrl, let u = URL(string: url) { return u }
        let map: [String: String] = [
            "iPhone 14": "https://store.storeimages.cdn-apple.com/4668/as-images.apple.com/is/iphone-14-finish-select-202209-6-1inch-blue?wid=400&hei=400&fmt=p-jpg",
            "iPhone 15 Pro": "https://store.storeimages.cdn-apple.com/4668/as-images.apple.com/is/iphone-15-pro-finish-select-202309-6-1inch-naturaltitanium?wid=400&hei=400&fmt=p-jpg",
            "iPhone 15": "https://store.storeimages.cdn-apple.com/4668/as-images.apple.com/is/iphone-15-finish-select-202309-6-1inch-pink?wid=400&hei=400&fmt=p-jpg",
            "Samsung Galaxy S24": "https://images.samsung.com/es/smartphones/galaxy-s24/images/galaxy-s24-highlights-design-back-702-mo.webp",
            "Samsung Galaxy A54": "https://images.samsung.com/is/image/samsung/p6pim/es/sm-a546blvceub/gallery/es-galaxy-a54-5g-sm-a546-sm-a546blvceub-535227270",
        ]
        let fallback = "https://via.placeholder.com/200x200?text=Phone"
        return URL(string: map[device.name] ?? fallback)
    }
}
