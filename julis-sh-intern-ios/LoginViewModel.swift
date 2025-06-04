import Foundation
import Combine

enum AppBereich {
    case keine
    case lgst
    case vorstand
}

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var isLoggedIn: Bool = false
    @Published var accessToken: String? = nil
    @Published var displayName: String = ""
    @Published var jobTitle: String = ""
    @Published var profileImageData: Data? = nil
    @Published var ausgewaehlterBereich: AppBereich = .keine
    @Published var userRole: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    func login() {
        self.errorMessage = nil
        self.isLoading = true
        APIService.shared.login(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let token):
                    KeychainHelper.shared.save(token: token)
                    self?.isLoggedIn = true
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func logout() {
        KeychainHelper.shared.deleteToken()
        isLoggedIn = false
    }
    
    func loadMicrosoftProfile() {
        guard let token = accessToken else { return }
        // 1. User Infos
        var request = URLRequest(url: URL(string: "https://graph.microsoft.com/v1.0/me")!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }
            DispatchQueue.main.async {
                self.displayName = json["displayName"] as? String ?? ""
                self.jobTitle = json["jobTitle"] as? String ?? ""
            }
        }.resume()
        // 2. Profilbild
        var imgRequest = URLRequest(url: URL(string: "https://graph.microsoft.com/v1.0/me/photo/$value")!)
        imgRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: imgRequest) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                self.profileImageData = data
            }
        }.resume()
    }
    
    func setUserFromBackend(_ user: [String: Any]) {
        self.userRole = (user["role"] as? String) ?? ""
    }
} 