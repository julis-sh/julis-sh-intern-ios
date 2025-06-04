import SwiftUI

struct VorstandTabView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel

    var body: some View {
        TabView {
            VorstandView()
                .tabItem {
                    Label("Termine", systemImage: "calendar")
                }
            VorstandTasksView()
                .tabItem {
                    Label("Aufgaben", systemImage: "checkmark.circle")
                }
            SettingsView()
                .tabItem {
                    Label("Einstellungen", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    VorstandTabView().environmentObject(LoginViewModel())
} 