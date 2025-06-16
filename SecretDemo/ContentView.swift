//
//  ContentView.swift
//  SecretDemo
//
//  Created by emre argana on 16.06.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var apiKey = ""
    @State private var showingSecret = false
    
    var body: some View {
        VStack(spacing: 30) {
            Text("GitHub Secrets Demo")
                .font(.largeTitle)
                .fontWeight(.bold)
            if showingSecret {
                VStack {
                    Text("API Key:")
                        .font(.headline)
                    Text(apiKey.isEmpty ? "Yükleniyor..." : apiKey)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .background(Color.yellow.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            
            Spacer()
            
            Button(action: {
                showingSecret.toggle()
            }) {
                Text(showingSecret ? "API Key'i Gizle" : "API Key'i Göster")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .onAppear {
            loadAPIKey()
        }
    }
    
    func loadAPIKey() {
        // Build time'da enjekte edilen değeri oku
        if let key = Bundle.main.infoDictionary?["API_KEY"] as? String {
            apiKey = key
        } else {
            apiKey = "API Key bulunamadı!"
        }
    }
}
#Preview {
    ContentView()
}
