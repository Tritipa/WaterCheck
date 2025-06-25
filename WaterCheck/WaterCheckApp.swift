//
//  WaterCheckApp.swift
//  WaterCheck
//
//

import SwiftUI

@main
struct WaterCheckApp: App {
    @StateObject private var hydrationManager = HydrationManager()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                MainTabView()
                    .environmentObject(hydrationManager)
                    .preferredColorScheme(.light)
            } else {
                OnboardingView()
            }
        }
    }
}
