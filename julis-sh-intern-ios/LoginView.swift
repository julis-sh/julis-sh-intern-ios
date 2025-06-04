import SwiftUI
import UIKit

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            Color("juliGrey").ignoresSafeArea()
            VStack(spacing: 32) {
                Spacer()
                ZStack {
                    Circle()
                        .fill(Color("juliYellow"))
                        .frame(width: 120, height: 120)
                        .shadow(color: Color("juliYellow").opacity(0.25), radius: 16, y: 8)
                    Image("JuLisSHLogo")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .padding(.bottom, 8)
                Text("Mitgliederinfo")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(Color("juliBlack"))
                VStack(spacing: 20) {
                    Button(action: {
                        startMicrosoftLogin()
                    }) {
                        HStack {
                            Image(systemName: "person.crop.circle.badge.checkmark")
                            Text("Mit Microsoft anmelden")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("juliYellow"))
                        .foregroundColor(Color("juliBlack"))
                        .cornerRadius(16)
                        .shadow(color: Color("juliYellow").opacity(0.18), radius: 10, y: 4)
                    }
                    .disabled(isLoading)
                    if isLoading {
                        ProgressView()
                    }
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(Color("juliRed"))
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.98))
                .cornerRadius(24)
                .shadow(color: Color("juliBlack").opacity(0.06), radius: 16, y: 8)
                Spacer()
                Text("© Junge Liberale Schleswig-Holstein")
                    .font(.footnote)
                    .foregroundColor(Color("juliBlack").opacity(0.5))
            }
            .padding(.horizontal, 24)
        }
    }
    
    func startMicrosoftLogin() {
        isLoading = true
        errorMessage = nil
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            errorMessage = "Kein Window gefunden."; isLoading = false; return
        }
        MicrosoftAuthManager.shared.signIn(presentationAnchor: window) { accessToken, idToken in
            guard let msAccessToken = accessToken, let msIdToken = idToken else {
                if let msalError = MicrosoftAuthManager.shared.lastError {
                    errorMessage = "Microsoft-Login fehlgeschlagen: \(msalError.localizedDescription)"
                } else {
                    errorMessage = "Microsoft-Login fehlgeschlagen. Unbekannter Fehler."
                }
                isLoading = false
                return
            }
            viewModel.accessToken = msAccessToken
            viewModel.loadMicrosoftProfile()
            // Sende das Token ans Backend und erhalte das App-JWT
            APIService.shared.exchangeMicrosoftToken(msToken: msIdToken) { result in
                DispatchQueue.main.async {
                    isLoading = false
                    switch result {
                    case .success(let jwt):
                        KeychainHelper.shared.save(token: jwt)
                        viewModel.isLoggedIn = true
                        // User-Info aus dem JWT extrahieren (vereinfachte Annahme: Backend gibt User-Objekt zurück)
                        if let user = APIService.shared.lastUserObject {
                            viewModel.setUserFromBackend(user)
                        }
                    case .failure(let error):
                        errorMessage = "Backend-Login fehlgeschlagen: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
}

#Preview {
    LoginView(viewModel: LoginViewModel())
} 