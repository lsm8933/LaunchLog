//
//  LaunchesResult.swift
//  LaunchLog
//
//  Created by Jing Li on 11/28/24.
//


struct LaunchesResult: Codable {
    let results: [Launch]
}

struct Launch: Codable, Identifiable{
    let id, name, net: String
    let status: LaunchStatus
    let image: ImageLabel?
}

struct LaunchStatus: Codable {
    let id: Int
    let name, abbrev: String
}

struct ImageLabel: Codable {
    let image_url, thumbnail_url: String
}
