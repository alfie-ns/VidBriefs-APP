import SwiftUI
import Combine
import AVFoundation
// SwiftUI framework is used for building modern, declarative user interfaces.
// Combine framework is used for handling asynchronous events, such as keyboard height changes.
// AVFoundation framework supports working with audiovisual assets, including playback and speech synthesis for reading out insights.

extension UIResponder { // Extends UIResponder to find and manage the current first responder
    private weak static var _currentFirstResponder: UIResponder? = nil 
    // A static weak variable to hold the current first responder. 
    // It is weak to avoid retain cycles and optional to handle the absence of a first responder.

    public static var currentFirstResponder: UIResponder? {
        // Retrieves the current first responder by setting _currentFirstResponder to nil, 
        // sending a findFirstResponder action across the app, and returning the result.
        _currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(findFirstResponder(_:)), to: nil, from: nil, for: nil)
        return _currentFirstResponder
    }

    @objc internal func findFirstResponder(_ sender: Any) {
        // '@objc' attribute enables this method to interact with Objective-C runtime for action-based callbacks.
        // 'internal' access level restricts its visibility to within the same module, ensuring it's used only internally.
        UIResponder._currentFirstResponder = self
    }
    
    var globalFrame: CGRect? {
        guard let view = self as? UIView else { return nil }
        return view.window?.convert(view.bounds, from: view)
    }
}


// Adjusts the view's layout to prevent the keyboard from covering up the content.
// The modifier dynamically adds bottom padding to shift the view up when the keyboard appears.
struct KeyboardAdaptive: ViewModifier {
    @State private var bottomPadding: CGFloat = 0 // Initial bottom padding is zero

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .padding(.bottom, self.bottomPadding) // Apply dynamic bottom padding
                .onReceive(Publishers.keyboardHeight) { keyboardHeight in 
                    // Adjust bottom padding based on the keyboard height and the position of the focused text input
                    let keyboardTop = geometry.frame(in: .global).height - keyboardHeight // Top edge of the keyboard
                    let focusedTextInputBottom = UIResponder.currentFirstResponder?.globalFrame?.maxY ?? 0 // Bottom edge of the focused text input
                    self.bottomPadding = max(0, focusedTextInputBottom - keyboardTop - geometry.safeAreaInsets.bottom) 
                    // Set bottom padding to ensure the focused input is above the keyboard
                }
                .animation(.easeOut(duration: 0.16), value: bottomPadding) // Smooth animation for padding changes
        }
    }
}

extension View { 
    // Extends the View protocol to add a keyboardAdaptive modifier.
    // This modifier adapts the view's layout dynamically when the keyboard appears, ensuring that input fields are not hidden.
    // It is particularly useful in this app to maintain a smooth user experience by keeping the input fields visible when typing.
    func keyboardAdaptive() -> some View {
        ModifiedContent(content: self, modifier: KeyboardAdaptive())
    }
}

extension Publishers { 
    // Provides a publisher that emits keyboard height changes.
    // Combines the notifications for keyboard appearance and disappearance to emit the current keyboard height.
    // Essential for this app to dynamically adjust the layout based on the keyboard height.
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { $0.keyboardHeight }

        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }

        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

extension Notification {
    // Extracts the keyboard height from the notification's userInfo.
    // Converts the keyboard frame into its height, which is used to adjust the view layout.
    // This app uses it to ensure that the bottom padding is accurately calculated based on the keyboard's position.
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}


struct InsightView: View { // The main view for generating insights from a youtube video
    
    //    @State private var isApiKeySet: Bool = UserDefaults.standard.string(forKey: "openai_apikey") != nil
    
    @Binding var currentPath: AppNavigationPath // Binding to the current navigation path
    var customLoading: CustomLoadingView! // Custom loading sign
    @EnvironmentObject var settings: SharedSettings // "terms are accepted" bool gate keepe

    
    
    @State private var urlInput: String = "" // URL input starts empty
    @State private var customInsight: String = "" // Custom message
    
