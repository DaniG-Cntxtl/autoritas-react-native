import Foundation

// MARK: - Auth

struct LiveKitAuthResponse: Codable {
    let token: String
    let url: String
}

// MARK: - Agent State

enum AgentState: String {
    case disconnected
    case connecting
    case listening
    case thinking
    case speaking
}

// MARK: - Message

enum MessageRole: String, Codable {
    case user
    case agent
}

// All widget type keys (matches backend JSON "widget" field)
enum WidgetType: String, Codable {
    case actionButtons    = "action_buttons"
    case deviceGrid       = "device_grid"
    case planCard         = "plan_card"
    case planGrid         = "plan_grid"
    case invoiceSummary   = "invoice_summary"
    case routerDiagnostics = "router_diagnostics"
    case documentPreview  = "document_preview"
    case telemetryDashboard = "telemetry_dashboard"
    case welcomeMenu      = "welcome_menu"
}

/// Unified message model used in the chat list
struct Message: Identifiable, Equatable {
    let id: String
    let role: MessageRole
    var text: String?
    // Widget-specific
    let widgetType: WidgetType?
    var rawData: [String: Any]?   // raw JSON dict for flexible widget rendering
    var actions: [WidgetAction]?
    var selectedActionId: String?
    let timestamp: Date
    var isFinal: Bool = true

    var isWidget: Bool { widgetType != nil }

    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id &&
        lhs.isFinal == rhs.isFinal &&
        lhs.selectedActionId == rhs.selectedActionId &&
        lhs.text == rhs.text
    }
}

// MARK: - Widget Shared Types

struct WidgetAction: Identifiable, Codable {
    let id: String
    let label: String
    let style: ActionStyle?
    let icon: String?
    let disabled: Bool?

    enum ActionStyle: String, Codable {
        case primary, secondary, success, danger, link
    }
}

// MARK: - Widget Data Models

/// Phones / devices list
struct DeviceItem: Codable, Identifiable {
    let id: String?
    let name: String
    let brand: String?
    let fullPrice: Double?
    let monthly: Double?
    let priceWithPlan: Double?
    let imageUrl: String?
    let inStock: Bool?
    let storage: String?
    let color: String?

    enum CodingKeys: String, CodingKey {
        case id, name, brand, storage, color
        case fullPrice     = "full_price"
        case monthly
        case priceWithPlan = "price_with_plan"
        case imageUrl      = "image_url"
        case inStock       = "in_stock"
    }
    // Provide a stable id even if the backend omits it
    var stableId: String { id ?? name }
}

struct DeviceGridData: Codable {
    let title: String?
    let devices: [DeviceItem]
}

/// Single plan / tariff
struct PlanData: Codable, Identifiable {
    let id: String?
    let name: String
    let price: Double
    let period: String?
    let features: [String]?
    let dataGb: Int?
    let callsMinutes: AnyCodable?   // "Ilimitados" or a number
    let sms: AnyCodable?
    let badge: String?
    let highlighted: Bool?

    enum CodingKeys: String, CodingKey {
        case id, name, price, period, features, badge, highlighted, sms
        case dataGb       = "data_gb"
        case callsMinutes = "calls_minutes"
    }
    var stableId: String { id ?? name }
}

struct PlanGridData: Codable {
    let title: String?
    let plans: [PlanData]
}

/// Invoice / billing summary
struct InvoiceLineItem: Codable {
    let description: String
    let amount: Double
}

struct InvoiceData: Codable {
    let invoiceId: String?
    let period: String?
    let total: Double
    let status: String?        // "paid" | "pending" | "overdue"
    let dueDate: String?
    let lineItems: [InvoiceLineItem]?

    enum CodingKeys: String, CodingKey {
        case total, status, period
        case invoiceId  = "invoice_id"
        case dueDate    = "due_date"
        case lineItems  = "line_items"
    }
}

/// Router diagnostics metric
struct DiagnosticMetric: Codable, Identifiable {
    let id: String?
    let label: String
    let value: String
    let status: String?     // "ok" | "warning" | "critical"
    var stableId: String { id ?? label }
}

struct RouterDiagnosticsData: Codable {
    let title: String?
    let metrics: [DiagnosticMetric]
}

/// Document preview
struct DocumentData: Codable {
    let title: String
    let fileType: String?       // "pdf" | "docx" | etc.
    let thumbnailUrl: String?
    let downloadUrl: String?
    let sizeLabel: String?

    enum CodingKeys: String, CodingKey {
        case title
        case fileType    = "file_type"
        case thumbnailUrl = "thumbnail_url"
        case downloadUrl = "download_url"
        case sizeLabel   = "size_label"
    }
}

/// Telemetry metric row
struct TelemetryMetric: Codable, Identifiable {
    let id: String?
    let label: String
    let value: String
    let unit: String?
    let status: String?         // "active" | "warning" | "critical"
    let chartValue: Double?     // 0-1, used to draw a thin bar
    var stableId: String { id ?? label }

    enum CodingKeys: String, CodingKey {
        case id, label, value, unit, status
        case chartValue = "chart_value"
    }
}

struct TelemetryData: Codable {
    let title: String?
    let metrics: [TelemetryMetric]
}

/// Welcome menu category button
struct WelcomeCategory: Codable, Identifiable {
    let id: String
    let label: String
    let icon: String?
}

struct WelcomeMenuData: Codable {
    let greeting: String?
    let categories: [WelcomeCategory]
}

/// Action-buttons widget (generic list of CTA buttons + optional title)
struct ActionButtonsData: Codable {
    let title: String?
}

// MARK: - Theme Engine

struct ThemeMeta: Codable {
    let name: String
    let generatedAt: Double?

    enum CodingKeys: String, CodingKey {
        case name
        case generatedAt = "generated_at"
    }
}

struct ThemeColors: Codable {
    let primary: String
    let background: String
    let text: String
    let secondaryText: String
    let accent: String
    let cardBackground: String
    let inputBackground: String
    let messageBubbleUser: String
    let messageBubbleAgent: String
}

struct ThemeLayout: Codable {
    let borderRadius: Double
    let borderWidth: Double
    let spacingUnit: Double
    let chatPosition: String?
    let widgetPosition: String?
}

struct ThemeTypography: Codable {
    let headingFontName: String?
    let headingFontUrl: String?
    let bodyFontName: String?
    let bodyFontUrl: String?
}

struct ThemeStyles: Codable {
    let colors: ThemeColors
    let layout: ThemeLayout
    let typography: ThemeTypography?
}

struct GeneratedTheme: Codable {
    let meta: ThemeMeta
    let styles: ThemeStyles
}

// MARK: - AnyCodable helper (for flexible number/string fields)

struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) { self.value = value }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let int = try? container.decode(Int.self)         { value = int; return }
        if let double = try? container.decode(Double.self)   { value = double; return }
        if let str = try? container.decode(String.self)      { value = str; return }
        if let bool = try? container.decode(Bool.self)       { value = bool; return }
        value = ""
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let i as Int:    try container.encode(i)
        case let d as Double: try container.encode(d)
        case let s as String: try container.encode(s)
        case let b as Bool:   try container.encode(b)
        default:              try container.encodeNil()
        }
    }

    var stringValue: String {
        switch value {
        case let s as String: return s
        case let i as Int:    return "\(i)"
        case let d as Double: return d.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(d))" : "\(d)"
        default:              return "\(value)"
        }
    }
}
