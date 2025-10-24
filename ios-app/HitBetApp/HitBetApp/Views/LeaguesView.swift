//
//  LeaguesView.swift
//  HitBetApp
//
//  View for managing football leagues
//

import SwiftUI

struct LeaguesView: View {
    @StateObject private var viewModel = LeaguesViewModel()
    @State private var showingDownloadSheet = false
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.isLoading {
                    ProgressView("Loading leagues...")
                } else if let error = viewModel.errorMessage {
                    ErrorView(message: error) {
                        Task { await viewModel.loadLeagues() }
                    }
                } else {
                    Section(header: Text("Saved Leagues")) {
                        ForEach(viewModel.savedLeagues) { league in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(league.name)
                                        .font(.headline)
                                    if let country = league.country {
                                        Text(country)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    Task {
                                        await viewModel.deleteLeague(name: league.name)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("Available Leagues")) {
                        ForEach(viewModel.availableLeagues) { league in
                            Button {
                                Task {
                                    await viewModel.downloadLeague(name: league.name)
                                }
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(league.name)
                                            .font(.headline)
                                        Text(league.country)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "arrow.down.circle")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Leagues")
            .refreshable {
                await viewModel.loadLeagues()
            }
        }
        .task {
            await viewModel.loadLeagues()
        }
    }
}

@MainActor
class LeaguesViewModel: ObservableObject {
    @Published var savedLeagues: [League] = []
    @Published var availableLeagues: [AvailableLeague] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    
    func loadLeagues() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let data = try await apiService.getLeagues()
            savedLeagues = data.saved
            availableLeagues = data.available
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func downloadLeague(name: String) async {
        do {
            _ = try await apiService.downloadLeague(name: name)
            await loadLeagues()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteLeague(name: String) async {
        do {
            try await apiService.deleteLeague(name: name)
            await loadLeagues()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct LeaguesView_Previews: PreviewProvider {
    static var previews: some View {
        LeaguesView()
    }
}
