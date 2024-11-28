//
//  LaunchDetail.swift
//  LaunchLog
//
//  Created by Jing Li on 11/18/24.
//


import Foundation

struct LaunchDetail: Codable {
    let id, name, net: String
    
    let status: LaunchStatus
    let image: ImageLabel?
    
    let launchServiceProvider: Agency
    let rocket: Rocket
    let mission: Mission?
    
    let videoUrls: [VideoUrl]  // use [0]

    // pad, program[], updates?, vid_urls(video)[]?, timeline[]?

    enum CodingKeys: String, CodingKey {
        case id, name, net, status, image, rocket, mission
        case launchServiceProvider = "launch_service_provider"
        case videoUrls = "vid_urls"
    }
}

struct Agency: Codable {
    let id: Int
    let featured: Bool?
    
    let name, abbrev: String
    let type: NamedLabel
    let countries: [Country]?
    
    let description, administrator: String?
    let foundingYear: Int? //to do camel case, codingkey
    let image, logo, socialLogo: ImageLabel?
    // and some parameters
    
    enum CodingKeys: String, CodingKey {
        case countries = "country"
        case foundingYear = "founding_year"
        case socialLogo = "social_logo"
        case id, featured, name, abbrev, type, description, administrator, image, logo
    }
}

struct Rocket: Codable {
    let configuration: RocketConfiguration
    let spacecraftStage: [SpacecraftStage]? // to do: use [0]
    
    enum CodingKeys: String, CodingKey {
        case configuration
        case spacecraftStage = "spacecraft_stage"
    }
}
struct RocketConfiguration: Codable {
    let id: Int
    let name, description: String
    let active, reusable: Bool
    let manufacturer: Agency
    let image: ImageLabel?
    
    // list parameters
    let length, diameter: Float? // in meters
    let leo_capacity, gto_capacity: Float? // in kg
    let launch_mass: Float? // in tonnes
    let to_thrust: Float? // in kN
    let max_stage: Int?
    let maiden_flight: String?
    let successful_launches, consecutive_successful_launches, failed_launches: Int?
}

struct SpacecraftStage: Codable {
    let id: Int
    let destination: String
    
    let spacecraft: Spacecraft
    // let landing: Landing // with location
    let launchCrew: [CrewMember]?
    
    enum CodingKeys: String, CodingKey {
        case id, destination, spacecraft
        case launchCrew = "launch_crew"
    }
}

struct Spacecraft: Codable {
    let name, serialNumber, description: String
    let image: ImageLabel
    let inSpace: Bool
    // other params
    let status: NamedLabel
    
    let spacecraftConfig: SpacecraftConfig
    
    enum CodingKeys: String, CodingKey {
        case name, description, image, status
        case spacecraftConfig = "spacecraft_config"
        case serialNumber = "serial_number"
        case inSpace = "in_space"
    }
}
struct SpacecraftConfig: Codable {
    let name: String
    let type: NamedLabel
    let agency: Agency
}

struct CrewMember: Codable {
    let role: Role
    let astronaut: Astronaut
}
struct Role: Codable {
    let role: String
}
struct Astronaut: Codable {
    let id, age: Int
    let name, bio: String
    let status: NamedLabel
    let agency: Agency // in list mode, brief
    
    let image: ImageLabel
    let type: NamedLabel
    
    let inSpace: Bool
    // params: time
    let dob, lastFlight, firstFlight: String
    let dod: String?
    
    let nationality: [Country] // [0]
    
    enum CodingKeys: String, CodingKey {
        case id, age, name, bio, status, agency, image, type, nationality
        case inSpace = "in_space"
        case dob = "date_of_birth"
        case dod = "date_of_death"
        case lastFlight = "last_flight"
        case firstFlight = "first_flight"
    }
}

struct Country: Codable {
    let name, national: String // national: e.g. "American"
    
    enum CodingKeys: String, CodingKey {
        case name
        case national = "nationality_name"
    }
}

/*
struct Landing: Codable {
    // to do: with location
}*/

struct VideoUrl: Codable {
    let title, description, imageUrl, urlString: String
    enum CodingKeys: String, CodingKey {
        case title, description
        case imageUrl = "feature_image"
        case urlString = "url"
    }
}

struct Mission: Codable {
    let name, type, description: String
    let orbit: Orbit
}
struct Orbit: Codable {
    let name: String
    let celestialBody: NamedLabel
    
    enum CodingKeys: String, CodingKey {
        case name
        case celestialBody = "celestial_body"
    }
}

struct NamedLabel: Codable {
    let name: String
}
