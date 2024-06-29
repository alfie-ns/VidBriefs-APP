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
            
            TextField("Enter your question about the video", text: $customInsight)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            HStack {
                Button("Load Video") {
                    loadVideo()
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.customTeal)
                .cornerRadius(10)
                
                Button("Ask Question") {
                    askQuestion()
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.customTeal)
                .cornerRadius(10)
                .disabled(!isVideoLoaded || customInsight.isEmpty)
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
                    chatMessages.append(ChatMessage(content: response, isUser: false))
                    saveConversation()
                } else {
                    print("Error: No response received from GPT")
                    chatMessages.append(ChatMessage(content: "Sorry, I couldn't process that request. Please try again.", isUser: false))
                }
            }
        }
    }
    
    func saveConversation() {
        guard let conversationId = currentConversationId else { return }
        
        let title = "Conversation about \(urlInput.isEmpty ? "General Topic" : urlInput)"
        let insight = chatMessages.map { $0.isUser ? "User: \($0.content)" : "AI: \($0.content)" }.joined(separator: "\n")
        let newInsight = VideoInsight(id: conversationId, title: title, insight: insight, messages: chatMessages)
        
        if var savedInsights = UserDefaults.standard.data(forKey: "savedInsights"),
           var decodedInsights = try? JSONDecoder().decode([VideoInsight].self, from: savedInsights) {
            decodedInsights.append(newInsight)
            if let encodedInsights = try? JSONEncoder().encode(decodedInsights) {
                UserDefaults.standard.set(encodedInsights, forKey: "savedInsights")
            }
        } else {
            if let encodedInsight = try? JSONEncoder().encode([newInsight]) {
                UserDefaults.standard.set(encodedInsight, forKey: "savedInsights")
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