    @State private var apiResponse = "" // API response starts empty
    @State private var isResponseExpanded = false // for DisclosureGroup
    @State private var savedInsights: [VideoInsight] = [] // Saved insights list starts empty
    @State private var isLoading = false // Loading state starts false
    
    @State private var selectedQuestion: String = "" // Selected question starts empty
    @State private var showingActionSheet = false // Action sheet starts hidden
    
    @State private var videoTitle: String = "" // Video title starts empty
    @State private var videoTranscript: String = "" // Video transcript starts empty
    
    @State private var speechSynthesizer = AVSpeechSynthesizer() // Speech synthesizer for text-to-speech(voiceover)




    // List of questions
    let questions = [
        "what are the step-by-step instructions for replicating the process demonstrated in the video?",
        "based on the content, provide a practical action plan.",
        "Explain this video",
        "give me a list of the main things discussed in this video",
        "are there any logical fallacies or errors in the video's arguments?",
        "what is the main takeaway from this video",
        "give me all the interesting information from this video",
        "what are the key arguments or points made in this video?",
        "summarize the video in 1 sentence",
        "summarize the video in 1 word",
        "what is the intended audience of this video?",
        "what are the supporting facts or examples mentioned?",
        "is the content biased in any way?",
        "what questions are raised but left unanswered?",
        "what was the most surprising information presented?",
        "list any key quotes or phrases worth remembering",
        "what's the emotional tone of the video?",
        "what are the counter-arguments or alternate viewpoints presented?",
        "how credible is the source of this video?",
        "is there a call to action, and if so, what is it?",
        "what background knowledge is assumed or required for understanding this video?",
        "identify any notable guests, interviews, or citations in the video",
        "what's the main skill or lesson taught in this tutorial or how-to video?",
        "what are the key statistics or data points mentioned?",
        "are there any moments of humor or entertainment, and what's their purpose?",
        "what auditory elements stand out?",
        
    ]
    
   
    var body: some View { // The main body of the InsightView
        
            
            ZStack { // ZStack to layer the background gradient and the main content
                
                LinearGradient( // Background gradient
                    gradient: Gradient(colors: [Color.black, Color.customTeal, Color.gray]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all) // Fill the entire screen with the gradient
                
                
                if settings.termsAccepted == false{ // If the terms anc condition has not been accepted yet
                    
                    // Display a message to set the API key if it's not set
                    Button("Press here to sign the terms and conditions"){
                        currentPath = .terms // takes to terms and conditions view
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.customTeal.opacity(0.7)) // coloured background to show authority
                    .cornerRadius(10)
                    
                } else { // terms and conditions must have been accepted
                    
                    // The ScrollView to accommodate dynamic content eg the keyboard
                    
                    // - Allows veritcal scrolling, UI elements(text-fields,buttons,response display
                    // - Works with keyboardAdaptive modifier to prevent keyboard from obscuring UI elements, maintaining a smooth user experience.
                    // - Organizes content in a linear, scrollable fashion, guiding the user through the process of entering a URL, selecting questions, and viewing video insights.
                    
                    
                    ScrollView {
                        
                        // VStack { // VStack containing the main UI elements for video URL input, custom insight text editor, question selection menu, video unpacking button, loading view, and the response display.
                            
                            Spacer().frame(height: 100) // Vertical space at the top
                            
                            
                            HStack { // "Enter URL" text field with paste and delete buttons, horizontal padding, and rounded border
                                
                                TextField("Enter URL", text: $urlInput) // Text field for entering the video URL
                                    .padding([.leading, .trailing])
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .overlay(
                                        HStack { // HStack for delete and paste buttons
                                            Spacer() // Pushes the buttons to the trailing edge inside the text field
                                            
                                            // Paste button
                                            if UIPasteboard.general.hasStrings { // if theres something copieds
                                                Button(action: {
                                                    if let clipboardContent = UIPasteboard.general.string {
                                                        urlInput = clipboardContent // Sets the text field's content to the clipboard's content
                                                    }
                                                }) {
                                                    Image(systemName: "doc.on.clipboard")
                                                        .font(.system(size: 20))
                                                        .padding(8)
                                                        .foregroundStyle(Color.customTeal)
                                                }
                                                .padding(.trailing, 10) // Adjust padding as needed
                                            }
                                            
                                            // Delete button
                                            if !urlInput.isEmpty { // Shows the delete button only when there is text
                                                Button(action: {
                                                    urlInput = "" // Clears the text field when the button is tapped
                                                }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .font(.system(size: 20))
                                                        .foregroundColor(.gray)
                                                }
                                                .padding(.trailing, 20) // Increased padding to push the button further left
                                            }
                                        }
                                    )
                            }
                            
                            
                            
                            VStack {
                                
                                ZStack(alignment: .topTrailing) {
                                    
                                    TextEditor(text: $customInsight)
                                        .padding(4) // Adjust padding inside TextEditor if needed
                                        .frame(height: 100)
                                        .border(Color(UIColor.separator), width: 1) // Border for TextEditor
                                        .cornerRadius(8) // Rounded corners for TextEditor
                                    
                                    // Show the button only when there is text
                                    if !customInsight.isEmpty {
                                        Button(action: {
                                            customInsight = ""
                                        }) {
                                            Image(systemName: "xmark.circle.fill") // Clear button
                                                .font(.system(size: 20))
                                                .foregroundColor(.gray)
                                                .padding(.trailing, 10) // Right padding inside TextEditor
                                                .padding(.top, 8) // Top padding inside TextEditor
                                        }
                                        .transition(.opacity) // Fade transition for the button
                                        .animation(.default, value: customInsight.isEmpty)
                                    }
                                }
                            }
                            
                            
                            HStack {
                                
                                ZStack { // The Menu for selecting a question
                                    Menu {
                                        Picker("Select a question", selection: $customInsight) { // Picker for selecting a question
                                            ForEach(questions, id: \.self) { question in // Loop through the list of questions
                                                Text(question).tag(question) // Display each question as a selectable option
                                            }
                                        }
                                    } label: {
                                        HStack { // Horizontal stack 
                                            Text("Select a question")
                                                .foregroundColor(.white)
                                                .font(.headline)
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 20))
                                                .foregroundColor(Color.white)
                                        }
                                        
                                        .padding()
                                        
                                        .cornerRadius(10)
                                        .foregroundColor(.white)
                                    }
                                }
                                .background(Color.customTeal)
                                .opacity(0.9)
                                .cornerRadius(20)
                                
                                
                                // The "Digest video" button
                                Button("Analyse Video") {
                                    fetchData()
                                }
                                // .disabled(!isApiKeySet) // Disable the button if the API key is not set
                                .padding()
                                .foregroundColor(.white)
                                .fontWeight(.bold)                                .padding(.horizontal)
                                .background(Color.customTeal)
                                .opacity(0.9)
                                .cornerRadius(20)
                            }
                            
                            if isLoading { // if loading, make CustomLoadingSwiftUIView the view for this vstack
                                VStack {
                                    Spacer() 
                                    CustomLoadingSwiftUIView() // Custom loading view
                                        .frame(width: 50, height: 50)
                                        .offset(x: 21, y: 50)
                                    
                                    Spacer()
                                }
                                .frame(height: 100)
                            }
                            
                            DisclosureGroup(
                                isExpanded: $isResponseExpanded,
                                content: {
                                    // Display the API response
                                    Text(LocalizedStringKey(apiResponse))
                                        .onTapGesture {
                                            self.speak(text: self.apiResponse)
                                        }
                                        .padding()
                                        .foregroundColor(.white)
                                        .background(Color.customTeal.opacity(0.5))
                                },
                                label: {
                                    Label("", systemImage: "chevron.down") // chevron down image
                                        .foregroundColor(Color.white) 
                                }
                            )
                            .foregroundColor(Color.black)
                            .multilineTextAlignment(.center)
                    }
                    
                }
                
                
            }
            .edgesIgnoringSafeArea(.all)
            .keyboardAdaptive()
            .cornerRadius(10) // Rounded corners
            .gesture(
                TapGesture()
                    .onEnded { _ in
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
            )
        
            
        
    }
    
