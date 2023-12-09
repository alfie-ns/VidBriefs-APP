import SwiftUI

struct AboutView: View {
    
    @Binding var currentPath: AppNavigationPath
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // Back Button
                Button(action: {
                    currentPath = .settings
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundStyle(.white)
                        .font(.system(size: 24))
                        .padding()
                }

                // Title
                Text("About VideoDigest")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.bottom, 5)

                // Subtitle
                Text("Discover how to efficiently extract key information from videos in less time")
                    .font(.headline) // Changed to headline for better visibility
                    .foregroundStyle(.gray)
                    .padding(.bottom, 10)
                
                Divider()
                
                
                
                // Description
                Group {
                    Text("Explore the Essence of Every Video Instantly")
                        .font(.title3) // Slightly smaller than headline for differentiation
                        .fontWeight(.bold)
                        .padding(.vertical, 5)
                        .foregroundStyle(.white)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("1. : Input your question about the video's content, seeking clarity, insights, or deeper understanding.")
                        Text("2. Effortless Information Retrieval: Submit your query and feel free to navigate away. GPT-4 AI processes the video in the background.")
                        Text("3. Swift, Seamless Summaries: Return in 20 seconds for a concise summary. Your understanding, maximized with minimal time investment.")
                        Text("🌟Keep the app running in the background to ensure uninterrupted AI summarization🌟")
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

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView(currentPath: Binding.constant(AppNavigationPath.root))
    }
}
