import Foundation
import Combine

struct PlannerTask: Identifiable, Codable {
    let id: String
    let title: String
    let dueDate: Date?
    let completed: Bool
}

struct ToDoTask: Identifiable, Codable {
    let id: String
    let title: String
    let dueDate: Date?
    let completed: Bool
    let listName: String
}

class VorstandTaskViewModel: ObservableObject {
    @Published var plannerTasks: [PlannerTask] = []
    @Published var todoTasks: [ToDoTask] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func fetchAllTasks(accessToken: String) {
        isLoading = true
        errorMessage = nil
        let group = DispatchGroup()
        var planner: [PlannerTask] = []
        var todos: [ToDoTask] = []
        var error: String? = nil
        // Planner Tasks
        group.enter()
        fetchPlannerTasks(accessToken: accessToken) { result in
            switch result {
            case .success(let tasks): planner = tasks
            case .failure(let err): error = err.localizedDescription
            }
            group.leave()
        }
        // To Do Tasks
        group.enter()
        fetchToDoTasks(accessToken: accessToken) { result in
            switch result {
            case .success(let tasks): todos = tasks
            case .failure(let err): error = err.localizedDescription
            }
            group.leave()
        }
        group.notify(queue: .main) {
            self.isLoading = false
            self.errorMessage = error
            self.plannerTasks = planner
            self.todoTasks = todos
        }
    }
    
    private func fetchPlannerTasks(accessToken: String, completion: @escaping (Result<[PlannerTask], Error>) -> Void) {
        guard let url = URL(string: "https://graph.microsoft.com/v1.0/me/planner/tasks") else {
            completion(.failure(NSError(domain: "API", code: 0, userInfo: [NSLocalizedDescriptionKey: "Ungültige Planner-URL"])))
            return
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { completion(.success([])); return }
            do {
                let decoded = try JSONDecoder().decode(PlannerTaskResponse.self, from: data)
                let tasks = decoded.value.map { t in
                    PlannerTask(
                        id: t.id,
                        title: t.title ?? "(Ohne Titel)",
                        dueDate: t.dueDateTime != nil ? parseGraphDate(t.dueDateTime!) : nil,
                        completed: (t.percentComplete ?? 0) == 100
                    )
                }
                completion(.success(tasks))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func fetchToDoTasks(accessToken: String, completion: @escaping (Result<[ToDoTask], Error>) -> Void) {
        guard let url = URL(string: "https://graph.microsoft.com/v1.0/me/todo/lists") else {
            completion(.failure(NSError(domain: "API", code: 0, userInfo: [NSLocalizedDescriptionKey: "Ungültige ToDo-URL"])))
            return
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { completion(.success([])); return }
            do {
                let decoded = try JSONDecoder().decode(ToDoListResponse.self, from: data)
                let group = DispatchGroup()
                var allTasks: [ToDoTask] = []
                for list in decoded.value {
                    group.enter()
                    self.fetchToDoTasksForList(accessToken: accessToken, list: list, completion: { tasks in
                        allTasks.append(contentsOf: tasks)
                        group.leave()
                    })
                }
                group.notify(queue: .main) {
                    completion(.success(allTasks))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func fetchToDoTasksForList(accessToken: String, list: ToDoList, completion: @escaping ([ToDoTask]) -> Void) {
        guard let url = URL(string: "https://graph.microsoft.com/v1.0/me/todo/lists/\(list.id)/tasks") else {
            completion([])
            return
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { completion([]); return }
            do {
                let decoded = try JSONDecoder().decode(ToDoTaskResponse.self, from: data)
                let tasks = decoded.value.map { t in
                    ToDoTask(
                        id: t.id,
                        title: t.title ?? "(Ohne Titel)",
                        dueDate: t.dueDateTime?.dateTime != nil ? parseGraphDate(t.dueDateTime!.dateTime) : nil,
                        completed: (t.status ?? "") == "completed",
                        listName: list.displayName
                    )
                }
                completion(tasks)
            } catch {
                completion([])
            }
        }.resume()
    }
}

// MARK: - Graph API Response-Structs
struct PlannerTaskResponse: Codable {
    let value: [PlannerTaskRaw]
}
struct PlannerTaskRaw: Codable {
    let id: String
    let title: String?
    let dueDateTime: String?
    let percentComplete: Int?
}

struct ToDoListResponse: Codable {
    let value: [ToDoList]
}
struct ToDoList: Codable {
    let id: String
    let displayName: String
}

struct ToDoTaskResponse: Codable {
    let value: [ToDoTaskRaw]
}
struct ToDoTaskRaw: Codable {
    let id: String
    let title: String?
    let dueDateTime: ToDoTaskDueDateTime?
    let status: String?
}
struct ToDoTaskDueDateTime: Codable {
    let dateTime: String
    let timeZone: String?
}

// Hilfsfunktion für Datum
func parseGraphDate(_ dateTime: String) -> Date? {
    let fmts = ["yyyy-MM-dd'T'HH:mm:ss.SSSSSSS", "yyyy-MM-dd'T'HH:mm:ss", "yyyy-MM-dd"]
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    for fmt in fmts {
        formatter.dateFormat = fmt
        if let date = formatter.date(from: dateTime) {
            return date
        }
    }
    return nil
} 