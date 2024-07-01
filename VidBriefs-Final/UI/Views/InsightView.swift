//
//  InsightView.swift
//  Youtube-Summarizer
//
//  Created by Alfie Nurse on 02/09/2023.
//

import SwiftUI
import Combine
import AVFoundation

struct InsightView: View {

    // MARK: - Properties ---------------------------------------------------------------------------------------------------------------------------------------------------

    // Navigation and Environment
    @Binding var currentPath: AppNavigationPath // Binding to the current path of app's navigation
    @EnvironmentObject var settings: SharedSettings // Environment shared settings object
    @Environment(\.presentationMode) var presentationMode // Environment variable for presentation mode, to dismiss views by swiping down

    // Video Input and Processing
    @State private var urlInput: String = ""
    @State private var videoTitle: String = ""
    @State private var videoTranscript: String = ""
    @State private var isVideoLoaded: Bool = false
    @State private var isLoading = false

    // Chat and Conversation
    @State private var chatMessages: [ChatMessage] = [] // Chat messages as an array of ChatMessage objects
    @State private var currentMessage: String = "" // Current message being sent
    @State private var currentConversationId: UUID?
    @State private var existingConversation: VideoInsight?

    // Insights and API: API Response and Summarisations
    @State private var customInsight: String = ""
    @State private var apiResponse = ""
    @State private var isResponseExpanded = false
    @State private var selectedQuestion: String = ""

    // UI Control; 
    @State private var showingActionSheet = false

    // Speech Synthesis: Text-to-Speech
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @State private var isSpeaking = false
    @State private var speechRate: Float = 0.5

    // Text Highlighting
    @State private var highlightedWords: [String] = []
    @State private var isHighlighting: Bool = false

    // Summary Customisation
    @State private var summaryLength: String = "medium"
    @State private var summaryStyle: String = "neutral"
    @State private var includeKeyPoints: Bool = false
    @State private var showingCustomizationSheet = false
    
    // MARK: - Body ---------------------------------------------------------------------------------------------------------------------------------------------------
    
    // function to initialise the VideoInsight object
    init(currentPath: Binding<AppNavigationPath>, existingConversation: VideoInsight? = nil) {
        // Initialise the currentPath binding
        self._currentPath = currentPath 
        
        // Initialize the existingConversation state variable
        // If nil is passed, it will create a State with nil value:
        self._existingConversation = State(initialValue: existingConversation)
        
        // If an existing conversation is provided, initialize other state variables
        if let conversation = existingConversation {
            // Set the URL input to the conversation title, removing the "Conversation about " prefix
            _urlInput = State(initialValue: conversation.title.replacingOccurrences(of: "Conversation about ", with: ""))
            
            // Initialize chat messages with the existing conversation's messages
            _chatMessages = State(initialValue: conversation.messages)
            
            // Set the current conversation ID
            _currentConversationId = State(initialValue: conversation.id)
            
            // Mark the video as loaded since we're restoring an existing conversation
            _isVideoLoaded = State(initialValue: true)
        }
    }
    
