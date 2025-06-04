import Foundation
import MSAL
import UIKit

class MicrosoftAuthManager {
    static let shared = MicrosoftAuthManager()
    private var applicationContext: MSALPublicClientApplication?
    
    // Werte aus Info.plist lesen
    private let clientId = Bundle.main.infoDictionary?["MSAL_CLIENT_ID"] as? String ?? ""
    private let redirectUri = Bundle.main.infoDictionary?["MSAL_REDIRECT_URI"] as? String ?? ""
    private let tenantId = Bundle.main.infoDictionary?["MSAL_TENANT_ID"] as? String ?? ""
    private var authority: String { "https://login.microsoftonline.com/\(tenantId)" }
    
    // Fehler für UI
    private(set) var lastError: Error? = nil
    
    private init() {
        do {
            let authorityURL = try MSALAADAuthority(url: URL(string: authority)!)
            let config = MSALPublicClientApplicationConfig(clientId: clientId, redirectUri: redirectUri, authority: authorityURL)
            applicationContext = try MSALPublicClientApplication(configuration: config)
            
        } catch {
            print("MSAL Init Error: \(error)")
        }
    }
    
    func signIn(presentationAnchor: UIWindow, completion: @escaping (_ accessToken: String?, _ idToken: String?) -> Void) {
        guard let appContext = applicationContext else { completion(nil, nil); return }
        let webParams = MSALWebviewParameters(authPresentationViewController: presentationAnchor.rootViewController!)
        let parameters = MSALInteractiveTokenParameters(scopes: ["User.Read"], webviewParameters: webParams)
        appContext.acquireToken(with: parameters) { (result, error) in
            if let error = error {
                print("MSAL error: \(error)")
                self.lastError = error
                completion(nil, nil)
                return
            }
            self.lastError = nil
            let accessToken = result?.accessToken
            let idToken = result?.idToken
            completion(accessToken, idToken)
        }
    }
} 
