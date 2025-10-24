//
//  DashboardViewModel.swift
//  HitBetApp
//
//  ViewModel for Dashboard
//

import Foundation

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var dashboardData: DashboardData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    
    func loadDashboard() async {
        isLoading = true
        errorMessage = nil
        
        do {
            dashboardData = try await apiService.getDashboard()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
