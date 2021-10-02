
import Foundation

// MARK: - LoginResponse
struct LoginResponse: Codable {
    let status: Bool?
    let message: String?
    let user: User?
}

// MARK: - User
struct User: Codable {
    let id, isVerified: Int?
    let firstName, lastName, countryCode, phonenumber: String?
    let dob, address: String?
    let image: Image?
    let bio: String?
    let lastLogin, gender, email, status: String?
    let verifiedAt, driver: String?
    let otp, deletedAt, createdBy: String?
    let created, modified: String?
    let documents: [Documents]?
    let cards: Cards?
    let addreses: Addreses?
    let access: Access?
    let femaleDriverOnly, spanishSpeakingOnly, flag, airportTrips, wheelChair: String?
    let contactByEmail: String?
    let languages: Languages?
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case countryCode = "country_code"
        case phonenumber, dob, address, image, bio
        case lastLogin = "last_login"
        case gender, email, status
        case isVerified = "is_verified"
        case verifiedAt = "verified_at"
        case driver, otp
        case deletedAt = "deleted_at"
        case createdBy = "created_by"
        case femaleDriverOnly = "female_driver_only"
        case spanishSpeakingOnly = "spanish_speaking_only"
        case flag
        case airportTrips = "airport_trips"
        case contactByEmail = "contact_by_email"
        case wheelChair = "wheel_chair"
        case created, modified, documents, cards, addreses, access,languages
    }
}

// MARK: - Access
struct Access: Codable {
    let id: Int?
    let token: String?
}

// MARK: - Addreses
struct Addreses: Codable {
    let id: Int?
    let userID, mailingAddress, addressLine, city: String?
    let state, zip, created, modified: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case mailingAddress = "mailing_address"
        case addressLine = "address_line"
        case city, state, zip, created, modified
    }
}

// MARK: - Document
struct Documents: Codable {
    let id: Int?
    let userID, title: String?
    let slug: Slug?
    let file, verified: String?
    let expiryDate: String?
    let created, modified: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case title, slug, file, verified
        case expiryDate = "expiry_date"
        case created, modified
    }
}

enum Slug: String, Codable {
    case drivingLicenseBack = "driving-license-back"
    case drivingLicenseFront = "driving-license-front"
    case insuranceProof = "insurance-proof"
    case vehicleRegistration = "vehicle-registration"
}

// MARK: - Image
struct Image: Codable {
    let original, large, medium, small: String?
}


// MARK: - Cards
struct Cards: Codable {
    let id: Int?
    let userID, cardName, cardNumber, cardType: String?
    let expiryDate, billingZip, created, modified: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case cardName = "card_name"
        case cardNumber = "card_number"
        case cardType = "card_type"
        case expiryDate = "expiry_date"
        case billingZip = "billing_zip"
        case created, modified
    }
}

// MARK: - Languages
struct Languages: Codable {
    let id: Int?
    let title, code: String?
    let pivot: Pivot?
}

struct Pivot: Codable {
    let userID, languageID: String?

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case languageID = "language_id"
    }
}

// MARK: - Encode/decode helpers



//// MARK: - User
//struct Usersss: Codable {
//    let id: Int?
//    let firstName, lastName, countryCode, phonenumber: String?
//    let dob, address: String?
//    let image: Imagess?
//    let bio: String?
//    let lastLogin, gender, email, status: String?
//    let verifiedAt: String?
//    let driver: String?
//    let otp, deletedAt, createdBy: String?
//    let created, modified: String?
//    let documents: Documents?
//    let cards: String?
//    let addreses: Addreses?
//    let access: Accessss?
//    let isverified: String?
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case firstName = "first_name"
//        case lastName = "last_name"
//        case countryCode = "country_code"
//        case phonenumber, dob, address, image, bio
//        case lastLogin = "last_login"
//        case gender, email, status
//        case verifiedAt = "verified_at"
//        case driver, otp
//        case deletedAt = "deleted_at"
//        case createdBy = "created_by"
//        case isverified = "is_verified"
//        case created, modified, documents, cards, addreses, access
//    }
//}
//
//// MARK: - Access
//struct Accessss: Codable {
//    let id: Int?
//    let token: String?
//}
//
//// MARK: - Addreses
//struct Addreses: Codable {
//    let id: Int?
//    let userID, mailingAddress, addressLine, city: String?
//    let state, zip, created, modified: String?
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case userID = "user_id"
//        case mailingAddress = "mailing_address"
//        case addressLine = "address_line"
//        case city, state, zip, created, modified
//    }
//}
//
//// MARK: - Documents
//struct Documents: Codable {
//    let id: Int?
//    let userID, title, slug, file: String?
//    let created, modified: String?
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case userID = "user_id"
//        case title, slug, file, created, modified
//    }
//}
//
//// MARK: - Image
//struct Imagess: Codable {
//    let original, large, medium, small: String?
//}
//
//// MARK: - Encode/decode helpers
//
////class JSONNull: Codable, Hashable {
////
////    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
////        return true
////    }
////
////    public var hashValue: Int {
////        return 0
////    }
////
////    public init() {}
////
////    public required init(from decoder: Decoder) throws {
////        let container = try decoder.singleValueContainer()
////        if !container.decodeNil() {
////            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
////        }
////    }
////
////    public func encode(to encoder: Encoder) throws {
////        var container = encoder.singleValueContainer()
////        try container.encodeNil()
////    }
////}
