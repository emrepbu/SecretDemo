//
//  SecretDemoApp.swift
//  SecretDemo
//
//  Created by emre argana on 16.06.2025.
//

import SwiftUI

@main
struct SecretDemoApp: App {
    init() {
        if let configPath = Bundle.main.path(forResource: "Secrets", ofType: "xcconfig") {
            print("Loaded config from: \(configPath)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
