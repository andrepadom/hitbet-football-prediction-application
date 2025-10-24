//
//  HitBetAppApp.swift
//  HitBetApp
//
//  Main application entry point for HitBet Football Prediction iOS App
//

import SwiftUI

@main
struct HitBetAppApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}

// App-wide state management
class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var apiBaseURL: String = "http://localhost:5000/api/v1"
    
    // You can configure this in production
    func setAPIBaseURL(_ url: String) {
        apiBaseURL = url
    }
}
