import SwiftUI

struct DeviceGrid: View {
    let message: Message
    let onAction: (String) -> Void
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let agentMessage = message.widgetData?.agentMessage {
                Text(agentMessage)
                    .font(.body)
                    .foregroundColor(.white)
                    .padding(.horizontal)
            }
            
            LazyVGrid(columns: columns, spacing: 12) {
                if let devices = message.widgetData?.devices {
                    ForEach(devices) { device in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: deviceTypeIcon(device.type))
                                    .font(.title2)
                                    .foregroundColor(.indigo)
                                Spacer()
                                Circle()
                                    .fill(device.status == "active" ? Color.green : Color.gray)
                                    .frame(width: 8, height: 8)
                            }
                            
                            Text(device.name)
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            if let value = device.value {
                                Text(value)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            
                            Text(device.status.uppercased())
                                .font(.system(size: 10, weight: .bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.indigo.opacity(0.2))
                                .foregroundColor(.indigo)
                                .cornerRadius(4)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.horizontal)
            
            if let actions = message.actions {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(actions) { action in
                            Button(action: {
                                onAction(action.id)
                            }) {
                                Text(action.label)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(message.selectedActionId == action.id ? .white : .indigo)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(
                                        message.selectedActionId == action.id 
                                            ? Color.indigo 
                                            : Color.indigo.opacity(0.1)
                                    )
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    func deviceTypeIcon(_ type: String) -> String {
        switch type.lowercased() {
        case "mobile", "phone": return "iphone"
        case "tablet": return "ipad"
        case "laptop", "computer": return "laptopcomputer"
        case "watch": return "applewatch"
        default: return "cpu"
        }
    }
}
