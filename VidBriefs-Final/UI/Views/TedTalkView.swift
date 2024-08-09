//
//  TedTalkView.swift
//  VidBriefs-Final
//
//  Created by Alfie Nurse  on 06/08/2024.
//

import SwiftUI
import AVFoundation

struct TedTalkView: View {
    // MARK: - Properties

    @Binding var currentPath: AppNavigationPath
    @EnvironmentObject var settings: SharedSettings
    @Environment(\.presentationMode) var presentationMode

    @State private var selectedTalk: String?
    @State private var talkTranscript: String = ""
    @State private var isLoading = false
    @State private var tedChatMessages: [TedChatMessage] = []
    @State private var currentMessage: String = ""
    @State private var currentTedConversationId: UUID?
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @State private var isSpeaking = false
    @State private var speechRate: Float = 0.5
    @State private var showingTalkPicker = false
    @State private var allTalks: [String] = []
    @State private var recommendedTalks: [String] = []

    // testing variables
    @State private var allTalksList: [String] = []
    @State private var currentTranscript: String = ""
    @State private var showingAllTalks = false
    @State private var showingTranscript = false

    // MARK: - Body

    var body: some View {
    ZStack {
        LinearGradient(gradient: Gradient(colors: [Color.black, Color.red.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)

        VStack(spacing: 20) {
            Text("TED Talks Insights")
                .font(.system(size: 42, weight: .heavy))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                .padding(.vertical, 20)

            // New buttons for API testing
            HStack(spacing: 20) {
                Button("List All Talks") {
                    listAllTalksTest()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                Button("Get Random Talk Transcript") {
                    getRandomTranscriptTest()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }

            talkSelectionSection

            Divider().background(Color.white)

            speechRateControl

            tedChatSection
        }
        .padding()
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarItems(leading: backButton, trailing: newTedChatButton)
        .onAppear(perform: loadAllTalks)
        .onDisappear(perform: saveTedConversation)
        .sheet(isPresented: $showingAllTalks) {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(allTalksList, id: \.self) { talk in
                        Text(talk)
                            .padding()
                    }
                }
            }
            .navigationTitle("All TED Talks")
        }
        .sheet(isPresented: $showingTranscript) {
            ScrollView {
                Text(currentTranscript)
                    .padding()
            }
            .navigationTitle("Random Talk Transcript")
        }
    }

    // MARK: - View Components

    var talkSelectionSection: some View {
        VStack(spacing: 18) {
            Button(action: {
                showingTalkPicker = true
            }) {
                Text(selectedTalk ?? "Select a TED Talk")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .sheet(isPresented: $showingTalkPicker) {
                TedTalkPickerView(selectedTalk: $selectedTalk, allTalks: allTalks)
            }

            if let talk = selectedTalk {
                Text("Selected Talk: \(talk)")
                    .foregroundColor(.white)
            }

            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
    }

    var tedChatSection: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack {
                        ForEach(tedChatMessages) { message in
                            TedChatBubble(message: message, speak: speakMessage, speechRate: speechRate)
                                .id(message.id)
                        }
                    }
                }
                .onChange(of: tedChatMessages) { _ in
                    if let lastMessage = tedChatMessages.last {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }

            HStack {
                TextField("Type a message", text: $currentMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: sendTedMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .disabled(currentMessage.isEmpty)
            }
            .padding()
        }
    }

    var backButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
            Text("Back")
        }
        .foregroundColor(.white)
    }

    var newTedChatButton: some View {
        Button(action: startNewTedChat) {
            Text("New Chat")
        }
        .foregroundColor(.white)
    }

    var speechRateControl: some View {
        VStack {
            Text("Speech Rate: \(speechRate, specifier: "%.2f")")
                .foregroundColor(.white)

            HStack {
                Text("Slow").foregroundColor(.white)
                Slider(value: $speechRate, in: 0.1...1.0).accentColor(.red)
                Text("Fast").foregroundColor(.white)
            }
        }
        .padding()
    }

    // MARK: - Functions

    func loadAllTalks() {
        APIManager.listAllTedTalks { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let talks):
                    self.allTalks = talks
                case .failure(let error):
                    print("Failed to load TED Talks: \(error.localizedDescription)")
                    // Handle error (e.g., show an alert to the user)
                }
            }
        }
    }

    func startNewTedChat() {
        selectedTalk = nil
        talkTranscript = ""
        tedChatMessages.removeAll()
        currentTedConversationId = nil
    }

    func sendTedMessage() {
        let userMessage = currentMessage
        tedChatMessages.append(TedChatMessage(content: userMessage, isUser: true))
        currentMessage = ""

        if selectedTalk == nil {
            if let number = Int(userMessage), number > 0 && number <= recommendedTalks.count {
                // User has selected a talk by number
                let selectedTalkTitle = recommendedTalks[number - 1]
                selectedTalk = selectedTalkTitle
                tedChatMessages.append(TedChatMessage(content: "You've selected: \(selectedTalkTitle). What would you like to know about this talk?", isUser: false))
            } else {
                // Treat as a new query if it's not a valid number
                APIManager.handleTedTalkConversation(userInput: userMessage) { response in
                    DispatchQueue.main.async {
                        self.tedChatMessages.append(TedChatMessage(content: response, isUser: false))
                        if response.contains("Based on your input, here are some TED Talks you might be interested in:") {
                            self.recommendedTalks = response.components(separatedBy: "\n")
                                .filter { $0.contains(". ") }
                                .map { $0.components(separatedBy: ". ")[1] }
                        }
                    }
                }
            }
        } else if let talk = selectedTalk {
            // Process query about the selected talk
            APIManager.getTedTalkTranscript(title: talk) { result in
                switch result {
                case .success(let transcript):
                    APIManager.chatWithGPT(message: "Based on the following TED Talk transcript, please answer the user's question: '\(userMessage)'\n\nTranscript:\n\(transcript)", conversationId: self.currentTedConversationId ?? UUID(), customization: [:]) { response in
                        DispatchQueue.main.async {
                            if let response = response {
                                self.tedChatMessages.append(TedChatMessage(content: response, isUser: false))
                            } else {
                                self.tedChatMessages.append(TedChatMessage(content: "I'm sorry, I couldn't generate a response based on the transcript.", isUser: false))
                            }
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.tedChatMessages.append(TedChatMessage(content: "I'm sorry, I couldn't fetch the transcript for this TED Talk. Error: \(error.localizedDescription)", isUser: false))
                    }
                }
            }
        }
    }

    func speakMessage(_ message: String) {
        if isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
            isSpeaking = false
        } else {
            let utterance = AVSpeechUtterance(string: message)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = speechRate
            speechSynthesizer.speak(utterance)
            isSpeaking = true
        }
    }

    func saveTedConversation() {
        // Here you would typically save the conversation to your data store
        print("Saving TED Talk conversation...")
    }
}

