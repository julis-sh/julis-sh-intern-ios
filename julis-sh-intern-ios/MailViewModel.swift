import Foundation
import Combine

class MailViewModel: ObservableObject {
    @Published var scenarios: [MailScenario] = []
    @Published var kreise: [Kreis] = []
    @Published var selectedScenario: MailScenario?
    @Published var mitglied: [String: Any] = [:]
    @Published var isLoading: Bool = false
    @Published var isSending: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    func loadData() {
        isLoading = true
        errorMessage = nil
        let group = DispatchGroup()
        group.enter()
        APIService.shared.fetchMailScenarios { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let scenarios):
                    self?.scenarios = scenarios
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
                group.leave()
            }
        }
        group.enter()
        APIService.shared.fetchKreise { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let kreise):
                    self?.kreise = kreise
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            self.isLoading = false
        }
    }
    
    func sendMail(completion: @escaping (Bool) -> Void) {
        isSending = true
        errorMessage = nil
        successMessage = nil
        guard let scenario = selectedScenario else {
            errorMessage = "Bitte wähle ein Szenario."
            isSending = false
            completion(false)
            return
        }
        APIService.shared.sendMail(mitglied: mitglied, scenario: scenario.value) { [weak self] result in
            DispatchQueue.main.async {
                self?.isSending = false
                switch result {
                case .success:
                    self?.successMessage = "Mails erfolgreich versendet!"
                    completion(true)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }
} 