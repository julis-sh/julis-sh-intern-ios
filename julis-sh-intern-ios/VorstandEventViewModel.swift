import Foundation
import Combine

struct VorstandEvent: Identifiable, Codable {
    let id: String
    let subject: String
    let start: Date
    let end: Date
    let location: String?
    let bodyPreview: String?
    let isAllDay: Bool
}

class VorstandEventViewModel: ObservableObject {
    @Published var events: [VorstandEvent] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    private var cancellables = Set<AnyCancellable>()
    
    let calendarId = "AAMkAGIzNmQ2MDA1LTlkMTMtNGNiZi1iYjY2LWRlZDEzNWFiNzVmNQBGAAAAAADJ4TgkPNd9Q771_1BO6Dr1BwABqql-VSwlT5kITws8w7qPAAAAAAEGAAABqql-VSwlT5kITws8w7qPAAAGbdtUAAA="
    let calendarUser = "info@julis-sh.de"
    
    var futureEvents: [VorstandEvent] {
        let now = Date()
        return events.filter { event in
            if event.isAllDay {
                let eventDay = Calendar.current.startOfDay(for: event.end)
                let today = Calendar.current.startOfDay(for: now)
                return eventDay >= today
            } else {
                return event.end >= now
            }
        }.sorted { $0.start < $1.start }
    }
    var pastEvents: [VorstandEvent] {
        let now = Date()
        return events.filter { event in
            if event.isAllDay {
                let eventDay = Calendar.current.startOfDay(for: event.end)
                let today = Calendar.current.startOfDay(for: now)
                return eventDay < today
            } else {
                return event.end < now
            }
        }.sorted { $0.start < $1.start }
    }
    
    func fetchEvents(accessToken: String) {
        isLoading = true
        errorMessage = nil
        let urlStr = "https://graph.microsoft.com/v1.0/users/\(calendarUser)/calendars/\(calendarId)/events?$orderby=start/dateTime asc&$top=50"
        fetchAllEvents(accessToken: accessToken, urlStr: urlStr, accumulated: []) { allEvents in
            DispatchQueue.main.async {
                self.isLoading = false
                self.events = allEvents.map { e in
                    let parsedStart = parseDateWithTimeZone(dateTime: e.start.dateTime, msTimeZone: e.start.timeZone, isAllDay: e.isAllDay ?? false)
                    let parsedEnd = parseDateWithTimeZone(dateTime: e.end.dateTime, msTimeZone: e.end.timeZone, isAllDay: e.isAllDay ?? false)
                    return VorstandEvent(
                        id: e.id,
                        subject: e.subject,
                        start: parsedStart,
                        end: parsedEnd,
                        location: e.location.displayName,
                        bodyPreview: e.bodyPreview,
                        isAllDay: e.isAllDay ?? false
                    )
                }.sorted { $0.start < $1.start }
            }
        }
    }
    
    private func fetchAllEvents(accessToken: String, urlStr: String, accumulated: [GraphEvent], completion: @escaping ([GraphEvent]) -> Void) {
        guard let url = URL(string: urlStr) else {
            completion(accumulated)
            return
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion(accumulated)
                return
            }
            do {
                let decoded = try JSONDecoder().decode(GraphEventResponseWithNextLink.self, from: data)
                let allEvents = accumulated + decoded.value
                if let nextLink = decoded.nextLink {
                    self.fetchAllEvents(accessToken: accessToken, urlStr: nextLink, accumulated: allEvents, completion: completion)
                } else {
                    completion(allEvents)
                }
            } catch {
                completion(accumulated)
            }
        }.resume()
    }
}

// Hilfsstrukturen für Microsoft Graph API
struct GraphEventResponse: Codable {
    let value: [GraphEvent]
}

struct GraphEvent: Codable {
    let id: String
    let subject: String
    let start: GraphEventDateTime
    let end: GraphEventDateTime
    let location: GraphEventLocation
    let bodyPreview: String?
    let isAllDay: Bool?
}

struct GraphEventDateTime: Codable {
    let dateTime: String
    let timeZone: String
}

struct GraphEventLocation: Codable {
    let displayName: String?
}

struct GraphEventResponseWithNextLink: Codable {
    let value: [GraphEvent]
    let nextLink: String?
    private enum CodingKeys: String, CodingKey {
        case value
        case nextLink = "@odata.nextLink"
    }
}

// Hilfsfunktion: Microsoft-Zeitzone zu IANA/Olson
func msTimeZoneToIANA(_ msTz: String) -> String {
    switch msTz {
    case "W. Europe Standard Time": return "Europe/Berlin"
    case "Central Europe Standard Time": return "Europe/Budapest"
    case "UTC": return "UTC"
    // Weitere Mappings nach Bedarf ergänzen
    default: return TimeZone.current.identifier
    }
}

func parseDateWithTimeZone(dateTime: String, msTimeZone: String, isAllDay: Bool = false) -> Date {
    if isAllDay {
        let fmts = ["yyyy-MM-dd", "yyyy-MM-dd'T'HH:mm:ss", "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS"]
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        for fmt in fmts {
            formatter.dateFormat = fmt
            if let date = formatter.date(from: dateTime) {
                return date
            }
        }
    } else {
        let ianaTz = msTimeZoneToIANA(msTimeZone)
        let tz = TimeZone(identifier: ianaTz) ?? TimeZone.current
        let formatter = DateFormatter()
        formatter.timeZone = tz
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let fmts = ["yyyy-MM-dd'T'HH:mm:ss.SSSSSSS", "yyyy-MM-dd'T'HH:mm:ss"]
        for fmt in fmts {
            formatter.dateFormat = fmt
            if let date = formatter.date(from: dateTime) {
                return date
            }
        }
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.timeZone = tz
        if let date = isoFormatter.date(from: dateTime) {
            return date
        }
    }
    return Date()
} 