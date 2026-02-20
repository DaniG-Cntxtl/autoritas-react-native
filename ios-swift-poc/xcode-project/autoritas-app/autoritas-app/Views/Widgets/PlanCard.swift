import SwiftUI

struct PlanCard: View {
    let message: Message
    let onAction: (String) -> Void
    
    var body: some View {
        if let widgetData = message.widgetData, let data = widgetData.plan {
            ZStack(alignment: .top) {
                // Background with Gradient and Border
                LinearGradient(
                    colors: [Color(red: 0.12, green: 0.12, blue: 0.25), Color(red: 0.09, green: 0.09, blue: 0.17)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(data.highlighted == true ? Color.indigo : Color.indigo.opacity(0.2), lineWidth: 1)
                )
                
                // Highlight Top Border
                if data.highlighted == true {
                    LinearGradient(
                        colors: [.indigo, .purple, .blue.opacity(0.5)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(height: 3)
                    .clipShape(
                        UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20)
                    )
                }
                
                VStack(spacing: 24) {
                    // Badge
                    if let badge = data.badge {
                        HStack {
                            Spacer()
                            Text(badge)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(
                                    LinearGradient(colors: [.orange, .yellow], startPoint: .leading, endPoint: .trailing)
                                )
                                .foregroundColor(.black)
                                .cornerRadius(20)
                        }
                    }
                    
                    // Header
                    VStack(spacing: 8) {
                        Text(data.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("€\(Int(data.price))")
                                .font(.system(size: 40, weight: .black))
                                .foregroundColor(.white)
                            Text(data.period ?? "/mes")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    
                    // Highlights (GB, Minutes, SMS)
                    HStack(spacing: 24) {
                        if let gb = data.dataGb {
                            HighlightItem(value: "\(gb)GB", label: "Datos")
                        }
                        if let mins = data.callsMinutes {
                            HighlightItem(value: mins, label: "Minutos")
                        }
                        if let sms = data.sms {
                            HighlightItem(value: sms, label: "SMS")
                        }
                    }
                    .padding(16)
                    .background(Color.indigo.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Features List
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(data.features.enumerated()), id: \.offset) { _, feature in
                            HStack(alignment: .top, spacing: 12) {
                                Text("✓")
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                Text(feature)
                                    .font(.footnote)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Actions
                    if let actions = message.actions {
                        HStack(spacing: 12) {
                            ForEach(actions) { action in
                                Button(action: {
                                    onAction(action.id)
                                }) {
                                    Text(action.label)
                                        .font(.system(size: 15, weight: .semibold))
                                        .padding(.vertical, 14)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            Group {
                                                if action.style == .primary {
                                                    LinearGradient(colors: [.indigo, .purple], startPoint: .leading, endPoint: .trailing)
                                                } else {
                                                    Color.white.opacity(0.1)
                                                }
                                            }
                                        )
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(action.style == .secondary ? Color.white.opacity(0.2) : Color.clear, lineWidth: 1)
                                        )
                                }
                                .disabled(action.disabled == true)
                            }
                        }
                    }
                }
                .padding(24)
            }
            .padding(.vertical, 8)
        }
    }
}

struct HighlightItem: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.indigo)
            Text(label.uppercased())
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}