    var body: some View {
        ZStack { // ZStack to stack the views on top of each other - e.g. background gradient, VStack, etc.
            LinearGradient( // Background gradient
                gradient: Gradient(colors: [Color.black, Color.customTeal, Color.gray]),
                startPoint: .top,    // Gradient starts from the top of the view
                endPoint: .bottom    // and transitions with top(black)->middle(customTeal)->bottom(gray)
            )
            .edgesIgnoringSafeArea(.all) // so background stretches to the edges of the screen
            // This creates a vertical gradient that transitions from black at the top, 
            // through customTeal in the middle, to gray at the bottom
            
            VStack(spacing: 20) { 
                Text("VidBriefs") // start/top of the VStack/body
                    .font(.system(size: 42, weight: .heavy))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2) // shadow effect
                    .padding(.vertical, 20)

                    .padding(.top, 20)
                
                videoInputSection // to input the video URL and load the video
                
                Divider().background(Color.white) // horizontal line (hr)
                
                speechRateControl // to ajust voice speed
                
                chatSection // to display the chat messages and input field pushed to bottom
            }
            .padding() // space around the VStack
        }
        .edgesIgnoringSafeArea(.all) // so background stretches to the edges of the screen
        .navigationBarItems(leading: backButton, trailing: newChatButton) // navigation bar items, back button and new chat button
        .onDisappear { // when the view disappears
            saveConversation() // save the conversation into background
        }
    }
    
    var backButton: some View { //
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
            Text("Back")
        }
        .foregroundColor(.white)
    }
    
    var newChatButton: some View {
        Button(action: startNewChat) {
            Text("New Chat")
        }
        .foregroundColor(.white)
    }
    
    var videoInputSection: some View { // view that's stacked on top
        VStack(spacing: 18) {
            TextField("Enter YouTube URL", text: $urlInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
            HStack {
                Button("Load Video") {
                    loadVideo()
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.customTeal)
                .cornerRadius(10)

                Button("Customise") {
                    showingCustomizationSheet = true
                }
                .padding()
                .background(Color.customTeal)
                .foregroundColor(.white)
                .cornerRadius(10)
                .sheet(isPresented: $showingCustomizationSheet) {
                    SummaryCustomisationView(
                        summaryLength: $summaryLength,
                        summaryStyle: $summaryStyle,
                        includeKeyPoints: $includeKeyPoints
                    )
                }
                

                //Button("Regenerate")
                // ...
            }
            
            if isLoading { // if the video is loading from API
                ProgressView() // show a progress view, loading spinner
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))  // style the spinner tint to white
                    .scaleEffect(1.5) // scale the spinner to 1.5x??
            }
        }
    }
    
    var chatSection: some View { // view that's stacked at the bottom
        VStack { // TOP
            ScrollViewReader { proxy in // ScrollViewReader to scroll to the bottom of the chat
                ScrollView { // ScrollView so user can scroll
                    LazyVStack { //
                        ForEach(chatMessages) { message in
                            ChatBubble(message: message, speak: speakMessage, speechRate: speechRate, highlightedWords: highlightedWords, isHighlighting: isHighlighting)
                                .id(message.id)
                        }
                    }
                }
                .onChange(of: chatMessages) { _ in
                    if let lastMessage = chatMessages.last {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            
            HStack {
                TextField("Type a message", text: $currentMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.customTeal)
                        .cornerRadius(10)
                }
                .disabled(currentMessage.isEmpty)
                
                Button(action: toggleHighlighting) {
                    Image(systemName: isHighlighting ? "highlighter" : "text.magnifyingglass")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.orange)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
    
    
    func toggleHighlighting() {
        isHighlighting.toggle()
        if isHighlighting {
            highlightedWords = extractKeywords(from: videoTranscript)
        } else {
            highlightedWords = []
        }
    }
    
    func extractKeywords(from text: String) -> [String] {
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        let commonWords = Set(["the", "a", "an", "and", "or", "but", "in", "on", "at", "to", "for", "of", "with", "by"])
        return Array(Set(words.filter { $0.count > 3 && !commonWords.contains($0.lowercased()) })).prefix(20).map { $0 }
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
    
    var speechRateControl: some View {
        VStack {
            Text("Speech Rate: \(speechRate, specifier: "%.2f")")
                .foregroundColor(.white)
            
            HStack {
                Text("Slow")
                    .foregroundColor(.white)
                Slider(value: $speechRate, in: 0.1...1.0)
                    .accentColor(.customTeal)
                Text("Fast")
                    .foregroundColor(.white)
            }
        }
        .padding()
    }
    
    func startNewChat() {
        urlInput = ""
        customInsight = ""
        chatMessages.removeAll()
        isVideoLoaded = false
        currentConversationId = nil
        videoTranscript = ""
    }
    
    func loadVideo() {
        isLoading = true
        currentConversationId = APIManager.ConversationHistory.createNewConversation()
        print("Starting new conversation with ID: \(currentConversationId?.uuidString ?? "nil")")
        
        APIManager.GetTranscript(yt_url: urlInput) { success, transcript in
            DispatchQueue.main.async {
                isLoading = false
                if success, let transcript = transcript {
                    self.videoTranscript = transcript
                    isVideoLoaded = true
                    print("Video transcript loaded successfully")
                    APIManager.ConversationHistory.addSystemMessage("The following is a transcript of the video: \(transcript)", forConversation: self.currentConversationId!)
                    chatMessages.append(ChatMessage(content: "Video loaded successfully. How can I help you with this video?", isUser: false))
                } else {
                    print("Failed to load video transcript")
                    chatMessages.append(ChatMessage(content: "Failed to load video. Please check the URL and try again.", isUser: false))
                }
            }
        }
    }
    
    func askQuestion() {
        isLoading = true
        APIManager.handleCustomInsightAll(url: urlInput, source: .youtube, userPrompt: customInsight) { success, response in
            DispatchQueue.main.async {
                isLoading = false
                if success, let response = response {
                    chatMessages.append(ChatMessage(content: customInsight, isUser: true))
                    chatMessages.append(ChatMessage(content: response, isUser: false))
                    customInsight = ""
                } else {
                    chatMessages.append(ChatMessage(content: "Failed to get insight. Please try again.", isUser: false))
                }
            }
        }
    }
    
    func sendMessage() {
        guard let conversationId = currentConversationId else {
            print("Error: No active conversation")
            chatMessages.append(ChatMessage(content: "Error: No active conversation. Please load a video first.", isUser: false))
            return
        }

        let customizationOptions: [String: Any] = [
            "length": summaryLength,
            "style": summaryStyle,
            "includeKeyPoints": includeKeyPoints
        ]
        
        let userMessage = currentMessage
        chatMessages.append(ChatMessage(content: userMessage, isUser: true))
        currentMessage = ""
        
        print("Sending message to GPT. ConversationId: \(conversationId)")
        
        APIManager.chatWithGPT(message: userMessage, conversationId: conversationId, customization: customizationOptions) { response in
            DispatchQueue.main.async {
                if let response = response {
                    print("Received response from GPT: \(response)")
                    self.chatMessages.append(ChatMessage(id: UUID(), content: response, isUser: false))
                    self.saveConversation()  // Save after each message
                } else {
                    print("Error: No response received from GPT")
                    self.chatMessages.append(ChatMessage(id: UUID(), content: "Sorry, I couldn't process that request. Please try again.", isUser: false))
                }
            }
        }
    }
    
    func saveConversation() {
        guard let conversationId = currentConversationId else { return }
        
        generateBriefTitle { briefTitle in
            let title = briefTitle ?? "Untitled Conversation"
            let insight = self.chatMessages.map { $0.isUser ? "User: \($0.content)" : "AI: \($0.content)" }.joined(separator: "\n")
            
            // Check if the conversation already exists
            if var savedInsights = UserDefaults.standard.data(forKey: "savedInsights"),
               var decodedInsights = try? JSONDecoder().decode([VideoInsight].self, from: savedInsights) {
                if let index = decodedInsights.firstIndex(where: { $0.id == conversationId }) {
                    // Update existing conversation
                    decodedInsights[index].title = title
                    decodedInsights[index].insight = insight
                    decodedInsights[index].messages = self.chatMessages
                } else {
                    // Add new conversation
                    let newInsight = VideoInsight(id: conversationId, title: title, insight: insight, messages: self.chatMessages)
                    decodedInsights.append(newInsight)
                }
                if let encodedInsights = try? JSONEncoder().encode(decodedInsights) {
                    UserDefaults.standard.set(encodedInsights, forKey: "savedInsights")
                }
            } else {
                // No existing conversations, create a new array
                let newInsight = VideoInsight(id: conversationId, title: title, insight: insight, messages: self.chatMessages)
                if let encodedInsight = try? JSONEncoder().encode([newInsight]) {
                    UserDefaults.standard.set(encodedInsight, forKey: "savedInsights")
                }
            }
        }
    }
    
    func generateBriefTitle(completion: @escaping (String?) -> Void) {
        let prompt = "Create a very brief title (3-5 words) for this conversation about a YouTube video: \(urlInput)"
        
        let tempConversationId = UUID()  // Create a temporary UUID
        
        let customizationOptions: [String: Any] = [
            "length": "short",
            "style": "neutral",
            "includeKeyPoints": false
        ]
        
        APIManager.chatWithGPT(message: prompt, conversationId: tempConversationId, customization: customizationOptions) { response in
            DispatchQueue.main.async {
                completion(response?.trimmingCharacters(in: .whitespacesAndNewlines))
                // Clean up the temporary conversation
                APIManager.ConversationHistory.clearConversation(tempConversationId)
            }
        }
    }
    
    struct SummaryCustomisationView: View {
        @Binding var summaryLength: String
        @Binding var summaryStyle: String
        @Binding var includeKeyPoints: Bool
        
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text("Customize Summary")
                    .font(.headline)
                
                Picker("Length", selection: $summaryLength) {
                    Text("Short").tag("short")
                    Text("Medium").tag("medium")
                    Text("Long").tag("long")
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Picker("Style", selection: $summaryStyle) {
                    Text("Formal").tag("formal")
                    Text("Neutral").tag("neutral")
                    Text("Casual").tag("casual")
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Toggle("Include Key Points", isOn: $includeKeyPoints)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
    
}

struct AttributedTextView: UIViewRepresentable {
    let attributedText: NSAttributedString

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = attributedText
    }
}



struct ChatBubble: View {
    let message: ChatMessage
    let speak: (String) -> Void
    let speechRate: Float
    let highlightedWords: [String]
    let isHighlighting: Bool

    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            VStack(alignment: .leading, spacing: 5) {
                if isHighlighting {
                    AttributedTextView(attributedText: APIManager.highlightWords(in: message.content, words: highlightedWords))
                        .padding()
                        .background(message.isUser ? Color.blue : Color.gray)
                        .cornerRadius(10)
                } else {
                    Text(message.content)
                        .padding()
                        .background(message.isUser ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
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
