import SwiftUI
import Combine
import AVFoundation

struct InsightView: View {
    @State private var currentConversationId: UUID? // to differentiate between conversations
    // MARK: - Properties
    
    @Binding var currentPath: AppNavigationPath
    var customLoading: CustomLoadingView!
    @EnvironmentObject var settings: SharedSettings
    
    @State private var urlInput: String = ""
    @State private var customInsight: String = ""
    @State private var apiResponse = ""
    @State private var isResponseExpanded = false
    @State private var savedInsights: [VideoInsight] = []
    @State private var isLoading = false
    @State private var selectedQuestion: String = ""
    @State private var showingActionSheet = false
    @State private var videoTitle: String = ""
    @State private var videoTranscript: String = ""
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    
    @State private var chatMessages: [ChatMessage] = []
    @State private var currentMessage: String = ""
    @State private var isVideoLoaded: Bool = false
    
    let questions = [
        "What are the step-by-step instructions for replicating the process demonstrated in the video?",
        "Based on the content, provide a practical action plan.",
        "Explain this video",
        // ... (other questions)
    ]
    
    
    
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Button("New Conversation") {
                startNewConversation()
            }
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.customTeal, Color.gray]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            if !settings.termsAccepted {
                termsAndConditionsView
            } else {
                mainContentView
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    // MARK: - Subviews
    
    var termsAndConditionsView: some View {
        Button("Press here to sign the terms and conditions") {
            currentPath = .terms
        }
        .foregroundColor(.white)
        .padding()
        .background(Color.customTeal.opacity(0.7))
        .cornerRadius(10)
    }
    
    var mainContentView: some View {
        VStack(spacing: 20) {
            
            Text("VidBriefs")
                .font(.system(size: 48, weight: .heavy))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                .padding(.vertical, 20)
                .padding(.top, 40)
            
            videoInputSection
            
            Divider().background(Color.white)
            
            chatSection
        }
        .padding()
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
                .disabled(urlInput.isEmpty || customInsight.isEmpty)
            }
            
            if isLoading {
                CustomLoadingSwiftUIView()
                    .frame(width: 50, height: 50)
            }
        }
        .padding(.top, 60)
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
    
    // MARK: - Methods
    
    func loadVideo() {
        isLoading = true
        APIManager.GetTranscript(yt_url: urlInput) { success, transcript in
            DispatchQueue.main.async {
                isLoading = false
                if success, let transcript = transcript {
                    videoTranscript = transcript
                    isVideoLoaded = true
                    APIManager.ConversationHistory.addAssistantMessage("Video transcript loaded successfully. How can I help you with this video?", forConversation: currentConversationId ?? UUID())
                    chatMessages.append(ChatMessage(content: "Video loaded successfully. How can I help you with this video?", isUser: false))
                    // TODO: [ ] CHATGPT SAYS TO ACTUALLY LOAD THE TRANSCRIPT INTO THE CONVERSATIONHISTORY NOW?
                } else {
                    chatMessages.append(ChatMessage(content: "Failed to load video. Please check the URL and try again.", isUser: false))
                }
            }
        }
    }
    
    func startNewConversation() {
        currentConversationId = APIManager.ConversationHistory.createNewConversation()
        chatMessages.removeAll()
        isVideoLoaded = false
        videoTranscript = ""
        urlInput = ""
        print("Started a new conversation with ID: \(currentConversationId!)") // debugging
    }
    
    func askQuestion() {
        isLoading = true
        guard let conversationId = currentConversationId else {
            print("Error: currentConversationId is nil.")
            return
        }
        print("Asking question with conversation ID: \(conversationId)")

        APIManager.handleCustomInsightAll(url: urlInput, source: .youtube, userPrompt: customInsight) { success, response in
            DispatchQueue.main.async {
                isLoading = false
                if success, let response = response {
                    print("Received response: \(response)")
                    APIManager.ConversationHistory.addUserMessage(customInsight, forConversation: conversationId)
                    APIManager.ConversationHistory.addAssistantMessage(response, forConversation: conversationId)
                    chatMessages.append(ChatMessage(content: customInsight, isUser: true))
                    chatMessages.append(ChatMessage(content: response, isUser: false))
                    customInsight = ""
                } else {
                    print("Failed to get insight. API call was not successful.")
                    chatMessages.append(ChatMessage(content: "Failed to get insight. Please try again.", isUser: false))
                }
            }
        }
    }
    
    func sendMessage() {
        guard let id = currentConversationId else {
            // If there's no current conversation, start a new one
            startNewConversation()
            return
        }
        
        let userMessage = currentMessage
        APIManager.ConversationHistory.addUserMessage(userMessage, forConversation: id)
        chatMessages.append(ChatMessage(content: userMessage, isUser: true))
        currentMessage = ""
        
        APIManager.chatWithGPT(message: userMessage, conversationId: id) { response in
            DispatchQueue.main.async {
                if let response = response {
                    APIManager.ConversationHistory.addAssistantMessage(response, forConversation: id)
                    chatMessages.append(ChatMessage(content: response, isUser: false))
                    saveConversation()
                } else {
                    chatMessages.append(ChatMessage(content: "Sorry, I couldn't process that request. Please try again.", isUser: false))
                }
            }
        }
    }
    
    func saveConversation() {
        let title = "Conversation about \(urlInput.isEmpty ? "General Topic" : urlInput)"
        let insight = chatMessages.map { $0.isUser ? "User: \($0.content)" : "AI: \($0.content)" }.joined(separator: "\n")
        let newInsight = VideoInsight(title: title, insight: insight)
        
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
    
    func clearChat() {
        chatMessages.removeAll()
        APIManager.ConversationHistory.clear()
    }
    
    func speak(text: String) {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        } else {
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            speechSynthesizer.speak(utterance)
        }
    }
}

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let isUser: Bool
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id && lhs.content == rhs.content && lhs.isUser == rhs.isUser
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

struct InsightView_Previews: PreviewProvider {
    static var previews: some View {
        let settings = SharedSettings()
        InsightView(currentPath: .constant(.root))
            .environmentObject(settings)
    }
}
