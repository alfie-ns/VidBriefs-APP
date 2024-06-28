import SwiftUI
import Combine
import AVFoundation

struct InsightView: View {
    // MARK: - Properties
    
    // Navigation
    @Binding var currentPath: AppNavigationPath
    var customLoading: CustomLoadingView!
    
    // Environment
    @EnvironmentObject var settings: SharedSettings
    
    // State variables for video input and processing
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
    
    // Text-to-speech
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    
    // New states for chat functionality
    @State private var chatMessages: [ChatMessage] = []
    @State private var currentMessage: String = ""
    @State private var isVideoLoaded: Bool = false
    
    // MARK: - Predefined Questions
    
    // List of predefined questions for video analysis
    let questions = [
        "What are the step-by-step instructions for replicating the process demonstrated in the video?",
        "Based on the content, provide a practical action plan.",
        "Explain this video",
        // ... (other questions)
    ]
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.customTeal, Color.gray]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            // Main content
            if !settings.termsAccepted {
                termsAndConditionsView
            } else {
                mainContentView
            }
        }
        .edgesIgnoringSafeArea(.all)
        .keyboardAdaptive() // Custom modifier to handle keyboard appearance
    }
    
    // MARK: - Subviews
    
    // View for accepting terms and conditions
    var termsAndConditionsView: some View {
        Button("Press here to sign the terms and conditions") {
            currentPath = .terms
        }
        .foregroundColor(.white)
        .padding()
        .background(Color.customTeal.opacity(0.7))
        .cornerRadius(10)
    }
    
    // Main content view that switches between video input and chat
    var mainContentView: some View {
        VStack {
            if !isVideoLoaded {
                videoInputView
            } else {
                chatView
            }
        }
        .padding()
    }
    
    // View for entering YouTube URL and initiating video analysis
    var videoInputView: some View {
        VStack(spacing: 20) {
            Text("YouTube Video Analyzer")
                .font(.largeTitle)
                .foregroundColor(.white)
            
            HStack {
                TextField("Enter YouTube URL", text: $urlInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                
                // Paste button for clipboard content
                Button(action: {
                    if let clipboardContent = UIPasteboard.general.string {
                        urlInput = clipboardContent
                    }
                }) {
                    Image(systemName: "doc.on.clipboard")
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            
            // Button to initiate video analysis
            Button("Analyze Video") {
                loadVideo()
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.customTeal)
            .cornerRadius(10)
            
            // Loading indicator
            if isLoading {
                CustomLoadingSwiftUIView()
                    .frame(width: 50, height: 50)
            }
        }
    }
    
    // Chat interface for interacting with the AI about the video
    var chatView: some View {
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
                    // Scroll to the bottom when a new message is added
                    if let lastMessage = chatMessages.last {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            
            Divider()
            
            // Message input area
            HStack {
                TextField("Type a message or select a question", text: $currentMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                // Send message button
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.customTeal)
                        .cornerRadius(10)
                }
                .disabled(currentMessage.isEmpty)
                
                // Predefined questions menu
                Menu {
                    ForEach(questions, id: \.self) { question in
                        Button(question) {
                            currentMessage = question
                        }
                    }
                } label: {
                    Image(systemName: "list.bullet")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.customTeal)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
    
    // MARK: - Methods
    
    // Loads the YouTube video transcript
    func loadVideo() {
        isLoading = true
        APIManager.GetTranscript(yt_url: urlInput) { success, transcript in
            DispatchQueue.main.async {
                isLoading = false
                if success, let transcript = transcript {
                    videoTranscript = transcript
                    isVideoLoaded = true
                    APIManager.ConversationHistory.clear()
                    APIManager.ConversationHistory.addAssistantMessage("Video transcript loaded successfully. How can I help you with this video?")
                    chatMessages.append(ChatMessage(content: "Video loaded successfully. How can I help you with this video?", isUser: false))
                } else {
                    chatMessages.append(ChatMessage(content: "Failed to load video. Please check the URL and try again.", isUser: false))
                }
            }
        }
    }
    
    // Sends a message to the AI and processes the response
    func sendMessage() {
        let userMessage = currentMessage
        chatMessages.append(ChatMessage(content: userMessage, isUser: true))
        currentMessage = ""
        
        APIManager.chatWithGPT(message: userMessage) { response in
            DispatchQueue.main.async {
                if let response = response {
                    chatMessages.append(ChatMessage(content: response, isUser: false))
                } else {
                    chatMessages.append(ChatMessage(content: "Sorry, I couldn't process that request. Please try again.", isUser: false))
                }
            }
        }
    }
    
    // Speaks the given text using text-to-speech
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

// MARK: - Supporting Structures

// Represents a chat message
struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
}

// Custom view for chat bubbles
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

// MARK: - Preview

struct InsightView_Previews: PreviewProvider {
    static var previews: some View {
        let settings = SharedSettings()
        InsightView(currentPath: .constant(.root))
            .environmentObject(settings)
    }
}