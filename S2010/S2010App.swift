//
//  S2010App.swift
//  Dream Rhythm
//
//  Created by IGOR on 09/10/2025.
//

import SwiftUI

@main
struct S2010App: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView(showOnboarding: .constant(true))
                    .onReceive(NotificationCenter.default.publisher(for: .onboardingCompleted)) { _ in
                        hasCompletedOnboarding = true
                    }
            }
        }
    }
}

extension Notification.Name {
    static let onboardingCompleted = Notification.Name("onboardingCompleted")
}
