//
//  SharedSettings.swift
//  VidBriefs-Final
//
//  Created by Alfie Nurse on 25/05/2024.
//

/*
    This file stores the shared settings of the app, including the API key and terms and conditions acceptance status.
*/

import SwiftUI
import Combine

class SharedSettings: ObservableObject {
    @Published var apiKey: String = "" // API Key
    @Published var termsAccepted: Bool { // Indicates if terms and conditions have been accepted
        didSet { // When the value is set
            UserDefaults.standard.set(termsAccepted, forKey: "termsAccepted") // Save to user defaults
        }
    }

    init() { // Initialise termsAccepted with the stored value
        self.termsAccepted = UserDefaults.standard.bool(forKey: "termsAccepted")
    }
}