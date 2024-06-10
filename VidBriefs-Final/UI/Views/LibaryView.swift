import SwiftUI

// This swift view is for the library view where the user can see all the insights they have saved. They can also delete all the insights or copy an insight to the clipboard.

enum ActiveAlert { // Enum for the alert
    case clearAll, selectedInsight
}

struct VideoInsight: Codable { // Struct for the video insight, codable for encoding && decoding   
    var title: String // Title of the insight: String
    var insight: String // Insights given to the user: String
}


struct LibraryView: View { // LibraryView struct
    
    @Binding var currentPath: AppNavigationPath // Binding for the current path
    @EnvironmentObject var settings: SharedSettings // Environment object for the SharedSettings

    
    @State private var savedInsights: [VideoInsight] = []  // create a savedInsights list storing the responses
    @State private var activeAlert: ActiveAlert = .selectedInsight 
    @State private var showAlert = false
    @State private var selectedInsight: String = ""
    @State private var insightCopied = false

    
    var body: some View { // main body of the view
        
        ZStack { // ZStack for the view
           
            ZStack { // ZStack for the background
                           
                LinearGradient( // Gradient for the background
                    gradient: Gradient(colors: [Color.black, Color.customTeal, Color.gray]), // Added Color.blue
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all) // Ignore the safe area for the gradient

                
                VStack { // vertical stack for the view
                    Text("Swipe left on an insight to delete it.")
                        .foregroundColor(Color.white)
                        .padding(.top)
                        .bold()
                    
                    // Clear All button
                    Button("Clear All") {
                        activeAlert = .clearAll
                        showAlert = true
                    }
                    .padding()
                    .background( 
                        
                        LinearGradient(
                        gradient: Gradient(colors: [Color.black, Color.customTeal, Color.gray]), // Added Color.blue
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .edgesIgnoringSafeArea(.all))
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
                        ForEach(savedInsights.indices, id: \.self) { index in
                            HStack {
                                Button(action: {
                                    self.selectedInsight = savedInsights[index].title

                                    activeAlert = .selectedInsight
                                    self.showAlert = true
                                }) {
                                    Text("Insight \(index + 1)")
                                        .foregroundStyle(Color.black)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    UIPasteboard.general.string = savedInsights[index].insight
                                    self.insightCopied = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        self.insightCopied = false
                                    }
                                }) {
                                    Image(systemName: "doc.on.doc") // System image for copy icon
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .onDelete(perform: delete)
                    }
                    .background(Color.clear)
                }
            }
            .navigationBarTitle("Library", displayMode: .inline)
            .onAppear {
                if let insightsData = UserDefaults.standard.data(forKey: "savedInsights") {
                    do {
                        self.savedInsights = try JSONDecoder().decode([VideoInsight].self, from: insightsData)
                    } catch {
                        print("Error decoding insights: \(error)")
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                switch activeAlert {
                case .clearAll:
                    return Alert(title: Text("Clear All"), message: Text("Are you sure you want to remove all saved insights?"), primaryButton: .destructive(Text("Yes")) {
                        savedInsights.removeAll()
                        UserDefaults.standard.set(savedInsights, forKey: "savedInsights")
                    }, secondaryButton: .cancel())
                case .selectedInsight:
                    return Alert(title: Text("Selected Insight"), message: Text(LocalizedStringKey(selectedInsight)), dismissButton: .default(Text("OK")))
                }
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        savedInsights.remove(atOffsets: offsets)
        UserDefaults.standard.set(savedInsights, forKey: "savedInsights")
    }
    
    func saveInsights() {
        UserDefaults.standard.set(savedInsights, forKey: "savedInsights")
    }
}

struct LibaryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView(currentPath: Binding.constant(AppNavigationPath.root))
    }
}
