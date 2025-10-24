//
//  AnalysisView.swift
//  HitBetApp
//
//  View for analyzing leagues and models
//

import SwiftUI

struct AnalysisView: View {
    @StateObject private var viewModel = AnalysisViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Analysis Type", selection: $selectedTab) {
                    Text("League").tag(0)
                    Text("Model").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                if selectedTab == 0 {
                    LeagueAnalysisView(viewModel: viewModel)
                } else {
                    ModelAnalysisView(viewModel: viewModel)
                }
            }
            .navigationTitle("Analysis")
        }
    }
}

struct LeagueAnalysisView: View {
    @ObservedObject var viewModel: AnalysisViewModel
    @State private var selectedLeague = ""
    
    var body: some View {
        Form {
            Section("Select League") {
                Picker("League", selection: $selectedLeague) {
                    Text("Select a league").tag("")
                    ForEach(viewModel.leagues) { league in
                        Text(league.name).tag(league.name)
                    }
                }
                
                Button("Analyze") {
                    Task {
                        await viewModel.analyzeLeague(name: selectedLeague)
                    }
                }
                .disabled(selectedLeague.isEmpty)
            }
            
            if viewModel.isLoading {
                Section {
                    ProgressView("Analyzing...")
                }
            }
            
            if let error = viewModel.errorMessage {
                Section {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
            
            if let analysis = viewModel.leagueAnalysis {
                Section("Statistics") {
                    if let total = analysis.totalMatches {
                        LabeledContent("Total Matches", value: "\(total)")
                    }
                    if let homeWins = analysis.homeWins {
                        LabeledContent("Home Wins", value: "\(homeWins)")
                    }
                    if let draws = analysis.draws {
                        LabeledContent("Draws", value: "\(draws)")
                    }
                    if let awayWins = analysis.awayWins {
                        LabeledContent("Away Wins", value: "\(awayWins)")
                    }
                    if let avgGoals = analysis.avgGoalsPerMatch {
                        LabeledContent("Avg Goals/Match", value: String(format: "%.2f", avgGoals))
                    }
                }
            }
        }
        .task {
            await viewModel.loadLeagues()
        }
    }
}

struct ModelAnalysisView: View {
    @ObservedObject var viewModel: AnalysisViewModel
    @State private var selectedModel = ""
    
    var body: some View {
        Form {
            Section("Select Model") {
                Picker("Model", selection: $selectedModel) {
                    Text("Select a model").tag("")
                    ForEach(viewModel.models) { model in
                        Text(model.name).tag(model.name)
                    }
                }
                
                Button("Analyze") {
                    Task {
                        await viewModel.analyzeModel(name: selectedModel)
                    }
                }
                .disabled(selectedModel.isEmpty)
            }
            
            if viewModel.isLoading {
                Section {
                    ProgressView("Analyzing...")
                }
            }
            
            if let error = viewModel.errorMessage {
                Section {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
            
            if let analysis = viewModel.modelAnalysis {
                Section("Performance Metrics") {
                    if let accuracy = analysis.accuracy {
                        LabeledContent("Accuracy", value: String(format: "%.2f%%", accuracy * 100))
                    }
                    if let precision = analysis.precision {
                        LabeledContent("Precision", value: String(format: "%.2f%%", precision * 100))
                    }
                    if let recall = analysis.recall {
                        LabeledContent("Recall", value: String(format: "%.2f%%", recall * 100))
                    }
                    if let f1 = analysis.f1Score {
                        LabeledContent("F1 Score", value: String(format: "%.2f%%", f1 * 100))
                    }
                }
            }
        }
        .task {
            await viewModel.loadModels()
        }
    }
}

@MainActor
class AnalysisViewModel: ObservableObject {
    @Published var leagues: [League] = []
    @Published var models: [MLModel] = []
    @Published var leagueAnalysis: LeagueAnalysis?
    @Published var modelAnalysis: ModelAnalysis?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    
    func loadLeagues() async {
        do {
            let data = try await apiService.getLeagues()
            leagues = data.saved
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func loadModels() async {
        do {
            models = try await apiService.getModels()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func analyzeLeague(name: String) async {
        isLoading = true
        errorMessage = nil
        leagueAnalysis = nil
        
        do {
            leagueAnalysis = try await apiService.analyzeLeague(name: name)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func analyzeModel(name: String) async {
        isLoading = true
        errorMessage = nil
        modelAnalysis = nil
        
        do {
            modelAnalysis = try await apiService.analyzeModel(name: name)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

struct AnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        AnalysisView()
    }
}
