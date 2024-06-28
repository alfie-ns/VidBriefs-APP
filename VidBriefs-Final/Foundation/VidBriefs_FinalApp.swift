import SwiftUI
import Foundation
import KeychainSwift
/*
    Imports the essential libraries:
    - SwiftUI: For building the user interface.
    - Foundation: Provides fundamental utilities.
    - KeychainSwift: Manages secure keychain storage.

    This file acts as the entry point for the app and
    defines the main structure of the app.
*/

func fetchOpenAIKey() -> String? {
    // Fetches the OpenAI API key from the environment variables
    return ProcessInfo.processInfo.environment["openai-apikey"]
}

class AppEnvironment: ObservableObject {
    // Manages app-wide state, such as a flag to restart the app
    @Published var shouldRestart: Bool = false
}

@main
struct Youtube_SummarizerApp: App {
    // The main structure for the app, conforming to the App protocol
    @StateObject var settings = SharedSettings() // Manages shared settings across the app
    @StateObject var appEnvironment = AppEnvironment() // Holds app-level state
    let keychain = KeychainSwift() // Manages secure keychain access

    init() {
        // Initializes the app and sets up the keychain
        setupKeychain()
    }

    private func setupKeychain() {
        // Configures the keychain by fetching and storing the OpenAI API key
        if let openAIKey = fetchOpenAIKey() {
            keychain.set(openAIKey, forKey: "openai-apikey")
        }
    }

    var body: some Scene {
        // Defines the main UI scene for the app
        WindowGroup {
            AppNavigation() // Sets up the primary navigation structure
                .environmentObject(settings) // Injects shared settings into the environment
                .environmentObject(appEnvironment) // Injects app environment into the environment
        }
    }
}
