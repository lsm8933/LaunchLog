//
//  LaunchDetailView.swift
//  LaunchLog
//
//  Created by Jing Li on 11/15/24.
//


import SwiftUI
import WebKit

// for development purpose, to see preview, put struct LaunchDetailView and preview into LLApp.swift
struct LaunchDetailView: View {
    @StateObject var vm: LaunchDetailViewModel
    
    init(id: String) {
        self._vm = .init(wrappedValue: LaunchDetailViewModel(id: id))
    }
    
    var body: some View {
        Group {
            // When network status is back to normal: revert to using vm's model. Network 429: use hard-coded launchDetail object.
            if vm.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .controlSize(.large)
            } else if vm.errorMessage != "" {
                Text(vm.errorMessage)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.red)
            } else if let launchDetail = vm.launchDetail {
                
                ScrollView {
                    // HeaderView
                    ZStack(alignment: .bottomLeading) {
                        AsyncImage(url: URL(string: launchDetail.image?.image_url ?? "")) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Color(white: 0.9, opacity: 0.5)
                        }.frame(minWidth: 0, maxWidth: .infinity)
                            .frame(height: 350)
                            .clipped()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Spacer()
                            Text(launchDetail.name)
                                .font(.system(size: 26, weight: .semibold))
                                .lineLimit(2)
                            HStack() {
                                let statusId = launchDetail.status.id
                                Text(launchDetail.status.abbrev)
                                    .font(.system(size: 18, weight: .semibold))
                                    .padding(8)
                                    .background(1...2 ~= statusId ? Color.yellow : statusId == 3 ? Color.green : 4...7 ~= statusId ? Color.red : Color.yellow)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                Text(" | " + launchDetail.net.replacingOccurrences(of: "T", with: " ").replacingOccurrences(of: "Z", with: " UTC"))
                                    .font(.system(size: 16))
                            }
                        }.foregroundStyle(Color.white)
                            .padding(16)
                    }
                    .padding(.bottom, 16)
                    
                    // RocketView
                    RocketSectionView(rocket: launchDetail.rocket)
                    
                    // RocketManufacturer
                    AgencySectionView(agency: launchDetail.rocket.configuration.manufacturer, agencyType: .rocketManufacturer)
                    
                    // VideoView, urlString samples:
                    // "https://www.youtube.com/watch?v=8bxBjqvnmjM"
                    // "https://www.youtube.com/embed/8bxBjqvnmjM"
                    // "https://vimeo.com/channels/bestofstaffpicks/1006042481"
                    if launchDetail.videoUrls.count > 0 {
                        VideoSectionView(videoUrlString: launchDetail.videoUrls[0].urlString)
                    }
                    
                    // MissionView
                    if let mission = launchDetail.mission {
                        MissionSectionView(mission: mission)
                    }
                    
                    // LaunchServiceProvider
                    AgencySectionView(agency: launchDetail.launchServiceProvider, agencyType: .launchServiceProvider)
                }.toolbarBackgroundVisibility(Visibility.hidden, for: ToolbarPlacement.navigationBar)
                    .ignoresSafeArea(edges: Edge.Set.top)
                
            }
            // revert comment, if network traffic is back to normal.
            //            else {
            //                Text("Oops, looks like we have lost detail of this launch.")
            //            }
        }
    }
}

#Preview {
    //LaunchDetailView(id: "eed1132a-d5aa-4c9c-bc38-c8ccb98829b6")
    LaunchDetailView(id: "973b1401-b6c1-401f-b795-d2a53265ad9a")
}

// Subviews
struct RocketSectionView: View {
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    
    let rocket: Rocket
    
