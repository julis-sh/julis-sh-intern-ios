import SwiftUI

struct BereichDashboardView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 32) {
            // Profil-Widget
            if !loginViewModel.displayName.isEmpty || !loginViewModel.email.isEmpty {
                HStack(spacing: 16) {
                    if let data = loginViewModel.profileImageData, let img = UIImage(data: data) {
                        Image(uiImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 56, height: 56)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.accentColor, lineWidth: 2))
                    } else {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 56, height: 56)
                            .foregroundColor(.accentColor)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(loginViewModel.displayName.isEmpty ? loginViewModel.email : loginViewModel.displayName)
                            .font(.headline)
                        if !loginViewModel.jobTitle.isEmpty {
                            Text(loginViewModel.jobTitle)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            Spacer()
            Text("Bitte wähle einen Bereich")
                .font(.title).bold()
                .padding(.bottom, 16)
            bereichLGStButton()
            bereichVorstandButton()
            Spacer()
        }
        .padding()
        .background(Color("juliGrey").ignoresSafeArea())
        .alert(isPresented: $showError) {
            Alert(title: Text("Keine Berechtigung"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    @ViewBuilder
    private func bereichLGStButton() -> some View {
        if loginViewModel.userRole == "admin" || loginViewModel.userRole == "lgst" {
            Button(action: {
                loginViewModel.ausgewaehlterBereich = .lgst
            }) {
                BereichCard(title: "Landesgeschäftsstelle", color: Color("juliTurquoise"), icon: "building.2")
            }
            Text("Zugriff auf Benutzerverwaltung, Audit-Log, Mail und Einstellungen für die Landesgeschäftsstelle.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
        } else {
            Button(action: {
                errorMessage = "Du hast keine Berechtigung für die Landesgeschäftsstelle."
                showError = true
            }) {
                BereichCard(title: "Landesgeschäftsstelle", color: Color("juliTurquoise"), icon: "building.2")
            }
            Text("Zugriff auf Benutzerverwaltung, Audit-Log, Mail und Einstellungen für die Landesgeschäftsstelle.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
        }
    }
    
    @ViewBuilder
    private func bereichVorstandButton() -> some View {
        if loginViewModel.userRole == "admin" || loginViewModel.userRole == "vorstand" {
            Button(action: {
                loginViewModel.ausgewaehlterBereich = .vorstand
            }) {
                BereichCard(title: "Landesvorstand", color: Color("juliYellow"), icon: "person.3")
            }
            Text("Vorstandstermine, Aufgaben und Einstellungen für den Landesvorstand.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
        } else {
            Button(action: {
                errorMessage = "Du hast keine Berechtigung für den Landesvorstand."
                showError = true
            }) {
                BereichCard(title: "Landesvorstand", color: Color("juliYellow"), icon: "person.3")
            }
            Text("Vorstandstermine, Aufgaben und Einstellungen für den Landesvorstand.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
        }
    }
}

struct BereichCard: View {
    let title: String
    let color: Color
    let icon: String
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundColor(.white)
                .padding()
                .background(color)
                .clipShape(Circle())
            Text(title)
                .font(.title2.bold())
                .foregroundColor(Color(.label))
            Spacer()
        }
        .padding()
        .background(color.opacity(0.13))
        .cornerRadius(18)
        .shadow(color: color.opacity(0.08), radius: 8, y: 4)
    }
}

// Hilfsfunktion außerhalb der View!
private func roleLabel(_ role: String) -> String {
    switch role {
    case "admin": return "Admin"
    case "lgst": return "Landesgeschäftsstelle"
    case "vorstand": return "Landesvorstand"
    case "user": return "User"
    default: return role
    }
}

#Preview {
    BereichDashboardView().environmentObject(LoginViewModel())
} 