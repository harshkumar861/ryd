//
//  UpdateEmailResponse.swift
//  Ryd Driver
//
//  Created by Prepladder on 01/05/21.
//  Copyright © 2021 Harsh. All rights reserved.
//


import Foundation

// MARK: - UpdateEmailResponse
struct UpdateEmailResponse: Codable {
    let status: Bool?
    let message: String?
    let user: User?
}

// MARK: - User
//struct Userssss: Codable {
//    let id: Int?
//    let firstName, lastName: String?
//    let countryCode, phonenumber: String?
//    let dob, address: String?
//    let image: Imagesss?
//    let bio: String?
//    let lastLogin: String?
//    let gender: String?
//    let email, status, isVerified: String?
//    let verifiedAt: String?
//    let driver: String?
//    let otp, deletedAt, createdBy: String?
//    let created, modified: String?
//    let documents: Documentss?
//    let cards, addreses: String?
//    let access: Accesssss?
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case firstName = "first_name"
//        case lastName = "last_name"
//        case countryCode = "country_code"
//        case phonenumber, dob, address, image, bio
//        case lastLogin = "last_login"
//        case gender, email, status
//        case isVerified = "is_verified"
//        case verifiedAt = "verified_at"
//        case driver, otp
//        case deletedAt = "deleted_at"
//        case createdBy = "created_by"
//        case created, modified, documents, cards, addreses, access
//    }
//}

// //MARK: - Access
//struct Accesssss: Codable {
//    let id: Int?
//    let token: String?
//}
//
// //MARK: - Documents
//struct Documentss: Codable {
//    let id: Int?
//    let userID, title, slug, file: String?
//    let verified: String?
//    let expiryDate: String?
//    let created, modified: String?
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case userID = "user_id"
//        case title, slug, file, verified
//        case expiryDate = "expiry_date"
//        case created, modified
//    }
//}

// //MARK: - Image
//struct Imagesss: Codable {
//    let original, large, medium, small: String?
//}

// MARK: - Encode/decode helpers

//class JSONNull: Codable, Hashable {
//
//    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
//        return true
//    }
//
//    public var hashValue: Int {
//        return 0
//    }
//
//    public init() {}
//
//    public required init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        if !container.decodeNil() {
//            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
//        }
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        try container.encodeNil()
//    }
//}
