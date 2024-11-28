//
//  LaunchesViewModel.swift
//  LaunchLog
//
//  Created by Jing Li on 11/28/24.
//


import SwiftUI
import Combine

@MainActor
class LaunchesViewModel: ObservableObject {
    @Published var launches: [Launch] = []
    
    @Published var searchText = ""
    var subscribers: [AnyCancellable] = []
    
    var page = 0
    var limit = 10
    
    enum NetworkStatus {
        case readyToStart
        case loading
        case endOfData
        case error(error: Error)
    }
    @Published var state: NetworkStatus = .readyToStart
    
    init() {
        $searchText.debounce(for: 0.5, scheduler: DispatchQueue.main)
            .sink { [weak self] newValue in
                guard let self = self else {
                    return
                }
                
                print("searching on searchText publisher... \(newValue)")
                self.fetchLaunches(searchText: newValue, offset: 0) 
            }
            .store(in: &subscribers)
    }
    
    func fetchLaunches(searchText: String, offset: Int) {
        // new searchText
        if offset == 0 {
            print("reset page and launches[]")
            page = 0
            launches = []
            state = .readyToStart
        }
        
        if searchText == "" {
            print("empty queryTerm, return")
            return
        }
        
        switch state {
        case .readyToStart, .loading :
            print("ready to start")
            Task {
                do {
                    print("loading")
                    state = .loading
                    let fetchedLaunches = try await ApiService.fetchLaunches(searchText: searchText, limit: limit,  offset: offset)
                    
                    if offset == 0 { // new searchText
                        launches = fetchedLaunches
                        page = 1
                    } else { // fetch more for earlier searchText
                        launches.append(contentsOf: fetchedLaunches)
                        page += 1
                    }
                    
                    print(fetchedLaunches)
                    print("total result count: \(launches.count)")
                    
                    if fetchedLaunches.count < limit {
                        print("end of data")
                        state = .endOfData
                    } else {
                        print("finished loading, ready to start")
                        state = .readyToStart
                    }
                } catch {
                    state = .error(error: error)
                    print("state error, \(error)")
                }
            }
        case .endOfData, .error(error: _):
            return
        }
    }
    
    func fetchMoreLaunches() {
        print("fetch more function start...")
        
        let offset = page * limit
        fetchLaunches(searchText: searchText, offset: offset)
    }
}
