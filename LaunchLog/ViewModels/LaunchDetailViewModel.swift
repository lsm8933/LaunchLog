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
    
    init(id: String) {
        // revert comment to fetch, when network 429 is gone and status back to normal.
        fetchLaunchDetail(id: id)
    }
    
    func fetchLaunchDetail(id: String) {
        Task {
            do {
                launchDetail = try await ApiService.fetchLaunchDetail(id: id)
                print("\nLaunch Detail: ")
                print(launchDetail)
            } catch {
                print(error)
            }
        }
    }
}