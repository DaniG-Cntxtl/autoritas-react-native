# Widget API Reference

To display rich UI components in the mobile application, the backend agent must send JSON payloads via the LiveKit data channel with the `type: "widget"` property.

## 1. Device Grid (Phones)
Shows a list of devices with pricing and selection logic.

**Widget Name:** `device_grid`

**Schema:**
```json
{
  "type": "widget",
  "widget": "device_grid",
  "data": {
    "title": "string (optional)",
    "devices": [
      {
        "name": "string (required)",
        "brand": "string (required)",
        "full_price": "number",
        "monthly": "number",
        "price_with_plan": "number",
        "image_url": "string (optional)",
        "in_stock": "boolean",
        "storage": "string",
        "color": "string"
      }
    ]
  },
  "actions": [
    {
      "id": "string",
      "label": "string",
      "style": "primary | secondary"
    }
  ],
  "agentMessage": "string (optional text to display below widget)"
}
```

## 2. Plan Card (Tariffs)
Shows a single mobile or data plan.

**Widget Name:** `plan_card`

**Schema:**
```json
{
  "type": "widget",
  "widget": "plan_card",
  "data": {
    "name": "string",
    "price": "number",
    "period": "string (e.g., '/mes')",
    "features": ["string"],
    "data_gb": "number",
    "calls_minutes": "string | number",
    "sms": "string | number",
    "badge": "string (optional)",
    "highlighted": "boolean"
  },
  "actions": [
    {
      "id": "string",
      "label": "string",
      "style": "primary | secondary | success | danger | link"
    }
  ]
}
```

## 3. Invoice Summary (Bill)
Shows a billing summary with line items.

**Widget Name:** `invoice_summary`

**Schema:**
```json
{
  "type": "widget",
  "widget": "invoice_summary",
  "data": {
    "invoice_id": "string",
    "period": "string",
    "total": "number",
    "status": "paid | pending | overdue",
    "due_date": "string (YYYY-MM-DD)",
    "line_items": [
      {
        "description": "string",
        "amount": "number"
      }
    ]
  },
  "actions": [
    {
      "id": "string",
      "label": "string",
      "style": "primary | secondary"
    }
  ]
}
```

## 4. Action Buttons
Generic list of buttons for quick replies or navigation.

**Widget Name:** `action_buttons`

**Schema:**
```json
{
  "type": "widget",
  "widget": "action_buttons",
  "data": {
    "title": "string (optional)"
  },
  "actions": [
    {
      "id": "string",
      "label": "string",
      "style": "primary | secondary",
      "icon": "string (optional)"
    }
  ],
  "agentMessage": "string (optional)"
}
```
