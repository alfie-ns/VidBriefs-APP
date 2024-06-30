import SwiftUI

// This swift view is for the library view where the user can see all the insights they have saved. They can also delete all the insights or copy an insight to the clipboard.

enum ActiveAlert { // Enum for the alert
    case clearAll, selectedInsight
}

//struct VideoInsight: Codable { // Struct for the video insight, codable for encoding && decoding   
//    var title: String // Title of the insight: String
//    var insight: String // Insights given to the user: String
//}


struct LibraryView: View { // LibraryView struct
    
    @Binding var currentPath: AppNavigationPath // Binding for the current path
    @EnvironmentObject var settings: SharedSettings // Environment object for the SharedSettings

    
    @State private var savedInsights: [VideoInsight] = []  // create a savedInsights list storing the responses
    @State private var activeAlert: ActiveAlert = .selectedInsight // active alert for the view 
    @State private var showAlert = false
    @State private var selectedInsight: String = ""
    @State private var insightCopied = false

    
    var body: some View { // main body of the view

        // Main ZStack for the view
        
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
                    .background( // Background for the button
                        
                        LinearGradient( // Gradient for the background
                        gradient: Gradient(colors: [Color.black, Color.customTeal, Color.gray]), // Added Color.blue
                        startPoint: .top, // start gradient from top
                        endPoint: .bottom // end gradient at bottom
                    )
                    .edgesIgnoringSafeArea(.all)) // Ignore the safe area for the gradient; thus entire screen is covered by the gradient
                    .foregroundColor(Color.white) // Set the text color to white
                    .cornerRadius(8)
                    
                    if insightCopied { // if an insight is copied
                        Text("Insight copied to clipboard") // print message
                            .foregroundColor(.green) // set text color to green
                            .bold() // set text to bold
                            .animation(.easeInOut, value: insightCopied) // set animation for the text
                            .transition(.opacity) // set transition for the text
                    }
                    
                    List { // list for all the insights
                        ForEach(savedInsights.indices, id: \.self) { index in // for each insight in the savedInsights list
                            HStack { // horizontal stack for each insight
                                Button(action: { // action for the button
                                    self.selectedInsight = savedInsights[index].title // select the insight

                                    activeAlert = .selectedInsight // set the active alert to selected insight
                                    self.showAlert = true // show the alert
                                }) {
                                    Text("Insight \(index + 1)") // print the insight number
                                        .foregroundStyle(Color.black) // set the text color to black
                                }
                                
                                Spacer() // add a spacer
                                
                                Button(action: { // button to copy the insight
                                    UIPasteboard.general.string = savedInsights[index].insight
                                    self.insightCopied = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { // Resets `insightCopied` to false after 1.5 seconds to hide the "Insight copied" message
                                        self.insightCopied = false // set the insight copied to false thus hide message
                                    }
                                }) {
                                    Image(systemName: "doc.on.doc") // System image for copy icon
                                        .foregroundColor(.blue) // set the color to blue
                                }
                            }
                        }
                        .onDelete(perform: delete) // perform delete action
                    }
                    .background(Color.black) // set the background color to clear
                    
                    // TODO: I NEED TO CHANGE THIS TO ALIGN WITH LIGHT OR DARK MODE
                }
            }
            .navigationBarTitle("Library", displayMode: .inline)
            .onAppear {
                if let insightsData = UserDefaults.standard.data(forKey: "savedInsights") {
                    do { // try to decode the insights, if error catch it
                        self.savedInsights = try JSONDecoder().decode([VideoInsight].self, from: insightsData)
                    } catch {
                        print("Error decoding insights: \(error)") // print the error
                    }
                }
            }
            .alert(isPresented: $showAlert) { // Presents an alert when `showAlert` is true
                switch activeAlert { // Determines which alert to present based on the value of `activeAlert`
                case .clearAll: // Case for the "Clear All" alert
                    return Alert(
                        title: Text("Clear All"), // Title of the alert
                        message: Text("Are you sure you want to remove all saved insights?"), // Message asking for confirmation to delete all insights
                        primaryButton: .destructive(Text("Yes")) { // Confirmation button to delete all insights
                            savedInsights.removeAll() // Remove all insights from the saved list
                            UserDefaults.standard.set(savedInsights, forKey: "savedInsights") // Update UserDefaults to reflect the removal
                        }, 
                        secondaryButton: .cancel() // Cancel button to dismiss the alert without making changes
                    )
                case .selectedInsight: // Case for the "Selected Insight" alert
                    return Alert(
                        title: Text("Selected Insight"), // Title of the alert
                        message: Text(LocalizedStringKey(selectedInsight)), // Displays the title of the selected insight
                        dismissButton: .default(Text("OK")) // Dismiss button to close the alert
                    )
                }
            }
    }

    }

    private func delete(at offsets: IndexSet) { // private delete function for the case when the user swipes left on an insight
        savedInsights.remove(atOffsets: offsets) // remove the insight at the given index
        UserDefaults.standard.set(savedInsights, forKey: "savedInsights") // update the user defaults
    }
    
    func saveInsights() { // function to save the insight
        UserDefaults.standard.set(savedInsights, forKey: "savedInsights") // save the insights to the user defaults
    }
}

struct LibaryView_Previews: PreviewProvider { // preview provider for the library view
    static var previews: some View {
        LibraryView(currentPath: Binding.constant(AppNavigationPath.root))
    }
}
