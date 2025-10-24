//
//  APIModels.swift
//  HitBetApp
//
//  Data models for API communication
//

import Foundation

// MARK: - API Response Wrappers

struct APIResponse<T: Codable>: Codable {
    let status: String
    let data: T?
    let message: String?
}

// MARK: - Dashboard Models

struct DashboardData: Codable {
    let stats: DashboardStats
    let recentLeagues: [League]
    let recentModels: [MLModel]
    
    enum CodingKeys: String, CodingKey {
        case stats
        case recentLeagues = "recent_leagues"
        case recentModels = "recent_models"
    }
}

struct DashboardStats: Codable {
    let totalLeaguesAvailable: Int
    let savedLeaguesCount: Int
    let savedModelsCount: Int
    let countriesAvailable: Int
    
    enum CodingKeys: String, CodingKey {
        case totalLeaguesAvailable = "total_leagues_available"
        case savedLeaguesCount = "saved_leagues_count"
        case savedModelsCount = "saved_models_count"
        case countriesAvailable = "countries_available"
    }
}

// MARK: - League Models

struct League: Codable, Identifiable {
    let id: Int?
    let name: String
    let country: String?
    let seasonsCount: Int?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, country
        case seasonsCount = "seasons_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct LeaguesData: Codable {
    let available: [AvailableLeague]
    let saved: [League]
}

struct AvailableLeague: Codable, Identifiable {
    var id: String { name }
    let country: String
    let name: String
    let seasonsCount: Int
    
    enum CodingKeys: String, CodingKey {
        case country, name
        case seasonsCount = "seasons_count"
    }
}

// MARK: - Model Models

struct MLModel: Codable, Identifiable {
    let id: Int?
    let name: String
    let modelType: String?
    let leagueName: String?
    let accuracy: Double?
    let trainingSamples: Int?
    let testSamples: Int?
    let features: Int?
    let createdAt: String?
    let updatedAt: String?
    let isActive: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, name, accuracy, features
        case modelType = "model_type"
        case leagueName = "league_name"
        case trainingSamples = "training_samples"
        case testSamples = "test_samples"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isActive = "is_active"
    }
}

struct ModelType: Codable, Identifiable {
    var id: String { type }
    let type: String
    let name: String
    let description: String
}

// MARK: - Prediction Models

struct PredictionRequest: Codable {
    let modelName: String
    let homeTeam: String
    let awayTeam: String
    
    enum CodingKeys: String, CodingKey {
        case modelName = "model_name"
        case homeTeam = "home_team"
        case awayTeam = "away_team"
    }
}

struct PredictionResult: Codable, Identifiable {
    var id: String { "\(homeTeam)-\(awayTeam)-\(Date().timeIntervalSince1970)" }
    let homeTeam: String
    let awayTeam: String
    let prediction: String
    let confidence: Double
    let probabilities: MatchProbabilities
    
    enum CodingKeys: String, CodingKey {
        case homeTeam = "home_team"
        case awayTeam = "away_team"
        case prediction, confidence, probabilities
    }
}

struct MatchProbabilities: Codable {
    let homeWin: Double
    let draw: Double
    let awayWin: Double
    
    enum CodingKeys: String, CodingKey {
        case homeWin = "home_win"
        case draw
        case awayWin = "away_win"
    }
}

struct FixturePredictionRequest: Codable {
    let modelName: String
    let leagueName: String
    
    enum CodingKeys: String, CodingKey {
        case modelName = "model_name"
        case leagueName = "league_name"
    }
}

// MARK: - Training Request

struct TrainingRequest: Codable {
    let leagueName: String
    let modelType: String
    let modelName: String
    
    enum CodingKeys: String, CodingKey {
        case leagueName = "league_name"
        case modelType = "model_type"
        case modelName = "model_name"
    }
}

// MARK: - Country Model

struct Country: Codable, Identifiable {
    let name: String
    let leagues: [String]
    let leaguesCount: Int
    
    var id: String { name }
    
    enum CodingKeys: String, CodingKey {
        case name, leagues
        case leaguesCount = "leagues_count"
    }
}

// MARK: - Analysis Models

struct LeagueAnalysis: Codable {
    let totalMatches: Int?
    let homeWins: Int?
    let draws: Int?
    let awayWins: Int?
    let avgGoalsPerMatch: Double?
    
    enum CodingKeys: String, CodingKey {
        case totalMatches = "total_matches"
        case homeWins = "home_wins"
        case draws
        case awayWins = "away_wins"
        case avgGoalsPerMatch = "avg_goals_per_match"
    }
}

struct ModelAnalysis: Codable {
    let accuracy: Double?
    let precision: Double?
    let recall: Double?
    let f1Score: Double?
    
    enum CodingKeys: String, CodingKey {
        case accuracy, precision, recall
        case f1Score = "f1_score"
    }
}
