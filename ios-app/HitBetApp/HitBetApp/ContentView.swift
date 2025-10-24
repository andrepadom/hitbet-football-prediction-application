//
//  ContentView.swift
//  HitBetApp
//
//  Main navigation view for the HitBet app
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
                .tag(0)
            
            LeaguesView()
                .tabItem {
                    Label("Leagues", systemImage: "sportscourt.fill")
                }
                .tag(1)
            
            ModelsView()
                .tabItem {
                    Label("Models", systemImage: "brain.head.profile")
                }
                .tag(2)
            
            PredictionsView()
                .tabItem {
                    Label("Predictions", systemImage: "wand.and.stars")
                }
                .tag(3)
            
            AnalysisView()
                .tabItem {
                    Label("Analysis", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(4)
        }
        .accentColor(.blue)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
    }
}
