//
//  Models.swift
//  someScreens1
//
//  Created by andriy kruglyanko on 23.04.2025.
//
import Foundation

struct UsersResult: Codable {
    let success: Bool
    let totalPages, totalUsers, count, page: Int
    let links: Links
    let users: [User]

    enum CodingKeys: String, CodingKey {
        case success
        case totalPages
        case totalUsers
        case count, page, links, users
    }
}

extension UsersResult {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(UsersResult.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        success: Bool? = nil,
        totalPages: Int? = nil,
        totalUsers: Int? = nil,
        count: Int? = nil,
        page: Int? = nil,
        links: Links? = nil,
        users: [User]? = nil
    ) -> UsersResult {
        return UsersResult(
            success: success ?? self.success,
            totalPages: totalPages ?? self.totalPages,
            totalUsers: totalUsers ?? self.totalUsers,
            count: count ?? self.count,
            page: page ?? self.page,
            links: links ?? self.links,
            users: users ?? self.users
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Links
struct Links: Codable {
    let nextURL: String
    let prevURL: JSONNull?

    enum CodingKeys: String, CodingKey {
        case nextURL
        case prevURL
    }
}

// MARK: Links convenience initializers and mutators

extension Links {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Links.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        nextURL: String? = nil,
        prevURL: JSONNull?? = nil
    ) -> Links {
        return Links(
            nextURL: nextURL ?? self.nextURL,
            prevURL: prevURL ?? self.prevURL
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - User
struct User: Codable {
    let id: Int
    let name, email, phone, position: String
    let positionID, registration_timestamp: Int
    let photo: String

    enum CodingKeys: String, CodingKey {
        case id, name, email, phone, position
        case positionID
        case registration_timestamp
        case photo
    }
}

// MARK: User convenience initializers and mutators

extension User {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(User.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        id: Int? = nil,
        name: String? = nil,
        email: String? = nil,
        phone: String? = nil,
        position: String? = nil,
        positionID: Int? = nil,
        registration_timestamp: Int? = nil,
        photo: String? = nil
    ) -> User {
        return User(
            id: id ?? self.id,
            name: name ?? self.name,
            email: email ?? self.email,
            phone: phone ?? self.phone,
            position: position ?? self.position,
            positionID: positionID ?? self.positionID,
            registration_timestamp: registration_timestamp ?? self.registration_timestamp,
            photo: photo ?? self.photo
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Helper functions for creating encoders and decoders

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
            return true
    }

    public var hashValue: Int {
            return 0
    }

    public func hash(into hasher: inout Hasher) {
            // No-op
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if !container.decodeNil() {
                    throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
            }
    }

    public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encodeNil()
    }
}
