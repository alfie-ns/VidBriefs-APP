import SwiftUI
import Foundation
import KeychainSwift

func fetchOpenAIKey() -> String? {
    return ProcessInfo.processInfo.environment["openai-apikey"]
}

class AppEnvironment: ObservableObject {
    @Published var shouldRestart: Bool = false
}

@main
struct Youtube_SummarizerApp: App {
    @StateObject var settings = SharedSettings()
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
            AppNavigation()
                .environmentObject(settings)
                .environmentObject(appEnvironment)
        }
    }
}
