//
//  ContentView.swift
//  LaunchLog
//
//  Created by Jing Li on 10/31/24.
//


import SwiftUI
import Combine

struct LaunchesView: View {
    @StateObject var vm: LaunchesViewModel
    
    init() {
        self._vm = .init(wrappedValue: LaunchesViewModel())
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                
                LazyVStack {
                    ForEach(vm.launches) { launch in
                        // Cell
                        HStack(alignment: .center, spacing: 16) {
                            if let image = launch.image, let url = URL(string: image.thumbnail_url) {
                                AsyncImage(url: url, content: { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                }, placeholder: {
                                    Spacer()
                                        .foregroundStyle(Color.gray)
                                })
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .shadow(color: .gray, radius: 4, x: 0, y: 2)
                                .padding(.leading, 8)
                                .padding(.vertical, 8)
                                
                            } else {
                                Spacer()
                                    .foregroundStyle(Color.gray)
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                    .padding(.leading, 8)
                                    .padding(.vertical, 8)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(launch.name) //Text("Falcon 9 Block 5 | Starlink Group 9-9")
                                    .font(.system(size: 18, weight: .semibold))
                                    .lineLimit(2)
                                
                                HStack(spacing: 2) {
                                    let statusId = launch.status.id
                                    Image(systemName: "circle.fill")
                                        .foregroundStyle(1...2 ~= statusId ? Color.yellow : statusId == 3 ? Color.green : 4...7 ~= statusId ? Color.red : Color.yellow)
                                    Text(launch.status.abbrev)
                                }
                                
                                Text(launch.net) // "2024/10/30 - 20:07:00 CST"
                                    .foregroundStyle(Color(.darkGray))
                            }
                            Spacer()
                            
                            NavigationLink(destination: LaunchDetailView(id: launch.id)) {
                                Image(systemName: "arrow.forward")
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundStyle(Color(.darkGray))
                                    .padding(.trailing, 16)
                            }
                        }// end of cell
                        .font(.system(size: 16))
                        .background(.yellow)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .shadow(color: .init(white: 0.9, opacity: 1), radius: 4, x: 0, y: 2)
                        .padding(.bottom, 8)
                        .padding(.horizontal, 8)
                    }
                    
                    /*
                    // Placeholder list, for development purpose
                    ForEach(0..<5) {_ in
                        HStack(alignment: .center, spacing: 8) {
                            
                            Spacer()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .foregroundStyle(Color.gray)
                                .padding(.leading, 8)
                                .padding(.vertical, 8)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Falcon 9 Block 5 | Starlink Group 9-9")
                                    .font(.system(size: 18, weight: .semibold))
                                    .lineLimit(2)
                                
                                HStack(spacing: 2) {
                                    Image(systemName: "circle.fill")
                                        .foregroundStyle(Color.green)
                                    Text("Success")
                                }
                                
                                Text("2024/10/30 - 20:07:00 CST")
                                    .foregroundStyle(Color(.darkGray))
                            }
                            Spacer()
                            Image(systemName: "arrow.forward")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(Color(.darkGray))
                                .padding(.trailing, 16)
                            
                        }// end of cell
                        .font(.system(size: 16))
                        .background(.yellow)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .shadow(color: .init(white: 0.9, opacity: 1), radius: 4, x: 0, y: 2)
                        .padding(.bottom, 8)
                        .padding(.horizontal, 8)
                    }
                    // end of placeholder list
                     */
                    
                    switch vm.state {
                    case .readyToStart:
                        if vm.launches.count > 0 {
                            // to do: change to clear
                            Color.clear
                                .frame(width: 20, height: 10)
                                .onAppear(perform: { // need List or lazyVStack to fire this call every time it appears on screen. vs ScrollView and ForEach only gets called when they are created.
                                    print("fetch more from clear box")
                                    vm.fetchMoreLaunches()
                                })
                        }
                    case .loading:
                        ProgressView()
                            .progressViewStyle(.circular)
                            .font(.system(size: 22))
                            .foregroundStyle(Color.gray)
                    case .endOfData:
                        EmptyView()
                    case .error(let error):
                        Text(error.localizedDescription)
                            .foregroundStyle(Color.red)
                            .font(.system(size: 16))
                    }
                    
                }// end of lazyVStack
            }
            .navigationTitle("Launches")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $vm.searchText, prompt: "Search for a launch")
        }
    }
}

#Preview {
    LaunchesView()
}

