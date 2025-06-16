//
//  ContentView.swift
//  SecretDemo
//
//  Created by emre argana on 16.06.2025.
//

import SwiftUI

struct ContentView: View {
    private var apiKey: String {
        Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String ?? "API Key Not Found"
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("GitHub Secrets Demo")
                .font(.title)
                .bold()
            Text("API Key:")
                .font(.headline)
            Text(apiKey)
                .font(.body)
                .foregroundColor(.blue)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
