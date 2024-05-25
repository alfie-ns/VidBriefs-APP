//
//  SharedSettings.swift
//  VidBriefs-Final
//
//  Created by Alfie Nurse  on 25/05/2024.
//

import SwiftUI
import Combine

class SharedSettings: ObservableObject {
    @Published var apiKey: String = ""
    @Published var termsAccepted: Bool {
        didSet {
            UserDefaults.standard.set(termsAccepted, forKey: "termsAccepted")
        }
    }

    init() {
        self.termsAccepted = UserDefaults.standard.bool(forKey: "termsAccepted")
    }
}
