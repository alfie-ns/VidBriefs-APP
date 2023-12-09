//
//  VidBriefs_FinalApp.swift
//  VidBriefs-Final
//
//  Created by Alfie Nurse  on 07/11/2023.
//

import SwiftUI

class AppEnvironment: ObservableObject {
    @Published var shouldRestart: Bool = false
}

class SharedSettings: ObservableObject { // ObserveObject means to record changes in the app(if terms have been accepted)
    @Published var termsAccepted: Bool { // This property, when changed, notifies all observers for UI updates.
        didSet { // when property has been set do the following
            UserDefaults.standard.set(termsAccepted, forKey: "termsAccepted") // set bool value of termsAccepted to user defaults
        }
    }

    init() { // restore userdefaults when app is relaunched
        self.termsAccepted = UserDefaults.standard.bool(forKey: "termsAccepted") // ensure that the termsAccepted property is initialized with a value from UserDefaults
    }
}


@main // Entry point of the application.
struct Youtube_SummarizerApp: App {
    
    var settings = SharedSettings() // Instance of SharedSettings for managing app settings.
    @StateObject var appEnvironment = AppEnvironment() // StateObject for app-wide environment settings.

    var body: some Scene {
        
        WindowGroup {
            
            if appEnvironment.shouldRestart { // Display AppNavigation, attaching settings and appEnvironment as environment objects?
                
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



