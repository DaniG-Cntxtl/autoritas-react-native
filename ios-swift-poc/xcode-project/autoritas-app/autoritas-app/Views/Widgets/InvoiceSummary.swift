import SwiftUI

struct InvoiceSummary: View {
    let message: Message
    let onAction: (String) -> Void
    
    var body: some View {
        if let widgetData = message.widgetData, let data = widgetData.invoice {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Invoice Summary")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(data.date)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    Spacer()
                    Text(data.status.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(data.status == "paid" ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                        .foregroundColor(data.status == "paid" ? .green : .orange)
                        .cornerRadius(4)
                }
                
                Divider().background(Color.white.opacity(0.1))
                
                // Items
                if let items = data.items {
                    VStack(spacing: 12) {
                        ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                            HStack {
                                Text(item.label)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                Spacer()
                                Text(item.value)
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                
                Divider().background(Color.white.opacity(0.1))
                
                // Total
                HStack {
                    Text("Total Amount")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Text("€\(String(format: "%.2f", data.amount))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.indigo)
                }
                
                // Actions
                if let actions = message.actions {
                    HStack(spacing: 12) {
                        ForEach(actions) { action in
                            Button(action: {
                                onAction(action.id)
                            }) {
                                Text(action.label)
                                    .font(.system(size: 14, weight: .semibold))
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity)
                                    .background(action.style == .primary ? Color.indigo : Color.white.opacity(0.1))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
}
