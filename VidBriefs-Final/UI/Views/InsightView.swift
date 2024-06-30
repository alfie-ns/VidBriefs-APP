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
    @Binding var currentPath: AppNavigationPath
    @EnvironmentObject var settings: SharedSettings
    
    @State private var urlInput: String = ""
    @State private var customInsight: String = ""
    @State private var apiResponse = ""
    @State private var isResponseExpanded = false
    @State private var isLoading = false
    @State private var selectedQuestion: String = ""
    @State private var showingActionSheet = false
    @State private var videoTitle: String = ""
    @State private var videoTranscript: String = ""
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    
    @State private var chatMessages: [ChatMessage] = []
    @State private var currentMessage: String = ""
    @State private var isVideoLoaded: Bool = false
    @State private var existingConversation: VideoInsight?
    
    @State private var currentConversationId: UUID?
    
    @Environment(\.presentationMode) var presentationMode
    
    init(currentPath: Binding<AppNavigationPath>, existingConversation: VideoInsight? = nil) {
        self._currentPath = currentPath
        self._existingConversation = State(initialValue: existingConversation)
        
        if let conversation = existingConversation {
            _urlInput = State(initialValue: conversation.title.replacingOccurrences(of: "Conversation about ", with: ""))
            _chatMessages = State(initialValue: conversation.messages)
            _currentConversationId = State(initialValue: conversation.id)
            _isVideoLoaded = State(initialValue: true)
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.customTeal, Color.gray]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("VidBriefs")
                    .font(.system(size: 48, weight: .heavy))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                    .padding(.vertical, 20)
                
                videoInputSection
                
                Divider().background(Color.white)
                
                chatSection
            }
            .padding()
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarItems(leading: backButton, trailing: newChatButton)
        .onDisappear {
            saveConversation()
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
    
    var newChatButton: some View {
        Button(action: startNewChat) {
            Text("New Chat")
        }
        .foregroundColor(.white)
    }
    
    var videoInputSection: some View {
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
                
            }
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
    }
    
    var chatSection: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack {
                        ForEach(chatMessages) { message in
                            ChatBubble(message: message)
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
            }
            .padding()
        }
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
        
        let userMessage = currentMessage
        chatMessages.append(ChatMessage(content: userMessage, isUser: true))
        currentMessage = ""
        
        print("Sending message to GPT. ConversationId: \(conversationId)")
        
        APIManager.chatWithGPT(message: userMessage, conversationId: conversationId) { response in
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
        
        APIManager.chatWithGPT(message: prompt, conversationId: tempConversationId) { response in
            DispatchQueue.main.async {
                completion(response?.trimmingCharacters(in: .whitespacesAndNewlines))
                // Clean up the temporary conversation
                APIManager.ConversationHistory.clearConversation(tempConversationId)
            }
        }
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            Text(message.content)
                .padding()
                .background(message.isUser ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
            if !message.isUser { Spacer() }
        }
        .padding(.horizontal)
    }
}
