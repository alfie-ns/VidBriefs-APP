import SwiftUI
// Import SwiftUI for building the user interface

struct AboutView: View { // Defines a view for the About screen
    
    @Binding var currentPath: AppNavigationPath // Binds the current navigation path
    
    var body: some View { // Body of the view
        ScrollView { // Scrollable view
            VStack(alignment: .leading, spacing: 16) { // Vertical stack with leading alignment and spacing of 16
                
                // Back Button
                Button(action: {
                    currentPath = .settings // Navigates back to the settings screen
                }) {
                    Image(systemName: "arrow.left") // Back arrow icon
                        .foregroundStyle(.white) // White color
                        .font(.system(size: 24)) // Font size 24
                        .padding() // Adds padding
                }

                // Title
                Text("About VideoDigest")
                    .font(.largeTitle) // Large title font
                    .fontWeight(.bold) // Bold weight
                    .foregroundStyle(.white) // White color
                    .padding(.bottom, 5) // Adds bottom padding of 5

                // Subtitle
                Text("Discover how to efficiently extract key information from videos in less time")
                    .font(.headline) // Changed to headline for better visibility
                    .foregroundStyle(.gray) // Gray color
                    .padding(.bottom, 10) // Adds bottom padding of 10
                
                Divider() // Horizontal divider
                
                
                
                // Description
                Group {
                    Text("Instantly Uncover the Core of Every Video.") 
                        .font(.title3) // Slightly smaller than headline for differentiation
                        .fontWeight(.bold) // Bold weight
                        .padding(.vertical, 5) // Adds vertical padding of 5
                        .foregroundStyle(.white) // White color

                    VStack(alignment: .leading, spacing: 8) {
                        Text("1. Input your question about the video content to seek clarity, insights, or deeper understanding.")
                        Text("2. Submit your query and let AI process the video. You may continue using the app or perform other tasks.")
                        Text("3. Return after a short while to view the summary and insights generated from the video.")
                        Text("🌟 Ensure the app remains active to complete the summarization process. 🌟")
                    }
                    .font(.body) // Standard body font for better readability
                    .padding(.leading, 10)
                    .foregroundStyle(.white)
                }
                
                Divider()
                
                // Additional Info
                Group {
                    Text("Viewing your question")
                        .font(.title3) // Consistency with other section titles
                        .fontWeight(.bold)
                        .padding(.vertical, 5)
                        .foregroundStyle(.white)
                    
                    Text("Your questions and the AI responses will be displayed here, in an easy-to-read format.")
                        .font(.body) // Consistent body font
                        .padding(.leading, 10)
                        .foregroundStyle(.white)
                }
                
                Divider()
                
            }
            .padding(.horizontal, 16)
        }
    }
}

struct AboutView_Previews: PreviewProvider { // Previews for the AboutView
    static var previews: some View {
        AboutView(currentPath: Binding.constant(AppNavigationPath.root))
    }
}
