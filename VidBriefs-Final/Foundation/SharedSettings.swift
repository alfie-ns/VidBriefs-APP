//
//  SharedSettings.swift
//  VidBriefs-Final
//
//  Created by Alfie Nurse on 25/05/2024.
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

struct ChatMessage: Identifiable, Equatable, Codable {
    let id: UUID
    let content: String
    let isUser: Bool
    
    init(id: UUID = UUID(), content: String, isUser: Bool) {
        self.id = id
        self.content = content
        self.isUser = isUser
    }
}

struct VideoInsight: Codable, Identifiable {
    let id: UUID
    var title: String
    var insight: String
    var timestamp: Date
    var messages: [ChatMessage]
    
    init(id: UUID = UUID(), title: String, insight: String, messages: [ChatMessage], timestamp: Date = Date()) {
        self.id = id
        self.title = title
        self.insight = insight
        self.timestamp = timestamp
        self.messages = messages
    }
}
