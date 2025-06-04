import Foundation

struct AuditLogEntry: Identifiable, Decodable {
    let id: Int
    let createdAt: String
    let user: String?
    let scenario: String?
    let kreis: String?
    let mitgliedEmail: String?
    let empfaenger: [String]?
    let type: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case timestamp
        case user
        case scenario
        case kreis
        case mitgliedEmail
        case empfaenger
        case type
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        // createdAt oder timestamp akzeptieren
        if let createdAtValue = try? container.decode(String.self, forKey: .createdAt) {
            createdAt = createdAtValue
        } else if let timestampValue = try? container.decode(String.self, forKey: .timestamp) {
            createdAt = timestampValue
        } else {
            throw DecodingError.keyNotFound(CodingKeys.createdAt, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Weder createdAt noch timestamp gefunden"))
        }
        user = try? container.decode(String.self, forKey: .user)
        scenario = try? container.decode(String.self, forKey: .scenario)
        kreis = try? container.decode(String.self, forKey: .kreis)
        mitgliedEmail = try? container.decode(String.self, forKey: .mitgliedEmail)
        empfaenger = try? container.decode([String].self, forKey: .empfaenger)
        type = try? container.decode(String.self, forKey: .type)
    }
}

extension AuditLogEntry: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(user, forKey: .user)
        try container.encodeIfPresent(scenario, forKey: .scenario)
        try container.encodeIfPresent(kreis, forKey: .kreis)
        try container.encodeIfPresent(mitgliedEmail, forKey: .mitgliedEmail)
        try container.encodeIfPresent(empfaenger, forKey: .empfaenger)
        try container.encodeIfPresent(type, forKey: .type)
    }
} 