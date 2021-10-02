// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let getFavoriteList = try? newJSONDecoder().decode(GetFavoriteList.self, from: jsonData)

import Foundation

// MARK: - GetFavoriteList
struct GetFavoriteListResponse: Codable {
    let status: Bool?
    let locations: [Locations]?
}

// MARK: - Location
struct Locations: Codable {
    let id: Int?
    let userID, location, lat, lng: String?
    let created, modified: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case location, lat, lng, created, modified
    }
}


struct DeleteFavoriteLocation :Codable {
    let status : Bool?
}
