import Foundation

struct User: Identifiable {
    let id: String
    let name: String
    let isCurrentUser: Bool
}

struct LiveKitAuthResponse: Codable {
    let token: String
    let url: String
}

enum MessageType: String, Codable {
    case text
    case widget
}

enum WidgetType: String, Codable {
    case actionButtons = "action_buttons"
    case deviceGrid = "device_grid"
    case planCard = "plan_card"
    case invoiceSummary = "invoice_summary"
}

// MARK: - Widget Data Structures

struct Action: Identifiable, Codable {
    let id: String
    let label: String
    let style: ActionStyle?
    let icon: String?
    let disabled: Bool?
    
    enum ActionStyle: String, Codable {
        case primary
        case secondary
        case success
        case danger
        case link
    }
}

struct PlanData: Codable {
    let name: String
    let price: Double
    let period: String?
    let features: [String]
    let dataGb: Int?
    let callsMinutes: String? // Can be "Ilimitados" or a number
    let sms: String?
    let badge: String?
    let highlighted: Bool?
    
    enum CodingKeys: String, CodingKey {
        case name, price, period, features, badge, highlighted, sms
        case dataGb = "data_gb"
        case callsMinutes = "calls_minutes"
    }
}

struct DeviceData: Codable, Identifiable {
    let id: String
    let name: String
    let status: String
    let type: String
    let value: String?
}

struct InvoiceData: Codable {
    let id: String
    let amount: Double
    let date: String
    let status: String
    let items: [InvoiceItem]?
    
    struct InvoiceItem: Codable {
        let label: String
        let value: String
    }
}

// MARK: - Unified Widget Data Container
struct WidgetData: Codable {
    // Shared or specific fields
    var title: String?
    var agentMessage: String?
    
    // Type-specific data containers
    var plan: PlanData?
    var devices: [DeviceData]?
    var invoice: InvoiceData?
    var genericItems: [String]? // For action buttons or simple lists
    
    // Note: In the POC, the API might send the raw JSON which we map here.
    // If the API structure is different, we can use a custom decoder.
}

// MARK: - Message Model

struct Message: Identifiable, Equatable {
    let id: String
    let role: MessageRole
    let type: MessageType
    
    // Text specific
    var text: String?
    
    // Widget specific
    let widgetType: WidgetType?
    let widgetData: WidgetData?
    var actions: [Action]?
    var selectedActionId: String?
    
    let timestamp: Date
    var isFinal: Bool = true
    
    enum MessageRole: String, Codable {
        case user
        case agent
    }
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id && 
               lhs.isFinal == rhs.isFinal && 
               lhs.selectedActionId == rhs.selectedActionId &&
               lhs.text == rhs.text
    }
}

// MARK: - Agent State
enum AgentState: String {
    case disconnected
    case connecting
    case listening
    case thinking
    case speaking
}
