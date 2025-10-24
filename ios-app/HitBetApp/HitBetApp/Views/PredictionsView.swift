//
//  PredictionsView.swift
//  HitBetApp
//
//  View for making match predictions
//

import SwiftUI

struct PredictionsView: View {
    @StateObject private var viewModel = PredictionsViewModel()
    @State private var homeTeam = ""
    @State private var awayTeam = ""
    @State private var selectedModel = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Select Model") {
                    Picker("Model", selection: $selectedModel) {
                        Text("Select a model").tag("")
                        ForEach(viewModel.models) { model in
                            Text(model.name).tag(model.name)
                        }
                    }
                }
                
                Section("Match Details") {
                    TextField("Home Team", text: $homeTeam)
                        .autocapitalization(.words)
                    
                    TextField("Away Team", text: $awayTeam)
                        .autocapitalization(.words)
                }
                
                Section {
                    Button("Predict Match") {
                        Task {
                            await viewModel.predictMatch(
                                modelName: selectedModel,
                                homeTeam: homeTeam,
                                awayTeam: awayTeam
                            )
                        }
                    }
                    .disabled(selectedModel.isEmpty || homeTeam.isEmpty || awayTeam.isEmpty)
                }
                
                if viewModel.isLoading {
                    Section {
                        ProgressView("Predicting...")
                    }
                }
                
                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
                
                if let prediction = viewModel.lastPrediction {
                    Section("Prediction Result") {
                        PredictionResultView(prediction: prediction)
                    }
                }
            }
            .navigationTitle("Predictions")
        }
        .task {
            await viewModel.loadModels()
        }
    }
}

struct PredictionResultView: View {
    let prediction: PredictionResult
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(prediction.homeTeam)
                    .font(.headline)
                Spacer()
                Text("vs")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(prediction.awayTeam)
                    .font(.headline)
            }
            
            VStack(spacing: 8) {
                Text("Prediction")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(prediction.prediction)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text(String(format: "Confidence: %.1f%%", prediction.confidence * 100))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 12) {
                ProbabilityBar(
                    label: "Home Win",
                    probability: prediction.probabilities.homeWin,
                    color: .green
                )
                
                ProbabilityBar(
                    label: "Draw",
                    probability: prediction.probabilities.draw,
                    color: .orange
                )
                
                ProbabilityBar(
                    label: "Away Win",
                    probability: prediction.probabilities.awayWin,
                    color: .red
                )
            }
        }
        .padding(.vertical)
    }
}

struct ProbabilityBar: View {
    let label: String
    let probability: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.caption)
                Spacer()
                Text(String(format: "%.1f%%", probability * 100))
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(probability), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
    }
}

@MainActor
class PredictionsViewModel: ObservableObject {
    @Published var models: [MLModel] = []
    @Published var lastPrediction: PredictionResult?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    
    func loadModels() async {
        do {
            models = try await apiService.getModels()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func predictMatch(modelName: String, homeTeam: String, awayTeam: String) async {
        isLoading = true
        errorMessage = nil
        lastPrediction = nil
        
        let request = PredictionRequest(
            modelName: modelName,
            homeTeam: homeTeam,
            awayTeam: awayTeam
        )
        
        do {
            lastPrediction = try await apiService.predictSingleMatch(request: request)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

struct PredictionsView_Previews: PreviewProvider {
    static var previews: some View {
        PredictionsView()
    }
}
