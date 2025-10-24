//
//  ModelsView.swift
//  HitBetApp
//
//  View for managing ML models
//

import SwiftUI

struct ModelsView: View {
    @StateObject private var viewModel = ModelsViewModel()
    @State private var showingTrainSheet = false
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.isLoading {
                    ProgressView("Loading models...")
                } else if let error = viewModel.errorMessage {
                    ErrorView(message: error) {
                        Task { await viewModel.loadModels() }
                    }
                } else if viewModel.models.isEmpty {
                    ContentUnavailableView(
                        "No Models",
                        systemImage: "brain.head.profile",
                        description: Text("Train a new model to get started")
                    )
                } else {
                    ForEach(viewModel.models) { model in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(model.name)
                                .font(.headline)
                            
                            HStack {
                                if let type = model.modelType {
                                    Text(type.uppercased())
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.2))
                                        .cornerRadius(4)
                                }
                                
                                if let accuracy = model.accuracy {
                                    Text(String(format: "%.1f%% accuracy", accuracy * 100))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            if let league = model.leagueName {
                                Text(league)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                        .swipeActions {
                            Button(role: .destructive) {
                                Task {
                                    await viewModel.deleteModel(name: model.name)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Models")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingTrainSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingTrainSheet) {
                TrainModelSheet(viewModel: viewModel)
            }
            .refreshable {
                await viewModel.loadModels()
            }
        }
        .task {
            await viewModel.loadModels()
        }
    }
}

struct TrainModelSheet: View {
    @ObservedObject var viewModel: ModelsViewModel
    @Environment(\.dismiss) var dismiss
    @State private var modelName = ""
    @State private var selectedLeague = ""
    @State private var selectedModelType = "fcnet"
    
    var body: some View {
        NavigationView {
            Form {
                Section("Model Details") {
                    TextField("Model Name", text: $modelName)
                    
                    Picker("Model Type", selection: $selectedModelType) {
                        Text("FCNet").tag("fcnet")
                        Text("Random Forest").tag("random_forest")
                    }
                }
                
                Section("League") {
                    TextField("League Name", text: $selectedLeague)
                        .autocapitalization(.none)
                }
            }
            .navigationTitle("Train New Model")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Train") {
                        Task {
                            await viewModel.trainModel(
                                name: modelName,
                                type: selectedModelType,
                                league: selectedLeague
                            )
                            dismiss()
                        }
                    }
                    .disabled(modelName.isEmpty || selectedLeague.isEmpty)
                }
            }
        }
    }
}

@MainActor
class ModelsViewModel: ObservableObject {
    @Published var models: [MLModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    
    func loadModels() async {
        isLoading = true
        errorMessage = nil
        
        do {
            models = try await apiService.getModels()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func trainModel(name: String, type: String, league: String) async {
        let request = TrainingRequest(
            leagueName: league,
            modelType: type,
            modelName: name
        )
        
        do {
            _ = try await apiService.trainModel(request: request)
            await loadModels()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteModel(name: String) async {
        do {
            try await apiService.deleteModel(name: name)
            await loadModels()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct ModelsView_Previews: PreviewProvider {
    static var previews: some View {
        ModelsView()
    }
}
