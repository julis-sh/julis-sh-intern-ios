import SwiftUI

struct VorstandView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    @StateObject private var eventVM = VorstandEventViewModel()
    @State private var selectedEvent: VorstandEvent? = nil
    @State private var filter: EventFilter = .all
    
    var filteredFutureEvents: [VorstandEvent] {
        switch filter {
        case .all: return eventVM.futureEvents
        case .upcoming: return eventVM.futureEvents
        case .allday: return eventVM.futureEvents.filter { $0.isAllDay }
        }
    }
    var filteredPastEvents: [VorstandEvent] {
        switch filter {
        case .all: return eventVM.pastEvents
        case .upcoming: return []
        case .allday: return eventVM.pastEvents.filter { $0.isAllDay }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SectionHeader(title: "Vorstandstermine")
                    .padding(.top, 8)
                Picker("Filter", selection: $filter) {
                    Text("Alle").tag(EventFilter.all)
                    Text("Nur zukünftige").tag(EventFilter.upcoming)
                    Text("Nur Ganztagstermine").tag(EventFilter.allday)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                if eventVM.isLoading {
                    ProgressView("Lade Termine...")
                        .padding()
                } else if let error = eventVM.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else if eventVM.events.isEmpty {
                    Text("Keine Termine gefunden.")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            if !filteredFutureEvents.isEmpty {
                                Text("Bevorstehende Termine")
                                    .font(.headline)
                                    .padding(.leading)
                                    .padding(.top, 8)
                                ForEach(filteredFutureEvents) { event in
                                    Button(action: { selectedEvent = event }) {
                                        EventRow(event: event, isPast: false)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            if !filteredPastEvents.isEmpty {
                                Text("Vergangene Termine")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                    .padding([.leading, .top])
                                ForEach(filteredPastEvents) { event in
                                    Button(action: { selectedEvent = event }) {
                                        EventRow(event: event, isPast: true)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding(.bottom, 16)
                    }
                    .refreshable {
                        if let token = loginViewModel.accessToken {
                            eventVM.fetchEvents(accessToken: token)
                        }
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
            .background(Color("juliGrey").ignoresSafeArea())
            .navigationTitle("")
            .onAppear {
                if let token = loginViewModel.accessToken {
                    eventVM.fetchEvents(accessToken: token)
                }
            }
            .sheet(item: $selectedEvent) { event in
                EventDetailView(event: event)
            }
        }
    }
}

struct EventRow: View {
    let event: VorstandEvent
    let isPast: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(event.subject)
                .font(.headline)
                .foregroundColor(isPast ? .secondary : .primary)
            if event.isAllDay {
                Text(eventDateString(event: event))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                Text(eventTimeString(event: event))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            if let location = event.location, !location.isEmpty {
                Text(location)
                    .font(.footnote.bold())
                    .foregroundColor(isPast ? .secondary : .accentColor)
            }
            if let preview = event.bodyPreview, !preview.isEmpty {
                Text(preview)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(Color(.secondarySystemBackground).opacity(isPast ? 0.7 : 1.0))
        .cornerRadius(12)
        .shadow(color: Color(.black).opacity(0.03), radius: 2, y: 1)
        .padding(.vertical, 2)
    }
    
    func eventDateString(event: VorstandEvent) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "de_DE")
        df.dateStyle = .full
        return "\(df.string(from: event.start)) · Ganztägig"
    }
    
    func eventTimeString(event: VorstandEvent) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "de_DE")
        df.dateStyle = .full
        df.timeStyle = .short
        let start = df.string(from: event.start)
        let endTime = DateFormatter.localizedString(from: event.end, dateStyle: .none, timeStyle: .short)
        return "\(start) – \(endTime) Uhr"
    }
}

struct EventDetailView: View {
    let event: VorstandEvent
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(event.subject)
                .font(.title2.bold())
            Text(event.isAllDay ? eventDateString(event: event) : eventTimeString(event: event))
                .font(.subheadline)
                .foregroundColor(.secondary)
            if let location = event.location, !location.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.accentColor)
                    Text(location)
                        .font(.body)
                }
            }
            if let preview = event.bodyPreview, !preview.isEmpty {
                Text(preview)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if let url = outlookUrl(for: event) {
                Link("Im Outlook öffnen", destination: url)
                    .font(.headline)
                    .foregroundColor(.accentColor)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    func eventDateString(event: VorstandEvent) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "de_DE")
        df.dateStyle = .full
        return "\(df.string(from: event.start)) · Ganztägig"
    }
    func eventTimeString(event: VorstandEvent) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "de_DE")
        df.dateStyle = .full
        df.timeStyle = .short
        let start = df.string(from: event.start)
        let endTime = DateFormatter.localizedString(from: event.end, dateStyle: .none, timeStyle: .short)
        return "\(start) – \(endTime) Uhr"
    }
    func outlookUrl(for event: VorstandEvent) -> URL? {
        // Placeholder: Outlook Web URL für Kalender-Event (nur wenn ID bekannt)
        // Hier ggf. anpassen, falls Event-URL im Backend/Graph verfügbar ist
        nil
    }
}

enum EventFilter: String, CaseIterable, Identifiable {
    case all, upcoming, allday
    var id: String { self.rawValue }
}

#Preview {
    VorstandView().environmentObject(LoginViewModel())
} 