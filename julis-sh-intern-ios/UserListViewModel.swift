import Foundation
import Combine

struct User: Identifiable, Codable {
    let id: Int
    let email: String
    let role: String
}

class UserListViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showSuccess: Bool = false
    @Published var successMessage: String = ""
    
    func fetchUsers() {
        isLoading = true
        errorMessage = nil
        APIService.shared.fetchUsers { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let users):
                    self?.users = users
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func createUser(email: String, role: String, password: String, completion: @escaping (Bool) -> Void) {
        APIService.shared.createUser(email: email, role: role, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.successMessage = "Benutzer angelegt."
                    self?.showSuccess = true
                    self?.fetchUsers()
                    completion(true)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }
    
    func updateUser(id: Int, role: String, password: String?, completion: @escaping (Bool) -> Void) {
        APIService.shared.updateUser(id: id, role: role, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.successMessage = "Benutzer gespeichert."
                    self?.showSuccess = true
                    self?.fetchUsers()
                    completion(true)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }
    
    func deleteUser(id: Int, completion: @escaping (Bool) -> Void) {
        APIService.shared.deleteUser(id: id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.successMessage = "Benutzer gelöscht."
                    self?.showSuccess = true
                    self?.fetchUsers()
                    completion(true)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }
} 