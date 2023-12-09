import SwiftUI
import Combine

extension UIResponder {
    private weak static var _currentFirstResponder: UIResponder? = nil

    public static var currentFirstResponder: UIResponder? {
        _currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(findFirstResponder(_:)), to: nil, from: nil, for: nil)
        return _currentFirstResponder
    }

    @objc internal func findFirstResponder(_ sender: Any) {
        UIResponder._currentFirstResponder = self
    }
    
    var globalFrame: CGRect? {
        guard let view = self as? UIView else { return nil }
        return view.window?.convert(view.bounds, from: view)
    }
}


// Adapts the app to not push down up the screen if using keyboard
struct KeyboardAdaptive: ViewModifier {
    @State private var bottomPadding: CGFloat = 0

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .padding(.bottom, self.bottomPadding)
                .onReceive(Publishers.keyboardHeight) { keyboardHeight in
                    let keyboardTop = geometry.frame(in: .global).height - keyboardHeight
                    let focusedTextInputBottom = UIResponder.currentFirstResponder?.globalFrame?.maxY ?? 0
                    self.bottomPadding = max(0, focusedTextInputBottom - keyboardTop - geometry.safeAreaInsets.bottom)
                }
                .animation(.easeOut(duration: 0.16), value: bottomPadding)
        }
    }
}

extension View {
    func keyboardAdaptive() -> some View {
        ModifiedContent(content: self, modifier: KeyboardAdaptive())
    }
}

extension Publishers {
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
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}


struct InsightView: View {
    
    //    @State private var isApiKeySet: Bool = UserDefaults.standard.string(forKey: "openai_apikey") != nil
    
    @Binding var currentPath: AppNavigationPath
    var customLoading: CustomLoadingView! // Custom loading sign
    @EnvironmentObject var settings: SharedSettings // "terms are accepted" bool gate keeper
    
    
    @State private var urlInput: String = ""
    @State private var customInsight: String = "" // Custom message
    
    @State private var apiResponse: String = ""
    @State private var isResponseExpanded = false // for DisclosureGroup
    @State private var savedInsights: [String] = []
    @State private var isLoading = false
    
    @State private var selectedQuestion: String = ""
    @State private var showingActionSheet = false
    
    @State private var videoTitle: String = ""
    @State private var videoTranscript: String = ""



    // List of questions
    let questions = [
        
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
    
   
    var body: some View {
        
            
            ZStack {
                
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color.customTeal, Color.gray]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                
                if settings.termsAccepted == false{ // If the terms anc condition has not been accepted yet
                    
                    // Display a message to set the API key if it's not set
                    Button("Press here to sign the terms and conditions"){
                        currentPath = .terms // takes to terms and conditions view
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.customTeal.opacity(0.7)) // coloured background to show authority
                    .cornerRadius(10)
                    
                } else {
                    
                    // The ScrollView to accommodate dynamic content eg the Picker
                    
                    // - Allows veritcal scrolling, UI elements(text-fields,buttons,response display
                    // - Works with keyboardAdaptive modifier to prevent keyboard from obscuring UI elements, maintaining a smooth user experience.
                    // - Organizes content in a linear, scrollable fashion, guiding the user through the process of entering a URL, selecting questions, and viewing video insights.
                    
                    
                    ScrollView {
                        
                        VStack { // VStack containing the main UI elements for video URL input, custom insight text editor, question selection menu, video unpacking button, loading view, and the response display.
                            
                            Spacer().frame(height: 100) // Vertical space at the top
                            
                            
                            HStack { // "Enter URL"
                                
                                TextField("Enter URL", text: $urlInput)
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
                                            Image(systemName: "xmark.circle.fill")
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
                                        Picker("Select a question", selection: $customInsight) {
                                            ForEach(questions, id: \.self) { question in
                                                Text(question).tag(question)
                                            }
                                        }
                                    } label: {
                                        HStack {
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
                                Button("Analyze Video") {
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
                            
                            if isLoading { // if loading make CustomLoadingSwiftUIView the view for this vstack
                                VStack {
                                    Spacer()
                                    CustomLoadingSwiftUIView()
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
        isLoading = true
        APIManager.handleCustomInsightAll(yt_url: urlInput, userPrompt: customInsight) { success, response in
            DispatchQueue.main.async {
                self.isLoading = false
                if success, let response = response {
                    print(response) // print response
                    self.apiResponse = response
                    self.updateUI(success: success, response: response)
                } else {
                    self.apiResponse = "Error fetching data"
                    self.updateUI(success: false, response: nil)
                }
            }
        }
    }


    private func updateUI(success: Bool, response: String?) {
        DispatchQueue.main.async {
            if success {
                let newInsight = VideoInsight(title: videoTitle, insight: response ?? "No data")
                if let existingSavedInsightsData = UserDefaults.standard.data(forKey: "savedInsights"),
                   var existingSavedInsights = try? JSONDecoder().decode([VideoInsight].self, from: existingSavedInsightsData) {
                    existingSavedInsights.append(newInsight)
                    if let encoded = try? JSONEncoder().encode(existingSavedInsights) {
                        UserDefaults.standard.set(encoded, forKey: "savedInsights")
                    }
                } else {
                    let newInsights = newInsight
                    if let encoded = try? JSONEncoder().encode(newInsights) {
                        UserDefaults.standard.set(encoded, forKey: "savedInsights")
                    }
                }
            } else {
                apiResponse = response ?? "An unspecified error occurred"
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