    var body: some View {
        VStack(spacing: 8) {
            Divider()
                .padding(.horizontal, 16)
            
            HStack{
                Text("Rocket")
                    .font(.system(size: 22, weight: Font.Weight.semibold))
                Spacer()
            }
            .padding(.horizontal, 16)
            
            HStack(spacing: 16) {
                AsyncImage(url: URL(string: rocket.configuration.image?.thumbnail_url ?? "")) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    Color(white: 0.9, opacity: 0.5)
                }.frame(width: 100, height: 100)
                    .cornerRadius(16)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(rocket.configuration.name)
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text((rocket.configuration.reusable ? "Reusable": "Non-reusable") + " • " + (rocket.configuration.active ? "Active": "Inactive"))
                        .font(.system(size:16))
                        .foregroundStyle(Color(.darkGray))
                    Spacer()
                }
                .padding(.vertical, 16)
                Spacer()
            }.padding(.horizontal, 16)
            
            let rocketConfiguration = rocket.configuration
            var rowCount = 0
            List {
                Section(header: Text("Parameters").font(.system(size: 12))) {
                    if let height = rocketConfiguration.length {
                        HStack {
                            Text("Height")
                            Spacer()
                            Text(String(format: "%.2f", height) + " Meters")
                        }
                        let _ = (rowCount += 1)
                    }
                    if let diameter = rocketConfiguration.diameter {
                        HStack {
                            Text("Diameter")
                            Spacer()
                            Text(String(format: "%.2f", diameter) + " Meters")
                        }
                        let _ = (rowCount += 1)
                    }
                    if let maxStages = rocketConfiguration.max_stage {
                        HStack {
                            Text("Max Stages")
                            Spacer()
                            Text(String(maxStages))
                        }
                        let _ = (rowCount += 1)
                    }
                    if let massToLEO = rocketConfiguration.leo_capacity {
                        HStack {
                            Text("Mass To LEO")
                            Spacer()
                            Text("\(Int(massToLEO)) kg")
                        }
                        let _ = (rowCount += 1)
                    }
                    if let massToGTO = rocketConfiguration.gto_capacity {
                        HStack {
                            Text("Mass To GTO")
                            Spacer()
                            Text("\(Int(massToGTO)) kg")
                        }
                        let _ = (rowCount += 1)
                    }
                    if let liftoffMass = rocketConfiguration.launch_mass {
                        HStack {
                            Text("Liftoff Mass")
                            Spacer()
                            Text("\(Int(liftoffMass)) Tonnes")
                        }
                        let _ = (rowCount += 1)
                    }
                    if let liftoffThrust = rocketConfiguration.to_thrust {
                        HStack {
                            Text("Liftoff Thrust")
                            Spacer()
                            Text("\(Int(liftoffThrust)) kN")
                        }
                        let _ = (rowCount += 1)
                    }
                }
                Section(header: Text("Historical Figures").font(.system(size: 12))) {
                    if let launchSuccess = rocketConfiguration.successful_launches {
                        HStack {
                            Text("Launch Success")
                            Spacer()
                            Text(String(launchSuccess))
                        }
                        let _ = (rowCount += 1)
                    }
                    if let consecutiveSuccess = rocketConfiguration.consecutive_successful_launches {
                        HStack {
                            Text("Consecutive Success")
                            Spacer()
                            Text(String(consecutiveSuccess))
                        }
                        let _ = (rowCount += 1)
                    }
                    if let maidenFlight = rocketConfiguration.maiden_flight {
                        HStack {
                            Text("Maiden Flight")
                            Spacer()
                            Text(maidenFlight)
                        }
                        let _ = (rowCount += 1)
                    }
                    if let launchFailures = rocketConfiguration.failed_launches {
                        HStack {
                            Text("Launch Failures")
                            Spacer()
                            Text(String(launchFailures))
                        }
                        let _ = (rowCount += 1)
                    }
                }
            }
            .scrollDisabled(true)
            .font(.system(size: 16))
            .frame(minHeight: minRowHeight * CGFloat(rowCount + 2) + 24)
            .cornerRadius(16)
            .padding(.vertical, 4)
            
            // to do: see more
            Text(rocket.configuration.description)
                .font(.system(size: 16))
                .lineLimit(6)
                .padding(.horizontal, 16)
        }.padding(.bottom, 16)
    }
}

