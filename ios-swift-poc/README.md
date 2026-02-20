# iOS Swift PoC

This is a native iOS implementation of the AI Telco Assistant Chat application, refactored from the original React Native version.

## Architecture

- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Architecture**: MVVM (Model-View-ViewModel)
- **Dependencies**: 
  - `LiveKit Client SDK for Swift` (via Swift Package Manager)

## Project Structure

- `iOSApp/App.swift`: Main entry point.
- `iOSApp/Models/`: Data models for Chat, User, and Widgets.
- `iOSApp/Services/`: 
  - `AuthService.swift`: Fetches LiveKit tokens from the backend.
  - `LiveKitManager.swift`: Manages LiveKit room connection and data channel.
- `iOSApp/ViewModels/`:
  - `ChatViewModel.swift`: Orchestrates chat logic and state.
- `iOSApp/Views/`:
  - `LoginView.swift`: Authentication screen.
  - `ChatView.swift`: Main chat interface.
  - `Widgets/`: Native implementations of ActionButtons, DeviceGrid, PlanCard, InvoiceSummary.

## How to Run

1. Open Xcode.
2. Select `File > New > Project` if you want a full Xcode project wrapper, or open this folder if using Swift Playgrounds App / SPM-based workflow.
3. Ensure `LiveKit` dependency is resolved (SPM).
4. Run on Simulator or Device.
5. Ensure your backend (token server) is running on `localhost:8080`.

## Notes on LiveKit

The `LiveKitManager.swift` contains the logic to connect to a LiveKit room. Ensure the backend provides a valid token and URL.
This implementation focuses on Data Channel (Text/JSON) communication for the chat agent.