struct TedTalkPickerView: View {
    @Binding var selectedTalk: String?
    @Environment(\.presentationMode) var presentationMode
    let allTalks: [String]

    var body: some View {
        NavigationView {
            List(allTalks, id: \.self) { talk in
                Button(action: {
                    selectedTalk = talk
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text(talk)
                }
            }
            .navigationTitle("Select a TED Talk")
        }
    }
}

struct TedChatBubble: View {
    let message: TedChatMessage
    let speak: (String) -> Void
    let speechRate: Float

    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            VStack(alignment: .leading, spacing: 5) {
                Text(message.content)
                    .padding()
                    .background(message.isUser ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                Button(action: { speak(message.content) }) {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundColor(.white)
                }
                .padding(.leading, 10)
            }
            if !message.isUser { Spacer() }
        }
        .padding(.horizontal)
    }
}

struct TedChatMessage: Identifiable, Equatable {
    let id: UUID
    let content: String
    let isUser: Bool
    
    init(id: UUID = UUID(), content: String, isUser: Bool) {
        self.id = id
        self.content = content
        self.isUser = isUser
    }
    
    static func == (lhs: TedChatMessage, rhs: TedChatMessage) -> Bool {
        return lhs.id == rhs.id && lhs.content == rhs.content && lhs.isUser == rhs.isUser
    }
}