struct AgencySectionView: View {
    enum AgencyType {
        case launchServiceProvider
        case rocketManufacturer
    }
    
    let agency: Agency
    var agencyType: AgencyType
    
    var body: some View {
        VStack(spacing: 8) {
            Divider()
            
            HStack{
                switch agencyType {
                case .launchServiceProvider:
                    Text("Launch Service Provider")
                        .font(.system(size: 22, weight: Font.Weight.semibold))
                case .rocketManufacturer:
                    Text("Rocket Manufacturer")
                        .font(.system(size: 22, weight: Font.Weight.semibold))
                }
                Spacer()
            }.padding(.bottom, 2)
            
            HStack {
                VStack(alignment: .leading, spacing: 2){
                    Text(agency.name)
                        .font(.system(size: 19, weight: .semibold))
                    
                    // to do: foreach country, use abbrev == alpha3_code
                    HStack(spacing: 4) {
                        Text(agency.type.name + " • " + (agency.countries?[0].name ?? ""))
                            .font(.system(size:17))
                            .lineLimit(1)
                    }
                }
                Spacer()
            }
            
            if let logo = agency.logo {
                AsyncImage(url: URL(string: logo.image_url)) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    Color(white: 0.9, opacity: 0.5)
                }.frame(width: abs(.infinity), height: abs(200))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            
            VStack{
                if let foundingYear = agency.foundingYear {
                    Text("Founded " + String(foundingYear))
                        .font(.system(size:17, weight: .semibold))
                    
                }
                if let administrator = agency.administrator {
                    Text(administrator)
                        .font(.system(size:16))
                }
            }
            
            if let description = agency.description {
                Text(description)
                    .font(.system(size: 17))
                    .lineLimit(5)
            }
        }.padding(.horizontal, 16)
            .padding(.bottom, 16)
    }
}

struct WebViewRepresentable: UIViewRepresentable {
    let url: URL
    
    typealias UIViewType = WKWebView
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}

struct VideoSectionView: View {
    let videoUrlString: String
    var youtubeEmbeddedUrlString: String = ""
    
