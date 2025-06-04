# Mitgliederinformationssystem – iOS App

> **Native SwiftUI-App für das Interne Tool der Jungen Liberalen Schleswig-Holstein e. V.**

---

## 🚀 Tech-Stack

- **Swift 5** & **SwiftUI**
- **Xcode 15** (oder neuer)
- **MVVM-Architektur**
- **Combine** (State-Management)
- **Microsoft Authentication Library (MSAL)**
- **URLSession** (API-Requests, JWT)
- **AppStorage** (Persistenz)
- **Keychain** (Token-Speicherung)
- **Apple Push Notification Service (APNs)**
- **Dark Mode** & **Custom Theme**

---

## 📦 Projektstruktur

- `julis-sh-intern-ios/` – Hauptprojekt (SwiftUI-Quellcode, Views, ViewModels, Services)
- `Assets.xcassets/` – App-Icons, Farben, Logos
- `Info.plist` – **Zentrale App-Konfiguration (API-URL, MSAL, etc.)**
- `julis-sh-intern-ios.xcodeproj/` – Xcode-Projektdatei
- `julis-sh-intern-iosTests/` & `julis-sh-intern-iosUITests/` – Tests

---

## 🛠️ Lokale Entwicklung

### Voraussetzungen

- **macOS** mit Xcode 15+
- **Apple Developer Account** (für Push, Auth ggf. erforderlich)
- Zugriff auf das interne Backend (API-URL)

### Setup

1. Repository klonen und in Xcode öffnen:
   ```bash
   git clone https://github.com/Julis-SH/mitgliederinfo-app.git
   cd ios/julis-sh-intern-ios
   open julis-sh-intern-ios.xcodeproj
   ```
2. **Bundle Identifier** & **Team** in den Projekteinstellungen anpassen (eigener Account).
3. **API-URL & MSAL-Konfiguration** in `Info.plist` pflegen (siehe unten).

### Starten im Simulator

- Zielgerät wählen (z. B. iPhone 15)
- ⌘R zum Starten

---

## ⚙️ Konfiguration & Umgebungsvariablen (Info.plist)

Alle zentralen Werte werden in der `Info.plist` gepflegt – **keine Klartext-IDs mehr im Code!**

**Beispiel-Konfiguration:**

```xml
<key>API_URL</key>
<string>API_URL</string>
<key>MSAL_CLIENT_ID</key>
<string>MSAL_CLIENT_ID</string>
<key>MSAL_TENANT_ID</key>
<string>MSAL_TENANT_ID</string>
<key>MSAL_REDIRECT_URI</key>
<string>MSAL_REDIRECIT_URI</string>
```

- **API_URL**: Basis-URL für Backend-API
- **MSAL_CLIENT_ID**: Microsoft App Client-ID
- **MSAL_TENANT_ID**: Azure Tenant-ID
- **MSAL_REDIRECT_URI**: Redirect-URI für Auth

> **Hinweis:** Die Werte werden automatisch im Code ausgelesen. Änderungen in der Info.plist wirken sofort.

---

## 📜 Nützliche Xcode-Skripte

| Shortcut | Zweck             |
| -------- | ----------------- |
| ⌘R       | App starten (Run) |
| ⌘U       | Tests ausführen   |
| ⌘⇧K      | Clean Build       |

---

## 🖌️ Design & Branding

- **JuLi-Farben**: Gelb `#FFD600`, Blau `#0033A0`, Schwarz `#231F20`
- **Font**: System (San Francisco), SwiftUI
- **Dark Mode**: Voll unterstützt

---

## 🔒 Authentifizierung

- Login via Microsoft (MSAL) & JWT
- Token-Speicherung im Keychain
- **MSAL-Konfiguration zentral in Info.plist**
- Geschützte Views via State-Management

---

## 🧪 Testing & Code-Qualität

- Unit- & UI-Tests (`julis-sh-intern-iosTests`, `julis-sh-intern-iosUITests`)
- SwiftLint empfohlen (optional)

---

## 🐳 Deployment

- Release-Build via Xcode (App Store, TestFlight oder Ad-hoc)
- CI/CD via GitHub Actions möglich (optional)

---

## 🧑‍💻 Entwickler:innen

- Siehe [GitHub Repo](https://github.com/Julis-SH/)
- Kontakt: [luca.kohls@julis-sh.de](mailto:luca.kohls@julis-sh.de)

---

**Mitmachen?** PRs & Issues willkommen! ✨
