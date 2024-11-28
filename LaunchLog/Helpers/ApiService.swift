//
//  ApiService.swift
//  LaunchLog
//
//  Created by Jing Li on 11/15/24.
//


import SwiftUI
import Combine

struct ApiService {
    enum NetworkError: Error {
        case badUrl
        case badResponse(statusCode: Int)
    }
    
    static func fetchLaunches(searchText: String, limit: Int, offset: Int) async throws -> [Launch] {
        guard let url = URL(string: "https://ll.thespacedevs.com/2.3.0/launches/?search=\(searchText)&limit=\(limit)&offset=\(offset)") else { // max limit=100
            throw NetworkError.badUrl
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        if let statusCode = (response as? HTTPURLResponse)?.statusCode, !(200...299 ~= statusCode) {
            throw NetworkError.badResponse(statusCode: statusCode)
        }
        
        let launchesResult = try JSONDecoder().decode(LaunchesResult.self, from: data)
        return launchesResult.results
    }
    
    static func fetchLaunchDetail(id: String) async throws -> LaunchDetail {
        guard let url = URL(string: "https://ll.thespacedevs.com/2.3.0/launches/\(id)") else {
            throw NetworkError.badUrl
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        if let statusCode = (response as? HTTPURLResponse)?.statusCode, !(200...299 ~= statusCode) {
            throw NetworkError.badResponse(statusCode: statusCode)
        }
        
        let launchDetail = try JSONDecoder().decode(LaunchDetail.self, from: data)
        return launchDetail
    }
}
