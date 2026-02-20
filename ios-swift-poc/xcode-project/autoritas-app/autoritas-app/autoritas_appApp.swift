//
//  autoritas_appApp.swift
//  autoritas-app
//
//  Created by Daniel Gomez on 18/2/26.
//

import SwiftUI
// import AVFoundation // Not needed if relying on LiveKit

@main
struct autoritas_appApp: App {
    init() {
        print("DEBUG: iOSApp init")
        // LiveKit SDK handles AudioSession automatically.
        // Manual configuration often conflicts and causes error 801.
    }
    
    var body: some Scene {
        WindowGroup {
            let _ = print("DEBUG: WindowGroup body")
            ContentView()
        }
    }
}
