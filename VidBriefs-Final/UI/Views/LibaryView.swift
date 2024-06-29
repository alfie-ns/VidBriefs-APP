import SwiftUI

struct LibraryView: View {
    @Binding var currentPath: AppNavigationPath
    @EnvironmentObject var settings: SharedSettings
    
    @State private var savedInsights: [VideoInsight] = []
    @State private var showAlert = false
    @State private var selectedInsight: String = ""
    @State private var insightCopied = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.customTeal, Color.gray]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Text("Library")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: startNewChat) {
                        Text("New Chat")
                            .padding()
                            .background(Color.customTeal)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                
                Text("Swipe left on an insight to delete it.")
                    .foregroundColor(Color.white)
                    .padding(.top)
                    .bold()
                
                Button("Clear All") {
                    showAlert = true
                }
                .padding()
                .background(Color.customTeal)
                .foregroundColor(Color.white)
                .cornerRadius(8)
                
                if insightCopied {
                    Text("Insight copied to clipboard")
                        .foregroundColor(.green)
                        .bold()
                        .animation(.easeInOut, value: insightCopied)
                        .transition(.opacity)
                }
                
                List {
                    ForEach(savedInsights) { insight in
                        HStack {
                            Button(action: {
                                openConversation(insight)
                            }) {
                                Text(insight.title)
                                    .foregroundColor(.black)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                UIPasteboard.general.string = insight.insight
                                self.insightCopied = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    self.insightCopied = false
                                }
                            }) {
                                Image(systemName: "doc.on.doc")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .onDelete(perform: delete)
                }
                .background(Color.black)
            }
            .navigationBarTitle("Library", displayMode: .inline)
            .onAppear(perform: loadInsights)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Clear All"),
                    message: Text("Are you sure you want to remove all saved insights?"),
                    primaryButton: .destructive(Text("Yes")) {
                        savedInsights.removeAll()
                        saveInsights()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    private func startNewChat() {
        let newChat = InsightView(currentPath: $currentPath)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(UIHostingController(rootView: newChat), animated: true, completion: nil)
        }
    }
    
    private func delete(at offsets: IndexSet) {
        savedInsights.remove(atOffsets: offsets)
        saveInsights()
    }
    
    private func loadInsights() {
        if let savedData = UserDefaults.standard.data(forKey: "savedInsights"),
           let decodedInsights = try? JSONDecoder().decode([VideoInsight].self, from: savedData) {
            self.savedInsights = decodedInsights
        }
    }
    
    private func saveInsights() {
        if let encodedData = try? JSONEncoder().encode(savedInsights) {
            UserDefaults.standard.set(encodedData, forKey: "savedInsights")
        }
    }
    
    private func openConversation(_ insight: VideoInsight) {
        let insightView = InsightView(currentPath: $currentPath, existingConversation: insight)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(UIHostingController(rootView: insightView), animated: true, completion: nil)
        }
    }
}