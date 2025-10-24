//
//  DashboardView.swift
//  HitBetApp
//
//  Dashboard view showing overview statistics
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.isLoading {
                        ProgressView("Loading dashboard...")
                            .padding()
                    } else if let error = viewModel.errorMessage {
                        ErrorView(message: error) {
                            Task {
                                await viewModel.loadDashboard()
                            }
                        }
                    } else if let dashboard = viewModel.dashboardData {
                        StatsGridView(stats: dashboard.stats)
                        
                        if !dashboard.recentLeagues.isEmpty {
                            RecentLeaguesSection(leagues: dashboard.recentLeagues)
                        }
                        
                        if !dashboard.recentModels.isEmpty {
                            RecentModelsSection(models: dashboard.recentModels)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("HitBet Dashboard")
            .refreshable {
                await viewModel.loadDashboard()
            }
        }
        .task {
            await viewModel.loadDashboard()
        }
    }
}

// MARK: - Stats Grid

struct StatsGridView: View {
    let stats: DashboardStats
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            StatCard(
                title: "Available Leagues",
                value: "\(stats.totalLeaguesAvailable)",
                icon: "sportscourt.fill",
                color: .blue
            )
            
            StatCard(
                title: "Saved Leagues",
                value: "\(stats.savedLeaguesCount)",
                icon: "folder.fill",
                color: .green
            )
            
            StatCard(
                title: "Trained Models",
                value: "\(stats.savedModelsCount)",
                icon: "brain.head.profile",
                color: .purple
            )
            
            StatCard(
                title: "Countries",
                value: "\(stats.countriesAvailable)",
                icon: "globe",
                color: .orange
            )
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Recent Sections

struct RecentLeaguesSection: View {
    let leagues: [League]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Leagues")
                .font(.headline)
            
            ForEach(leagues) { league in
                LeagueRowView(league: league)
            }
        }
    }
}

struct RecentModelsSection: View {
    let models: [MLModel]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Models")
                .font(.headline)
            
            ForEach(models) { model in
                ModelRowView(model: model)
            }
        }
    }
}

struct LeagueRowView: View {
    let league: League
    
    var body: some View {
        HStack {
            Image(systemName: "sportscourt.fill")
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text(league.name)
                    .font(.subheadline)
                if let country = league.country {
                    Text(country)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct ModelRowView: View {
    let model: MLModel
    
    var body: some View {
        HStack {
            Image(systemName: "brain.head.profile")
                .foregroundColor(.purple)
            
            VStack(alignment: .leading) {
                Text(model.name)
                    .font(.subheadline)
                if let accuracy = model.accuracy {
                    Text(String(format: "Accuracy: %.1f%%", accuracy * 100))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Error View

struct ErrorView: View {
    let message: String
    let retry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("Error")
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: retry) {
                Label("Retry", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
