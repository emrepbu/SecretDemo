# iOS CI/CD Pipeline Tutorial: GitHub Secrets ile Güvenli Key Yönetimi

Bu dokükenda, iOS uygulamalarında hassas bilgileri (API keys, secrets vb.) güvenli bir şekilde yönetmek için GitHub Actions ve GitHub Secrets kullanarak CI/CD pipeline kurulumunu adım adım anlatmaktadır.

## Adım Adım Kurulum

### 1. SwiftUI Projesi Oluşturma

```bash
# Xcode'da yeni proje oluşturun
- Product Name: SecretDemo
- Interface: SwiftUI
- Language: Swift
```

### 2. ContentView.swift Oluşturma

```swift
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

```

### 3. Info.plist Konfigürasyonu

Info.plist dosyanıza şu satırı ekleyin:

```xml
<key>API_KEY</key>
<string>$(API_KEY)</string>
```

### 4. Configuration File Oluşturma

Proje root dizininde `Config.xcconfig` dosyası oluşturun:

```xcconfig
// Local test için
API_KEY_VALUE = LOCAL_TEST_KEY
API_KEY = $(API_KEY_VALUE)
```
> Release için gerekli xcconfig dosyası Github Actions ile oluşturulmaktadır.
### 5. Xcode'da Configuration Dosyasını Bağlama

1. Xcode'da projenizi açın
2. Sol panelde proje adına (mavi ikon) tıklayın
3. PROJECT → SecretDemo seçin
4. Info sekmesine gidin
5. Configurations bölümünde Debug ve Release için Config dosyasını seçin

### 6. .gitignore Dosyası

```gitignore
# Configuration files with secrets
Config.xcconfig
*.xcconfig

# Xcode
*.xcodeproj/xcuserdata/
*.xcworkspace/xcuserdata/
*.xcuserstate

# Build
build/
DerivedData/
```

### 7. GitHub Repository Oluşturma

```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/SecretDemo.git
git push -u origin main
```

### 8. GitHub Secrets Ekleme

1. GitHub repository sayfasında: **Settings** → **Secrets and variables** → **Actions**
2. **"New repository secret"** butonuna tıklayın
3. Name: `API_KEY_VALUE`
4. Value: `SUPER_SECRET_KEY_12345`
5. **"Add secret"** butonuna tıklayın

### 9. GitHub Actions Workflow Oluşturma

`.github/workflows/build.yml` dosyası oluşturun:

```yaml
name: iOS Build and Release
on:
  push:
    branches: [ main ]
    tags:
      - 'v*'  # v1.0, v2.0.1 gibi tag'ler için
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: macos-latest
    permissions:
      contents: write  # Release oluşturmak için gerekli
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
    
    - name: Set up Xcode
      uses: maxim-lobanov/setup-xcode@v1
      with:
        xcode-version: latest-stable
    
    - name: Create Config file with Secret
      run: |
        echo "API_KEY = ${{ secrets.API_KEY_VALUE }}" > Config.xcconfig
        
    - name: Build iOS App
      run: |
        xcodebuild -project SecretDemo.xcodeproj \
                   -scheme SecretDemo \
                   -sdk iphonesimulator \
                   -configuration Debug \
                   -derivedDataPath ./build \
                   -xcconfig Config.xcconfig \
                   build
    
    - name: Create IPA
      run: |
        cd build/Build/Products/Debug-iphonesimulator
        mkdir Payload
        cp -R SecretDemo.app Payload/
        zip -r ../../../SecretDemo-Simulator.ipa Payload
        cd -
    
    - name: Generate Build Info
      run: |
        echo "Build Date: $(date)" > build-info.txt
        echo "Commit: ${{ github.sha }}" >> build-info.txt
        echo "Branch: ${{ github.ref_name }}" >> build-info.txt
        echo "API Key Status: Injected from GitHub Secrets" >> build-info.txt
    
    # Her push'ta otomatik release
    - name: Create Release
      if: github.event_name == 'push' && github.ref == 'refs/heads/main'
      uses: softprops/action-gh-release@v1
      with:
        tag_name: build-${{ github.run_number }}
        name: "Build #${{ github.run_number }}"
        body: |
          Automatic build from commit ${{ github.sha }}
          
          **Build Details:**
          - Branch: ${{ github.ref_name }}
          - Commit: ${{ github.sha }}
          - API Key: Injected from GitHub Secrets
          
          **Download:**
          - `SecretDemo-Simulator.ipa` - iOS Simulator build
          - `build-info.txt` - Build information
        draft: false
        prerelease: false
        files: |
          build/SecretDemo-Simulator.ipa
          build-info.txt
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Nasıl Çalışır?

### Variable Substitution Süreci

1. **Local Development**: 
   - `Config.xcconfig` dosyasında test değerleri tanımlanır
   - Xcode build sırasında `$(API_KEY_VALUE)` değişkeni çözümlenir
   - Info.plist'teki `$(API_KEY)` değeri doldurulur

2. **CI/CD Pipeline**:
   - GitHub Actions workflow tetiklenir
   - GitHub Secrets'tan `API_KEY_VALUE` alınır
   - Config.xcconfig dosyası dinamik olarak oluşturulur
   - Xcode build sırasında gerçek değer Info.plist'e yazılır

### Güvenlik Akışı

```
GitHub Secrets (Encrypted)
    ↓
GitHub Actions (Runtime)
    ↓
Config.xcconfig (Temporary)
    ↓
Xcode Build Process
    ↓
Info.plist (Compiled App)
```

## Build'i İndirme ve Test Etme

### GitHub Releases'den İndirme

1. Repository sayfasında sağ tarafta **"Releases"** bölümüne tıklayın
2. En son release'i bulun
3. Assets bölümünden `SecretDemo-Simulator.ipa` dosyasını indirin

### Simulator'a Yükleme

```bash
# ZIP'i açın
unzip SecretDemo-Simulator.ipa

# .app dosyasını Simulator'a yükleyin
xcrun simctl install booted Payload/SecretDemo.app

# Veya Finder'dan sürükle-bırak yapın
```

## 📖 İleri Okuma

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Xcode Build Configuration Files](https://developer.apple.com/documentation/xcode/build-settings-reference)
- [iOS Code Signing in CI/CD](https://docs.github.com/en/actions/deployment/deploying-xcode-applications/installing-an-apple-certificate-on-macos-runners-for-xcode-development)

---

**Not**: Bu tutorial eğitim amaçlıdır. Production ortamında daha gelişmiş güvenlik önlemleri (KeyChain, encrypted storage, certificate pinning vb.) kullanmanız önerilir.
