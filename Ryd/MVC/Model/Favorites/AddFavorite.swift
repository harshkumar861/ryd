// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let addFavoriteResponse = try? newJSONDecoder().decode(AddFavoriteResponse.self, from: jsonData)

import Foundation

// MARK: - AddFavoriteResponse
struct AddFavoriteResponse: Codable {
    let status: Bool?
    let message: String?
    let location: Location?
}

// MARK: - Location
struct Location: Codable {
    let userID, location, lat, lng: String?
    let created, modified: String?
    let id: Int?

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case location, lat, lng, created, modified, id
    }
}
