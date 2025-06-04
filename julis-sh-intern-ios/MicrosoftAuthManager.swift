import Foundation
import MSAL
import UIKit

class MicrosoftAuthManager {
    static let shared = MicrosoftAuthManager()
    private var applicationContext: MSALPublicClientApplication?
    
    // MSAL-Werte je nach Build-Konfiguration aus Info.plist lesen
    private static var resolvedClientId: String {
        #if DEBUG
        return Bundle.main.infoDictionary?["MSAL_CLIENT_ID_DEV"] as? String ?? Bundle.main.infoDictionary?["MSAL_CLIENT_ID"] as? String ?? ""
        #elseif TEST
        return Bundle.main.infoDictionary?["MSAL_CLIENT_ID_TEST"] as? String ?? Bundle.main.infoDictionary?["MSAL_CLIENT_ID"] as? String ?? ""
        #else
        return Bundle.main.infoDictionary?["MSAL_CLIENT_ID"] as? String ?? ""
        #endif
    }
    private static var resolvedTenantId: String {
        #if DEBUG
        return Bundle.main.infoDictionary?["MSAL_TENANT_ID_DEV"] as? String ?? Bundle.main.infoDictionary?["MSAL_TENANT_ID"] as? String ?? ""
        #elseif TEST
        return Bundle.main.infoDictionary?["MSAL_TENANT_ID_TEST"] as? String ?? Bundle.main.infoDictionary?["MSAL_TENANT_ID"] as? String ?? ""
        #else
        return Bundle.main.infoDictionary?["MSAL_TENANT_ID"] as? String ?? ""
        #endif
    }
    private static var resolvedRedirectUri: String {
        #if DEBUG
        return Bundle.main.infoDictionary?["MSAL_REDIRECT_URI_DEV"] as? String ?? Bundle.main.infoDictionary?["MSAL_REDIRECT_URI"] as? String ?? ""
        #elseif TEST
        return Bundle.main.infoDictionary?["MSAL_REDIRECT_URI_TEST"] as? String ?? Bundle.main.infoDictionary?["MSAL_REDIRECT_URI"] as? String ?? ""
        #else
        return Bundle.main.infoDictionary?["MSAL_REDIRECT_URI"] as? String ?? ""
        #endif
    }
    private var clientId: String { Self.resolvedClientId }
    private var tenantId: String { Self.resolvedTenantId }
    private var redirectUri: String { Self.resolvedRedirectUri }
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