    init(videoUrlString: String) {
        self.videoUrlString = videoUrlString
        
        // Youtube video urlString, need to be convert to embedded urlString
        if videoUrlString.hasPrefix("https://www.youtube.com/") {
            let videoUrlStringSplits = videoUrlString.components(separatedBy: "?v=")
            if videoUrlStringSplits.count == 2 {
                let youtubeVideoId = videoUrlStringSplits[1]
                youtubeEmbeddedUrlString = "https://www.youtube.com/embed/" + youtubeVideoId
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Divider()
            
            HStack{
                Text("Video")
                    .font(.system(size: 22, weight: Font.Weight.semibold))
                Spacer()
            }
            
            if youtubeEmbeddedUrlString != "", let youtubeUrl = URL(string: youtubeEmbeddedUrlString) {
                WebViewRepresentable(url: youtubeUrl)
                    .frame(height: 250)
                    .cornerRadius(4)
                    .shadow(color: Color.init(white: 0.5), radius: 2, x: 0, y: 4)
            } else if let url = URL(string: videoUrlString) {
                WebViewRepresentable(url: url)
                    .frame(height: 250)
                    .cornerRadius(4)
                    .shadow(color: Color.init(white: 0.5), radius: 2, x: 0, y: 4)
            } else{
                EmptyView()
                    .frame(height: 0)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

struct MissionSectionView: View {
    let mission: Mission
    
    var body: some View {
        VStack(spacing: 8) {
            Divider()
            HStack{
                Text("Mission")
                    .font(.system(size: 22, weight: Font.Weight.semibold))
                Spacer()
            }
            
            VStack(alignment: .center, spacing: 4) {
                Text(mission.name)
                    .font(.system(size: 20, weight: .semibold))
                Text(mission.type)
                    .font(.system(size:16))
                Text(mission.orbit.name)
                    .font(.system(size:16))
                    .foregroundStyle(Color(.darkGray))
            }
            // to do: see more
            Text(mission.description)
                .font(.system(size: 16))
                .lineLimit(4)
        }.padding(.horizontal, 16)
            .padding(.bottom, 16)
    }
}

// hard-coded model object, for development use, when network 429 error occurs.
// let launchDetail = LaunchDetail(id: "973b1401-b6c1-401f-b795-d2a53265ad9a", name: "Space Shuttle Challenger / OV-099 | STS-61-A", net: "1985-10-30T17:00:00Z", status: LaunchStatus(id: 3, name: "Launch Successful", abbrev: "Success"), image: ImageLabel(image_url: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/space_shuttle_image_20230422074810.jpeg", thumbnail_url: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/255bauto255d__image_thumbnail_20240305193916.jpeg"), launchServiceProvider: Agency(id: 192, featured: Optional(false), name: "Lockheed Space Operations Company", abbrev: "LSOC", type: LaunchLog.NamedLabel(name: "Commercial"), countries: [Country(name: "United States of America", national: "American")], description: nil, administrator: nil, foundingYear: nil, image: nil, logo: nil, socialLogo: nil), rocket: Rocket(configuration: LaunchLog.RocketConfiguration(id: 493, name: "Space Shuttle", description: "The Space Shuttle is a retired, partially reusable low Earth orbital spacecraft system operated from 1981 to 2011 by the U.S. National Aeronautics and Space Administration (NASA) as part of the Space Shuttle program. Its official program name was Space Transportation System (STS). Five complete Space Shuttle orbiter vehicles were built and flown on a total of 135 missions from 1981 to 2011.", active: false, reusable: true, manufacturer: LaunchLog.Agency(id: 44, featured: Optional(true), name: "National Aeronautics and Space Administration", abbrev: "NASA", type: LaunchLog.NamedLabel(name: "Government"), countries: [Country(name: "United States of America", national: "American")], description: Optional("The National Aeronautics and Space Administration is an independent agency of the executive branch of the United States federal government responsible for the civilian space program, as well as aeronautics and aerospace research. NASA have many launch facilities but most are inactive. The most commonly used pad will be LC-39B at Kennedy Space Center in Florida."), administrator: Optional("Administrator: Bill Nelson"), foundingYear: Optional(1958), image: Optional(LaunchLog.ImageLabel(image_url: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/national2520aeronautics2520and2520space2520administration_image_20190207032448.jpeg", thumbnail_url: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/255bauto255d__image_thumbnail_20240305184631.jpeg")), logo: Optional(LaunchLog.ImageLabel(image_url: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/national2520aeronautics2520and2520space2520administration_logo_20190207032448.png", thumbnail_url: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/255bauto255d__image_thumbnail_20240305185043.png")), socialLogo: Optional(LaunchLog.ImageLabel(image_url: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/national2520aeronautics2520and2520space2520administration_nation_20230803040809.jpg", thumbnail_url: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/255bauto255d__image_thumbnail_20240305184823.jpeg"))), image: Optional(LaunchLog.ImageLabel(image_url: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/space_shuttle_image_20230422074810.jpeg", thumbnail_url: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/255bauto255d__image_thumbnail_20240305193916.jpeg")), length: Optional(56.1), diameter: Optional(8.0), leo_capacity: Optional(27500.0), gto_capacity: nil, launch_mass: Optional(2030.0), to_thrust: Optional(28200.0), max_stage: 2, maiden_flight: "1981-04-12", successful_launches: 133, consecutive_successful_launches: 22, failed_launches: 2), spacecraftStage: Optional([LaunchLog.SpacecraftStage(id: 65, destination: "Low Earth Orbit", spacecraft: LaunchLog.Spacecraft(name: "Space Shuttle Challenger", serialNumber: "OV-099", description: "Space Shuttle Challenger (Orbiter Vehicle Designation: OV-099) was the second orbiter of NASA\'s space shuttle program to be put into service, after Columbia. Challenger was built by Rockwell International\'s Space Transportation Systems Division, in Downey, California. Its maiden flight, STS-6, began on April 4, 1983. The orbiter was launched and landed nine times before breaking apart 73 seconds into its tenth mission, STS-51-L, on January 28, 1986, resulting in the death of all seven crew members, including a civilian school teacher. It was the first of two shuttles to be destroyed in flight, the other being Columbia, in 2003. The accident led to a two-and-a-half-year grounding of the shuttle fleet; flights resumed in 1988, with STS-26 flown by Discovery. Challenger was replaced by Endeavour, which was built from structural spares ordered by NASA in the construction contracts for Discovery and Atlantis.", image: LaunchLog.ImageLabel(image_url: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/spaceshuttle_ch_image_20240309151332.jpeg", thumbnail_url: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/spaceshuttle_ch_image_thumbnail_20240309151332.jpeg"), inSpace: false, status: LaunchLog.NamedLabel(name: "Destroyed"), spacecraftConfig: LaunchLog.SpacecraftConfig(name: "Space Shuttle", type: LaunchLog.NamedLabel(name: "Spaceplane"), agency: LaunchLog.Agency(id: 44, featured: Optional(true), name: "National Aeronautics and Space Administration", abbrev: "NASA", type: LaunchLog.NamedLabel(name: "Government"), countries: [Country(name: "United States of America", national: "American")], description: Optional("The National Aeronautics and Space Administration is an independent agency of the executive branch of the United States federal government responsible for the civilian space program, as well as aeronautics and aerospace research. NASA have many launch facilities but most are inactive. The most commonly used pad will be LC-39B at Kennedy Space Center in Florida."), administrator: Optional("Administrator: Bill Nelson"), foundingYear: Optional(1958), image: Optional(LaunchLog.ImageLabel(image_url: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/national2520aeronautics2520and2520space2520administration_image_20190207032448.jpeg", thumbnail_url: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/255bauto255d__image_thumbnail_20240305184631.jpeg")), logo: Optional(LaunchLog.ImageLabel(image_url: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/national2520aeronautics2520and2520space2520administration_logo_20190207032448.png", thumbnail_url: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/255bauto255d__image_thumbnail_20240305185043.png")), socialLogo: Optional(LaunchLog.ImageLabel(image_url: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/national2520aeronautics2520and2520space2520administration_nation_20230803040809.jpg", thumbnail_url: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/255bauto255d__image_thumbnail_20240305184823.jpeg"))))), launchCrew: [LaunchLog.CrewMember(role: LaunchLog.Role(role: "Commander"), astronaut: LaunchLog.Astronaut(id: 129, age: 80, name: "Henry \'Hank\' Hartsfield", bio: "Henry Warren \"Hank\" Hartsfield Jr. was a United States Air Force officer and a USAF and NASA astronaut who logged over 480 hours in space. Hartsfield became a NASA astronaut in September 1969. Hartsfield was the pilot on STS-4, the fourth and final orbital test flight of the shuttle Columbia.", status: LaunchLog.NamedLabel(name: "Deceased"), agency: LaunchLog.Agency(id: 44, featured: nil, name: "National Aeronautics and Space Administration", abbrev: "NASA", type: LaunchLog.NamedLabel(name: "Government"), countries: [Country(name: "United States of America", national: "American")], description: nil, administrator: nil, foundingYear: nil, image: nil, logo: nil, socialLogo: nil), image: LaunchLog.ImageLabel(image_url: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/henry25202527hank25272520hartsfield_image_20181129203753.jpg", thumbnail_url: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/255bauto255d__image_thumbnail_20240305185432.jpeg"), type: LaunchLog.NamedLabel(name: "Government"), inSpace: false, dob: "1933-11-21", lastFlight: "1985-10-30T17:00:00Z", firstFlight: "1982-06-27T15:00:00Z", dod: Optional("2014-07-14"), nationality: [LaunchLog.Country(name: "United States of America", national: "American")])), LaunchLog.CrewMember(role: LaunchLog.Role(role: "Pilot"), astronaut: LaunchLog.Astronaut(id: 341, age: 67, name: "Steven R. Nagel", bio: "Steven Ray Nagel was an American astronaut, aeronautical and mechanical engineer, test pilot, and a United States Air Force pilot.", status: LaunchLog.NamedLabel(name: "Deceased"), agency: LaunchLog.Agency(id: 44, featured: nil, name: "National Aeronautics and Space Administration", abbrev: "NASA", type: LaunchLog.NamedLabel(name: "Government"), countries:[Country(name: "United States of America", national: "American")], description: nil, administrator: nil, foundingYear: nil, image: nil, logo: nil, socialLogo: nil), image: LaunchLog.ImageLabel(image_url: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/steven2520r.2520nagel_image_20190426143717.jpeg", thumbnail_url: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/255bauto255d__image_thumbnail_20240305190002.jpeg"), type: LaunchLog.NamedLabel(name: "Government"), inSpace: false, dob: "1946-10-27", lastFlight: "1993-04-26T14:50:00Z", firstFlight: "1985-06-17T11:33:00Z", dod: Optional("2014-08-21"), nationality: [LaunchLog.Country(name: "United States of America", national: "American")])), LaunchLog.CrewMember(role: LaunchLog.Role(role: "Payload Specialist"), astronaut: LaunchLog.Astronaut(id: 197, age: 79, name: "Ernst Messerschmid", bio: "Ernst Willi Messerschmid (born May 21, 1945) is a German physicist and former astronaut.\r\nFrom 1978 to 1982, he worked at the DFVLR (the precursor of the DLR) in the Institute of Communications Technology in Oberpfaffenhofen on space-borne communications. In 1983, he was selected as one of the astronauts for the first German Spacelab mission D-1. He flew as payload specialist on STS-61-A in 1985, spending over 168 hours in space.", status: LaunchLog.NamedLabel(name: "Retired"), agency: LaunchLog.Agency(id: 29, featured: nil, name: "German Aerospace Center", abbrev: "DLR", type: LaunchLog.NamedLabel(name: "Government"), countries: [Country(name: "United States of America", national: "American")], description: nil, administrator: nil, foundingYear: nil, image: nil, logo: nil, socialLogo: nil), image: LaunchLog.ImageLabel(image_url: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/ernst2520messerschmid_image_20181201175413.jpg", thumbnail_url: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/255bauto255d__image_thumbnail_20240305185837.jpeg"), type: LaunchLog.NamedLabel(name: "Government"), inSpace: false, dob: "1945-05-21", lastFlight: "1985-10-30T17:00:00Z", firstFlight: "1985-10-30T17:00:00Z", dod: nil, nationality: [LaunchLog.Country(name: "Germany", national: "German")])), LaunchLog.CrewMember(role: LaunchLog.Role(role: "Payload Specialist"), astronaut: LaunchLog.Astronaut(id: 109, age: 54, name: "Reinhard Furrer", bio: "Prof. Dr. Reinhard Alfred Furrer (25 November 1940 – 9 September 1995) was a German physicist and astronaut.\r\n\r\nIn 1977 Furrer applied for selection as an astronaut for the first Spacelab mission. He made it into the final round of candidates, although Ulf Merbold was finally selected. In 1982, the astronauts for the first German Spacelab mission were selected from the finalists for the first mission, and Furrer was one of the two chosen. He was a payload specialist on STS-61-A (D1), which was launched on 30 October 1985. The other payload specialists on the flight were Ernst Messerschmid and Wubbo Ockels (Netherlands).", status: LaunchLog.NamedLabel(name: "Deceased"), agency: LaunchLog.Agency(id: 29, featured: nil, name: "German Aerospace Center", abbrev: "DLR", type: LaunchLog.NamedLabel(name: "Government"), countries: [Country(name: "United States of America", national: "American")], description: nil, administrator: nil, foundingYear: nil, image: nil, logo: nil, socialLogo: nil), image: LaunchLog.ImageLabel(image_url: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/reinhard2520furrer_image_20181128231842.jpg", thumbnail_url: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/255bauto255d__image_thumbnail_20240305185627.jpeg"), type: LaunchLog.NamedLabel(name: "Government"), inSpace: false, dob: "1940-11-25", lastFlight: "1985-10-30T17:00:00Z", firstFlight: "1985-10-30T17:00:00Z", dod: Optional("1995-09-09"), nationality: [LaunchLog.Country(name: "Germany", national: "German")])), LaunchLog.CrewMember(role: LaunchLog.Role(role: "Payload Specialist"), astronaut: LaunchLog.Astronaut(id: 213, age: 68, name: "Wubbo Ockels", bio: "Dr Wubbo Johannes Ockels (28 March 1946 – 18 May 2014) was a Dutch physicist and an astronaut of the European Space Agency (ESA). In 1985 he participated in a flight on the Space Shuttle Challenger, STS-61-A, making him the first Dutch citizen in space.", status: LaunchLog.NamedLabel(name: "Deceased"), agency: LaunchLog.Agency(id: 27, featured: nil, name: "European Space Agency", abbrev: "ESA", type: LaunchLog.NamedLabel(name: "Multinational"), countries: [Country(name: "United States of America", national: "American")], description: nil, administrator: nil, foundingYear: nil, image: nil, logo: nil, socialLogo: nil), image: LaunchLog.ImageLabel(image_url: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/wubbo2520ockels_image_20181201184140.jpg", thumbnail_url: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/255bauto255d__image_thumbnail_20240305191144.jpeg"), type: LaunchLog.NamedLabel(name: "Government"), inSpace: false, dob: "1946-03-28", lastFlight: "1985-10-30T17:00:00Z", firstFlight: "1985-10-30T17:00:00Z", dod: Optional("2014-05-18"), nationality: [LaunchLog.Country(name: "Netherlands", national: "Dutch")])), LaunchLog.CrewMember(role: LaunchLog.Role(role: "Mission Specialist"), astronaut: LaunchLog.Astronaut(id: 347, age: 81, name: "Guion Bluford", bio: "Guion Stewart Bluford Jr., Ph.D. is an American aerospace engineer, retired U.S. Air Force officer and fighter pilot, and former NASA astronaut, who was the first African American in space.[1] Before becoming an astronaut, he was an officer in the U.S. Air Force, where he remained while assigned to NASA, rising to the rank of Colonel. He participated in four Space Shuttle flights between 1983 and 1992. In 1983, as a member of the crew of the Orbiter Challenger on the mission STS-8, he became the first African American in space as well as the second person of African ancestry in space, after Cuban cosmonaut Arnaldo Tamayo Méndez.", status: LaunchLog.NamedLabel(name: "Retired"), agency: LaunchLog.Agency(id: 44, featured: nil, name: "National Aeronautics and Space Administration", abbrev: "NASA", type: LaunchLog.NamedLabel(name: "Government"), countries: [Country(name: "United States of America", national: "American")], description: nil, administrator: nil, foundingYear: nil, image: nil, logo: nil, socialLogo: nil), image: LaunchLog.ImageLabel(image_url: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/guion_bluford_image_20220911033859.jpeg", thumbnail_url: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/255bauto255d__image_thumbnail_20240305190945.jpeg"), type: LaunchLog.NamedLabel(name: "Government"), inSpace: false, dob: "1942-11-22", lastFlight: "1992-12-02T13:24:00Z", firstFlight: "1983-08-30T06:32:00Z", dod: nil, nationality: [LaunchLog.Country(name: "United States of America", national: "American")])), LaunchLog.CrewMember(role: LaunchLog.Role(role: "Mission Specialist"), astronaut: LaunchLog.Astronaut(id: 348, age: 79, name: "James Buchli", bio: "James Frederick Buchli is a retired United States Marine aviator and former NASA astronaut who flew on four Space Shuttle missions.", status: LaunchLog.NamedLabel(name: "Retired"), agency: LaunchLog.Agency(id: 44, featured: nil, name: "National Aeronautics and Space Administration", abbrev: "NASA", type: LaunchLog.NamedLabel(name: "Government"), countries: [Country(name: "United States of America", national: "American")], description: nil, administrator: nil, foundingYear: nil, image: nil, logo: nil, socialLogo: nil), image: LaunchLog.ImageLabel(image_url: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/james2520buchli_image_20181202103808.jpg", thumbnail_url: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/255bauto255d__image_thumbnail_20240305190715.jpeg"), type: LaunchLog.NamedLabel(name: "Government"), inSpace: false, dob: "1945-06-20", lastFlight: "1991-09-12T23:11:04Z", firstFlight: "1985-01-24T19:50:00Z", dod: nil, nationality: [LaunchLog.Country(name: "United States of America", national: "American")])), LaunchLog.CrewMember(role: LaunchLog.Role(role: "Mission Specialist"), astronaut: LaunchLog.Astronaut(id: 374, age: 75, name: "Bonnie J. Dunbar", bio: "Bonnie Jeanne Dunbar is a former NASA astronaut. She retired from NASA in September 2005 then served as president and CEO of The Museum of Flight until April 2010. From January 2013 - December 2015, Dr. Dunbar lead the University of Houston\'s STEM Center (science, technology, engineering and math) and was a faculty member in the Cullen College of Engineering.[1] Currently, she is a professor of aerospace engineering at Texas A&M University and serves as Director of the Institute for Engineering Education and Innovation (IEEI), a joint entity in the Texas A&M Engineering Experiment Station (TEES) and the Dwight Look College of Engineering at Texas A&M University.", status: LaunchLog.NamedLabel(name: "Retired"), agency: LaunchLog.Agency(id: 44, featured: nil, name: "National Aeronautics and Space Administration", abbrev: "NASA", type: LaunchLog.NamedLabel(name: "Government"), countries: [Country(name: "United States of America", national: "American")], description: nil, administrator: nil, foundingYear: nil, image: nil, logo: nil, socialLogo: nil), image: LaunchLog.ImageLabel(image_url: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/bonnie2520j.2520dunbar_image_20181202120831.jpg", thumbnail_url: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/255bauto255d__image_thumbnail_20240305190626.jpeg"), type: LaunchLog.NamedLabel(name: "Government"), inSpace: false, dob: "1949-03-03", lastFlight: "1998-01-23T02:48:15Z", firstFlight: "1985-10-30T17:00:00Z", dod: nil, nationality: [LaunchLog.Country(name: "United States of America", national: "American")]))])])), mission: Mission(name: "STS-61-A", type: "Test Flight", description: "STS-61-A was the twenty-second space shuttle flight and ninth for Space Shuttle Challenger. It was a scientific spacelab mission funded entirely by West Germany. The payload operations were controlled from the German Space Operations Center as opposed to the regular NASA centers.", orbit: LaunchLog.Orbit(name: "Low Earth Orbit", celestialBody: LaunchLog.NamedLabel(name: "Earth"))), videoUrls: [LaunchLog.VideoUrl(title: "CNN Coverage of The STS-61-A Launch", description: "From October 30th 1985 CNN Covers The 22nd Space Shuttle Launch Launched at 12 (noon) The STS-61-A Crew: Commander :Henry W. Hartsfield Pilot: Steven R. Nage...", imageUrl: "https://i.ytimg.com/vi/8bxBjqvnmjM/hqdefault.jpg", urlString: "https://www.youtube.com/watch?v=8bxBjqvnmjM")])