    func speak(text: String) {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        } else {
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US") // or any other preferred language
            speechSynthesizer.speak(utterance)
        }
    }

    
    func actionSheetButtons() -> [ActionSheet.Button] {
            var buttons: [ActionSheet.Button] = []
            for question in questions {
                buttons.append(.default(Text(question)) {
                    self.selectedQuestion = question
                    self.customInsight = question
                })
            }
            buttons.append(.cancel())
            return buttons
        }
    
 
    private func fetchData() {
        isLoading = true // set loading to true, as we've entered the fetch data function
        APIManager.handleCustomInsightAll(yt_url: urlInput, userPrompt: customInsight) { success, response in // Call the HandleCustomInsightAll function from the APIManager.swift file
            DispatchQueue.main.async { // Dispatch the following code to the main thread
                self.isLoading = false // Set loading to false, as we've finished fetching data
                if success, let response = response { // If the fetch was successful and the response is NOT nil
                    print(response) // Print the response to the console
                    
                    self.savedInsights.append(VideoInsight(title: "Your Video Title", insight: response)) // Append directly to the list
                    self.apiResponse = response // Set apiResponse to the response generated
                    self.updateUI(success: success, response: response) // Update the UI with the response
                } else { // If the fetch was unsuccessful
                    self.apiResponse = "fetchData error" // Set apiResponse to an error message
                    self.updateUI(success: false, response: nil) // Update the UI with the error message
                }
            }
        }
    }
    
    // TODO: Unpack the

    private func updateUI(success: Bool, response: String?) { // function to update the UI based on the success of the API call
        DispatchQueue.main.async { // Dispatch the following code to the main thread
            if success { // If the API call was successful
                let newInsight = VideoInsight(title: videoTitle, insight: apiResponse ?? "No data") // Create a new VideoInsight object with the video title and the API response
//                self.apiResponse = newInsight.insight
                if let existingSavedInsightsData = UserDefaults.standard.data(forKey: "savedInsights"), // If there are existing saved insights in UserDefaults
                   var existingSavedInsights = try? JSONDecoder().decode([VideoInsight].self, from: existingSavedInsightsData) { // decode json data into VideoInsight objects
                    existingSavedInsights.append(newInsight) // Append the new insight to the existing list
                    if let encoded = try? JSONEncoder().encode(existingSavedInsights) { // Encode the updated list
                        UserDefaults.standard.set(encoded, forKey: "savedInsights") // Save the updated list to UserDefaults
                    }
                } else { // If there are no existing saved insights
                    let newInsights = newInsight // Set the new insights to the new insight
                    if let encoded = try? JSONEncoder().encode(newInsights) { // Encode the new insights
                        UserDefaults.standard.set(encoded, forKey: "savedInsights") // Save the new insights to UserDefaults
                    }
                }
            } else { // If the API call was unsuccessful
                apiResponse = response ?? "An unspecified error occurred"
            }
        }
        
        func handleNewInsight(title: String, insight: String) { // function to handle a new insight
            let newInsight = VideoInsight(title: title, insight: insight) // Create a new VideoInsight object with the title and insight
            savedInsights.append(VideoInsight(title: "Your Video Title", insight: response!)) // Append the new insight to the saved insights list
            
            // Save the updated list to UserDefaults
            if let encoded = try? JSONEncoder().encode(savedInsights) {
                UserDefaults.standard.set(encoded, forKey: "savedInsights")
            }
        }
    }
}



struct InsightView_Previews: PreviewProvider {
    static var previews: some View {
        // Create an instance of SharedSettings for the preview
        let settings = SharedSettings()

        // Pass the settings to the InsightView using the environmentObject modifier
        InsightView(currentPath: Binding.constant(AppNavigationPath.root))
            .environmentObject(settings)
    }
}
