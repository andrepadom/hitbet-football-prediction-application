//
//  APIService.swift
//  HitBetApp
//
//  Network service layer for API communication
//

import Foundation

class APIService {
    static let shared = APIService()
    private let baseURL: String
    
    init(baseURL: String = "http://localhost:5000/api/v1") {
        self.baseURL = baseURL
    }
    
    // MARK: - Generic Request Methods
    
    private func performRequest<T: Codable>(
        endpoint: String,
        method: String = "GET",
        body: Codable? = nil
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
    
    private func performAPIRequest<T: Codable>(
        endpoint: String,
        method: String = "GET",
        body: Codable? = nil
    ) async throws -> T {
        let response: APIResponse<T> = try await performRequest(
            endpoint: endpoint,
            method: method,
            body: body
        )
        
        guard response.status == "success", let data = response.data else {
            throw APIError.apiError(message: response.message ?? "Unknown error")
        }
        
        return data
    }
    
    // MARK: - Health & Dashboard
    
    func checkHealth() async throws -> Bool {
        struct HealthResponse: Codable {
            let status: String
        }
        let health: HealthResponse = try await performRequest(endpoint: "/health")
        return health.status == "ok"
    }
    
    func getDashboard() async throws -> DashboardData {
        return try await performAPIRequest(endpoint: "/dashboard")
    }
    
    // MARK: - Leagues
    
    func getLeagues() async throws -> LeaguesData {
        return try await performAPIRequest(endpoint: "/leagues")
    }
    
    func getLeagueDetails(name: String) async throws -> League {
        let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? name
        return try await performAPIRequest(endpoint: "/leagues/\(encodedName)")
    }
    
    func downloadLeague(name: String) async throws -> String {
        struct DownloadRequest: Codable {
            let league_name: String
        }
        struct MessageResponse: Codable {
            let message: String
        }
        
        let request = DownloadRequest(league_name: name)
        let response: APIResponse<MessageResponse> = try await performRequest(
            endpoint: "/leagues/download",
            method: "POST",
            body: request
        )
        
        guard response.status == "success" else {
            throw APIError.apiError(message: response.message ?? "Download failed")
        }
        
        return response.message ?? "Download successful"
    }
    
    func deleteLeague(name: String) async throws {
        let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? name
        let _: APIResponse<String> = try await performRequest(
            endpoint: "/leagues/\(encodedName)",
            method: "DELETE"
        )
    }
    
    // MARK: - Models
    
    func getModels() async throws -> [MLModel] {
        return try await performAPIRequest(endpoint: "/models")
    }
    
    func getModelDetails(name: String) async throws -> MLModel {
        let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? name
        return try await performAPIRequest(endpoint: "/models/\(encodedName)")
    }
    
    func trainModel(request: TrainingRequest) async throws -> String {
        struct MessageResponse: Codable {
            let message: String
        }
        
        let response: APIResponse<MessageResponse> = try await performRequest(
            endpoint: "/models/train",
            method: "POST",
            body: request
        )
        
        guard response.status == "success" else {
            throw APIError.apiError(message: response.message ?? "Training failed")
        }
        
        return response.message ?? "Training successful"
    }
    
    func deleteModel(name: String) async throws {
        let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? name
        let _: APIResponse<String> = try await performRequest(
            endpoint: "/models/\(encodedName)",
            method: "DELETE"
        )
    }
    
    func getModelTypes() async throws -> [ModelType] {
        return try await performAPIRequest(endpoint: "/model-types")
    }
    
    // MARK: - Predictions
    
    func predictSingleMatch(request: PredictionRequest) async throws -> PredictionResult {
        return try await performAPIRequest(
            endpoint: "/predictions/single",
            method: "POST",
            body: request
        )
    }
    
    func predictFixtures(request: FixturePredictionRequest) async throws -> [PredictionResult] {
        return try await performAPIRequest(
            endpoint: "/predictions/fixtures",
            method: "POST",
            body: request
        )
    }
    
    // MARK: - Analysis
    
    func analyzeLeague(name: String) async throws -> LeagueAnalysis {
        let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? name
        return try await performAPIRequest(endpoint: "/analysis/league/\(encodedName)")
    }
    
    func analyzeModel(name: String) async throws -> ModelAnalysis {
        let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? name
        return try await performAPIRequest(endpoint: "/analysis/model/\(encodedName)")
    }
    
    // MARK: - Metadata
    
    func getCountries() async throws -> [Country] {
        return try await performAPIRequest(endpoint: "/countries")
    }
}

// MARK: - Error Handling

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case apiError(message: String)
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .apiError(let message):
            return message
        case .decodingError:
            return "Failed to decode response"
        }
    }
}
