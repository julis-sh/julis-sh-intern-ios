//
//  ContentView.swift
//  julis-sh-intern-ios
//
//  Created by Luca Stephan Kohls on 01.06.25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var loginViewModel = LoginViewModel()
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some View {
        Group {
            if loginViewModel.isLoggedIn {
                if loginViewModel.ausgewaehlterBereich == .keine {
                    BereichDashboardView()
                        .environmentObject(loginViewModel)
                } else if loginViewModel.ausgewaehlterBereich == .lgst {
                    MainTabView()
                        .environmentObject(loginViewModel)
                } else if loginViewModel.ausgewaehlterBereich == .vorstand {
                    VorstandTabView()
                        .environmentObject(loginViewModel)
                }
            } else {
                LoginView(viewModel: loginViewModel)
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

#Preview {
    ContentView()
}
