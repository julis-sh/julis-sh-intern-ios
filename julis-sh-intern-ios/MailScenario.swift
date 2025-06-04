import Foundation

struct MailScenario: Identifiable, Codable, Hashable {
    var id: String { value }
    let value: String
    let label: String
} 