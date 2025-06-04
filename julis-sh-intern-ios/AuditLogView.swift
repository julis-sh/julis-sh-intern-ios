import SwiftUI

struct AuditLogView: View {
    @StateObject private var viewModel = AuditLogViewModel()
    @State private var searchText: String = ""
    @State private var selectedType: String = "Alle"
    
    let allTypes = ["Alle", "user_update", "user_create", "user_delete", "mitglied", "empfaenger"]
    
    var filteredLogs: [AuditLogEntry] {
        viewModel.logs.filter { log in
            (selectedType == "Alle" || log.type == selectedType) &&
            (searchText.isEmpty ||
                (log.user?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (log.type?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (log.scenario?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (log.kreis?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (log.mitgliedEmail?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (log.empfaenger?.joined(separator: ", ").localizedCaseInsensitiveContains(searchText) ?? false)
            )
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SectionHeader(title: "Audit-Log")
                    .padding(.top, 8)
                TextField("Suche nach User, Typ, Szenario...", text: $searchText)
                    .padding(12)
                    .background(Color("juliGrey"))
                    .cornerRadius(12)
                    .shadow(color: Color("juliBlack").opacity(0.06), radius: 4, y: 2)
                    .padding([.horizontal, .top])
                Picker("Typ", selection: $selectedType) {
                    ForEach(allTypes, id: \.self) { t in
                        Text(t.capitalized)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                if viewModel.isLoading {
                    ProgressView("Lade Audit-Log...")
                        .padding()
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(Color("juliRed"))
                        .padding()
                } else {
                    if filteredLogs.isEmpty {
                        Text("Keine Logs gefunden.")
                            .foregroundColor(Color(.label).opacity(0.5))
                            .padding()
                    } else {
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(filteredLogs) { log in
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack(alignment: .center) {
                                            Text(formatDate(log.createdAt))
                                                .font(.caption)
                                                .foregroundColor(Color(.secondaryLabel))
                                            Spacer()
                                            if let type = log.type {
                                                Text(type.uppercased())
                                                    .font(.caption2.bold())
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 4)
                                                    .background(typeBadgeColor(type))
                                                    .foregroundColor(.white)
                                                    .cornerRadius(8)
                                            }
                                        }
                                        HStack(spacing: 8) {
                                            Image(systemName: "person.fill")
                                                .foregroundColor(Color("juliTurquoise"))
                                            Text(log.user ?? "-")
                                                .font(.headline)
                                                .foregroundColor(Color(.label))
                                        }
                                        if let scenario = log.scenario {
                                            HStack(spacing: 8) {
                                                Image(systemName: "doc.text")
                                                    .foregroundColor(Color("juliYellow"))
                                                Text(scenario)
                                                    .font(.subheadline)
                                                    .foregroundColor(Color(.label))
                                            }
                                        }
                                        if let kreis = log.kreis {
                                            HStack(spacing: 8) {
                                                Image(systemName: "location")
                                                    .foregroundColor(Color("juliTurquoise"))
                                                Text(kreis)
                                                    .font(.subheadline)
                                                    .foregroundColor(Color(.label))
                                            }
                                        }
                                        if let mitglied = log.mitgliedEmail {
                                            HStack(spacing: 8) {
                                                Image(systemName: "envelope")
                                                    .foregroundColor(Color("juliYellow"))
                                                Text(mitglied)
                                                    .font(.subheadline)
                                                    .foregroundColor(Color(.label))
                                            }
                                        }
                                        if let empfaenger = log.empfaenger, !empfaenger.isEmpty {
                                            VStack(alignment: .leading, spacing: 4) {
                                                HStack(spacing: 8) {
                                                    Image(systemName: "paperplane")
                                                        .foregroundColor(Color("juliTurquoise"))
                                                    Text("Empfänger:")
                                                        .font(.subheadline.bold())
                                                        .foregroundColor(Color(.label))
                                                }
                                                ScrollView(.horizontal, showsIndicators: false) {
                                                    HStack(spacing: 6) {
                                                        ForEach(empfaenger, id: \ .self) { e in
                                                            Text(e)
                                                                .font(.caption)
                                                                .padding(6)
                                                                .background(Color("juliYellow").opacity(0.18))
                                                                .cornerRadius(6)
                                                                .foregroundColor(Color(.label))
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(Color("juliGrey"))
                                    .cornerRadius(16)
                                    .shadow(color: Color("juliBlack").opacity(0.06), radius: 8, y: 4)
                                    .overlay(Divider(), alignment: .bottom)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .background(Color("juliGrey").ignoresSafeArea())
            .navigationTitle("")
            .onAppear {
                viewModel.fetchLogs()
            }
        }
    }
    
    func formatDate(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: iso) {
            let df = DateFormatter()
            df.dateStyle = .short
            df.timeStyle = .short
            return df.string(from: date)
        }
        return iso
    }
    
    private func typeBadgeColor(_ type: String) -> Color {
        switch type {
        case "user_create": return Color("juliTurquoise")
        case "user_update": return Color("juliYellow")
        case "user_delete": return Color("juliRed")
        default: return Color.gray
        }
    }
}

#Preview {
    AuditLogView()
} 