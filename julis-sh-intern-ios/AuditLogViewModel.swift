import Foundation
import Combine

class AuditLogViewModel: ObservableObject {
    @Published var logs: [AuditLogEntry] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    func fetchLogs() {
        isLoading = true
        errorMessage = nil
        APIService.shared.fetchAuditLogs { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let logs):
                    self?.logs = logs
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
} 