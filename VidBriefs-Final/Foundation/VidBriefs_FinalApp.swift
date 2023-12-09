import SwiftUI
import Foundation
import KeychainSwift

func fetchOpenAIKey() -> String? {
    return ProcessInfo.processInfo.environment["openai-apikey"]
}

class AppEnvironment: ObservableObject {
    @Published var shouldRestart: Bool = false
}

class SharedSettings: ObservableObject {
    @Published var termsAccepted: Bool {
        didSet {
            UserDefaults.standard.set(termsAccepted, forKey: "termsAccepted")
        }
    }

    init() {
        self.termsAccepted = UserDefaults.standard.bool(forKey: "termsAccepted")
    }
}

@main
struct Youtube_SummarizerApp: App {
    
    var settings = SharedSettings()
    @StateObject var appEnvironment = AppEnvironment()
    let keychain = KeychainSwift()

    init() {
        setupKeychain()
    }

    private func setupKeychain() {
        if let openAIKey = fetchOpenAIKey() {
            keychain.set(openAIKey, forKey: "openai-apikey")
        }
    }

    var body: some Scene {
        WindowGroup {
            if appEnvironment.shouldRestart {
                AppNavigation()
                    .environmentObject(settings)
                    .environmentObject(appEnvironment)
            } else {
                AppNavigation()
                    .environmentObject(settings)
                    .environmentObject(appEnvironment)
            }
        }
    }
}
