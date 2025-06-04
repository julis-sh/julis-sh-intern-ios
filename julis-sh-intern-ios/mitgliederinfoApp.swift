//
//  julis-sh-intern-iosApp.swift
//  julis-sh-intern-ios
//
//  Created by Luca Stephan Kohls on 01.06.25.
//

import SwiftUI
import MSAL

func setupMSALLogging() {
    MSALGlobalConfig.loggerConfig.setLogCallback { (logLevel, message, containsPII) in
        // Zeige alle Logs in der Konsole an (auch mit PII für Debug-Zwecke)
        print("[MSAL][\(logLevel)] \(message)")
    }
    MSALGlobalConfig.loggerConfig.logLevel = .verbose
}

@main
struct julis-sh-intern-iosApp: App {
    init() {
        setupMSALLogging()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
