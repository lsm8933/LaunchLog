//
//  LaunchDetailViewModel.swift
//  LaunchLog
//
//  Created by Jing Li on 11/28/24.
//


import SwiftUI
import WebKit

@MainActor
class LaunchDetailViewModel: ObservableObject {
    @Published var launchDetail: LaunchDetail?
    
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    init(id: String) {
        // revert comment to fetch, when network 429 is gone and status back to normal.
        fetchLaunchDetail(id: id)
    }
    
    func fetchLaunchDetail(id: String) {
        isLoading = true
        Task {
            do {
                launchDetail = try await ApiService.fetchLaunchDetail(id: id)
                isLoading = false
                print("\nLaunch Detail: ")
                print(launchDetail)
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
                print(error)
            }
        }
    }
}
