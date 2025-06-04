import Foundation

class APIService {
    static let shared = APIService()
    private init() {}
    
    // Basis-URL aus Info.plist lesen
    private let baseURL: String = Bundle.main.infoDictionary?["API_URL"] as? String ?? "https://api.jlssrv.de/mitgliederinfo/"
    
    var lastUserObject: [String: Any]? = nil
    
    func login(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        // TODO: Implementiere echten API-Call
        // Beispiel: URLSession oder Alamofire
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            if email == "test@example.com" && password == "passwort" {
                completion(.success("fake-jwt-token"))
            } else {
                completion(.failure(NSError(domain: "Login", code: 401, userInfo: [NSLocalizedDescriptionKey: "Ungültige Zugangsdaten"])))
            }
        }
    }
    
    func createUser(email: String, role: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = KeychainHelper.shared.readToken() else {
            completion(.failure(NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Nicht eingeloggt"])))
            return
        }
        guard let url = URL(string: baseURL + "users") else {
            completion(.failure(NSError(domain: "API", code: 0, userInfo: [NSLocalizedDescriptionKey: "Ungültige URL"])))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["email": email, "role": role, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "API", code: 0, userInfo: [NSLocalizedDescriptionKey: "Keine Antwort vom Server"])))
                return
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                let msg = httpResponse.statusCode == 401 ? "Nicht autorisiert (nur Admins)" : "Serverfehler: \(httpResponse.statusCode)"
                completion(.failure(NSError(domain: "API", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: msg])))
                return
            }
            completion(.success(()))
        }.resume()
    }
    
    func updateUser(id: Int, role: String, password: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = KeychainHelper.shared.readToken() else {
            completion(.failure(NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Nicht eingeloggt"])))
            return
        }
        guard let url = URL(string: baseURL + "users/\(id)") else {
            completion(.failure(NSError(domain: "API", code: 0, userInfo: [NSLocalizedDescriptionKey: "Ungültige URL"])))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        var body: [String: Any] = ["role": role]
        if let pw = password, !pw.isEmpty { body["password"] = pw }
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "API", code: 0, userInfo: [NSLocalizedDescriptionKey: "Keine Antwort vom Server"])))
                return
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                let msg = httpResponse.statusCode == 401 ? "Nicht autorisiert (nur Admins)" : "Serverfehler: \(httpResponse.statusCode)"
                completion(.failure(NSError(domain: "API", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: msg])))
                return
            }
            completion(.success(()))
        }.resume()
    }
    
    func fetchAuditLogs(completion: @escaping (Result<[AuditLogEntry], Error>) -> Void) {
        guard let token = KeychainHelper.shared.readToken() else {
            completion(.failure(NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Nicht eingeloggt"])))
            return
        }
        guard let url = URL(string: baseURL + "auditlog") else {
            completion(.failure(NSError(domain: "API", code: 0, userInfo: [NSLocalizedDescriptionKey: "Ungültige URL"])))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "API", code: 0, userInfo: [NSLocalizedDescriptionKey: "Keine Antwort vom Server"])))
                return
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                let msg = httpResponse.statusCode == 401 ? "Nicht autorisiert (nur Admins)" : "Serverfehler: \(httpResponse.statusCode)"
                completion(.failure(NSError(domain: "API", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: msg])))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "API", code: 0, userInfo: [NSLocalizedDescriptionKey: "Keine Daten erhalten"])))
                return
            }
            do {
                let logs = try JSONDecoder().decode([AuditLogEntry].self, from: data)
                completion(.success(logs))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchMailScenarios(completion: @escaping (Result<[MailScenario], Error>) -> Void) {
        guard let token = KeychainHelper.shared.readToken() else {
            completion(.failure(NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Nicht eingeloggt"])))
            return
        }
        guard let url = URL(string: baseURL + "szenarien") else {
            completion(.failure(NSError(domain: "API", code: 0, userInfo: [NSLocalizedDescriptionKey: "Ungültige URL"])))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "API", code: 0, userInfo: [NSLocalizedDescriptionKey: "Keine Antwort vom Server"])))
                return
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                let msg = httpResponse.statusCode == 401 ? "Nicht autorisiert" : "Serverfehler: \(httpResponse.statusCode)"
                completion(.failure(NSError(domain: "API", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: msg])))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "API", code: 0, userInfo: [NSLocalizedDescriptionKey: "Keine Daten erhalten"])))
                return
            }
            do {
                let scenarios = try JSONDecoder().decode([MailScenario].self, from: data)
                completion(.success(scenarios))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchKreise(completion: @escaping (Result<[Kreis], Error>) -> Void) {
        guard let token = KeychainHelper.shared.readToken() else {
            completion(.failure(NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Nicht eingeloggt"])))
            return
        }
        guard let url = URL(string: baseURL + "kreise") else {
            completion(.failure(NSError(domain: "API", code: 0, userInfo: [NSLocalizedDescriptionKey: "Ungültige URL"])))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "API", code: 0, userInfo: [NSLocalizedDescriptionKey: "Keine Antwort vom Server"])))
                return
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                let msg = httpResponse.statusCode == 401 ? "Nicht autorisiert" : "Serverfehler: \(httpResponse.statusCode)"
                completion(.failure(NSError(domain: "API", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: msg])))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "API", code: 0, userInfo: [NSLocalizedDescriptionKey: "Keine Daten erhalten"])))
                return
            }
            do {
                let kreise = try JSONDecoder().decode([Kreis].self, from: data)
                completion(.success(kreise))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func sendMail(mitglied: [String: Any], scenario: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = KeychainHelper.shared.readToken() else {
            completion(.failure(NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Nicht eingeloggt"])))
            return
        }
        guard let url = URL(string: "https://api.jlssrv.de/mitgliederinfo/mail") else {
            completion(.failure(NSError(domain: "API", code: 0, userInfo: [NSLocalizedDescriptionKey: "Ungültige URL"])))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["mitglied": mitglied, "scenario": scenario, "attachments": []]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "API", code: 0, userInfo: [NSLocalizedDescriptionKey: "Keine Antwort vom Server"])))
                return
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                let msg = httpResponse.statusCode == 401 ? "Nicht autorisiert" : "Serverfehler: \(httpResponse.statusCode)"
                completion(.failure(NSError(domain: "API", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: msg])))
                return
            }
            completion(.success(()))
        }.resume()
    }
    
    func fetchUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        guard let token = KeychainHelper.shared.readToken() else {
            completion(.failure(NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Nicht eingeloggt"])))
            return
        }
        guard let url = URL(string: "https://api.jlssrv.de/mitgliederinfo/users") else {
            completion(.failure(NSError(domain: "API", code: 0, userInfo: [NSLocalizedDescriptionKey: "Ungültige URL"])))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "API", code: 0, userInfo: [NSLocalizedDescriptionKey: "Keine Antwort vom Server"])))
                return
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                let msg = httpResponse.statusCode == 401 ? "Nicht autorisiert (nur Admins)" : "Serverfehler: \(httpResponse.statusCode)"
                completion(.failure(NSError(domain: "API", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: msg])))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "API", code: 0, userInfo: [NSLocalizedDescriptionKey: "Keine Daten erhalten"])))
                return
            }
            do {
                let users = try JSONDecoder().decode([User].self, from: data)
                completion(.success(users))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func deleteUser(id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = KeychainHelper.shared.readToken() else {
            completion(.failure(NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Nicht eingeloggt"])))
            return
        }
        guard let url = URL(string: "https://api.jlssrv.de/mitgliederinfo/users/\(id)") else {
            completion(.failure(NSError(domain: "API", code: 0, userInfo: [NSLocalizedDescriptionKey: "Ungültige URL"])))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "API", code: 0, userInfo: [NSLocalizedDescriptionKey: "Keine Antwort vom Server"])))
                return
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                let msg = httpResponse.statusCode == 401 ? "Nicht autorisiert (nur Admins)" : "Serverfehler: \(httpResponse.statusCode)"
                completion(.failure(NSError(domain: "API", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: msg])))
                return
            }
            completion(.success(()))
        }.resume()
    }
    
    func exchangeMicrosoftToken(msToken: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://api.jlssrv.de/mitgliederinfo/auth/microsoft") else {
            completion(.failure(NSError(domain: "API", code: 0, userInfo: [NSLocalizedDescriptionKey: "Ungültige URL"])))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["token": msToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "API", code: 0, userInfo: [NSLocalizedDescriptionKey: "Keine Antwort vom Server"])))
                return
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                let msg = httpResponse.statusCode == 401 ? "Nicht autorisiert" : "Serverfehler: \(httpResponse.statusCode)"
                completion(.failure(NSError(domain: "API", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: msg])))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "API", code: 0, userInfo: [NSLocalizedDescriptionKey: "Kein Token erhalten"])))
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any], let jwt = json["token"] as? String {
                    self.lastUserObject = json["user"] as? [String: Any]
                    completion(.success(jwt))
                } else {
                    completion(.failure(NSError(domain: "API", code: 0, userInfo: [NSLocalizedDescriptionKey: "Kein Token im Response"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
} 