import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            UserListView()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Benutzer")
                }
            AuditLogView()
                .tabItem {
                    Image(systemName: "doc.text.magnifyingglass")
                    Text("Audit-Log")
                }
            MailView()
                .tabItem {
                    Image(systemName: "envelope.fill")
                    Text("Mail")
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Einstellungen")
                }
        }
    }
}

#Preview {
    MainTabView()
} 