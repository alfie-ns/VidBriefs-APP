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

    // Navigation and Environment
    @Binding var currentPath: AppNavigationPath
    @EnvironmentObject var settings: SharedSettings
    @Environment(\.presentationMode) var presentationMode

    // TED Talk Data
    @State private var selectedTalk: TedTalkInfo?
    @State private var talkTranscript: String = ""
    @State private var isLoading = false

    // Chat and Conversation
    @State private var tedChatMessages: [TedChatMessage] = []
    @State private var currentMessage: String = ""
    @State private var currentTedConversationId: UUID?

    // Speech Synthesis
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @State private var isSpeaking = false
    @State private var speechRate: Float = 0.5

    // UI Control
    @State private var showingTalkPicker = false

    // MARK: - Body

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.red.opacity(0.8)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("TED Talks Insights")
                    .font(.system(size: 42, weight: .heavy))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                    .padding(.vertical, 20)

                talkSelectionSection

                Divider().background(Color.white)

                speechRateControl

                tedChatSection
            }
            .padding()
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarItems(leading: backButton, trailing: newTedChatButton)
        .onDisappear {
            saveTedConversation()
        }
    }

    // MARK: - View Components

    var talkSelectionSection: some View {
        VStack(spacing: 18) {
            Button(action: {
                showingTalkPicker = true
            }) {
                Text(selectedTalk?.title ?? "Select a TED Talk")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .sheet(isPresented: $showingTalkPicker) {
                TedTalkPickerView(selectedTalk: $selectedTalk)
            }

            if let talk = selectedTalk {
                Text("Speaker: \(talk.speaker)")
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
                //.onChange(of: tedChatMessages) { _ in
                //    if let lastMessage = tedChatMessages.last {
                //        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                //    }
                //}
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
                Text("Slow")
                    .foregroundColor(.white)
                Slider(value: $speechRate, in: 0.1...1.0)
                    .accentColor(.red)
                Text("Fast")
                    .foregroundColor(.white)
            }
        }
        .padding()
    }

    // MARK: - Functions

    func startNewTedChat() {
        selectedTalk = nil
        talkTranscript = ""
        tedChatMessages.removeAll()
        currentTedConversationId = nil
    }

    func loadTalkTranscript() {
        guard let talk = selectedTalk else { return }
        isLoading = true
        // Here you would typically load the transcript from your data source
        // For this example, we'll just use a placeholder
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.talkTranscript = "This is a placeholder transcript for \(talk.title) by \(talk.speaker)."
            self.isLoading = false
            self.currentTedConversationId = UUID()
            self.tedChatMessages.append(TedChatMessage(content: "TED Talk loaded. How can I help you with insights from this talk?", isUser: false))
        }
    }

    func sendTedMessage() {
        guard let conversationId = currentTedConversationId else {
            tedChatMessages.append(TedChatMessage(content: "Error: No active conversation. Please select a TED Talk first.", isUser: false))
            return
        }

        let userMessage = currentMessage
        tedChatMessages.append(TedChatMessage(content: userMessage, isUser: true))
        currentMessage = ""

        // Here you would typically send the message to your AI model
        // For this example, we'll just echo the message
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let response = "This is a placeholder response to: \(userMessage)"
            self.tedChatMessages.append(TedChatMessage(content: response, isUser: false))
            self.saveTedConversation()
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

struct TedTalkInfo: Identifiable {
    let id = UUID()
    let title: String
    let speaker: String
}

struct TedTalkPickerView: View {
    @Binding var selectedTalk: TedTalkInfo?
    @Environment(\.presentationMode) var presentationMode

    let talks = [
        TedTalkInfo(title: "The power of vulnerability", speaker: "Brené Brown"),
        TedTalkInfo(title: "Your body language may shape who you are", speaker: "Amy Cuddy"),
        TedTalkInfo(title: "How great leaders inspire action", speaker: "Simon Sinek")
    ]

    var body: some View {
        NavigationView {
            List(talks) { talk in
                Button(action: {
                    selectedTalk = talk
                    presentationMode.wrappedValue.dismiss()
                }) {
                    VStack(alignment: .leading) {
                        Text(talk.title)
                            .font(.headline)
                        Text(talk.speaker)
                            .font(.subheadline)
                    }
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

                Button(action: {
                    speak(message.content)
                }) {
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

struct TedChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
}
