import SwiftUI
import AVKit

// RootView serves as the initial view of the application, utilising SwiftUI for the UI components

struct RootView: View {
    @Binding var currentPath: AppNavigationPath // Binding to the app's navigation path
    @State private var isContinueButtonPressed: Bool = false // State to track the "Continue" button press
    @State private var showingVideoPlayer = false // State to control the display of the video player
    @State private var dragAmount = CGSize.zero // State to track the drag gesture offset

    var body: some View {
        ZStack {
            // Background gradient from black to gray, filling the entire screen
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            // Image that moves vertically with the drag gesture
            Image("libraryPicture")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .opacity(0.5) // Semi-transparent image
                .blendMode(.overlay) // Overlay blend mode for effect
                .offset(y: dragAmount.height) // Offset applied based on drag amount
                .animation(.easeInOut) // Smooth animation for movement

            VStack {
                // Title view for the app
                Text("VidBriefs")
                    .font(.largeTitle) // Large title font
                    .fontWeight(.bold) // Bold font weight
                    .foregroundColor(.white) // White text color
                    .shadow(radius: 10) // Text shadow for depth
                    .padding(.bottom, 20) // Padding below the title

                // Button to proceed to the next view
                Button(action: {
                    self.isContinueButtonPressed = true // Update state on button press
                    self.currentPath = .home // Navigate to home
                }) {
                    Text("Continue")
                        .font(.title) // Title font for button text
                        .fontWeight(.bold) // Bold font weight
                        .foregroundColor(.white) // White text color
                        .padding() // Padding inside the button
                        .frame(width: 200, height: 60) // Button size
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.gray, Color.customTeal]), startPoint: .top, endPoint: .bottom)
                        ) // Button background gradient
                        .cornerRadius(15.0) // Rounded corners
                        .shadow(radius: 10) // Shadow for depth
                }
                .padding(.bottom, 5) // Padding below the button
                
                // Button to show the "How to use" video
                Button("How to use") {
                    showingVideoPlayer = true // Show video player on button tap
                }
                .foregroundColor(.white) // White text color
                .padding() // Padding inside the button
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.gray, Color.customTeal]), startPoint: .top, endPoint: .bottom)
                ) // Button background gradient
                .cornerRadius(10) // Rounded corners
                .shadow(radius: 5) // Shadow for depth
                .padding(.top, 7) // Padding above the button
            }
            .sheet(isPresented: $showingVideoPlayer) {
                VideoPlayerView(videoName: "ExampleVideo", videoType: "mov") // Present video player sheet
            }
        }
        .gesture(
            DragGesture()
                .onChanged { self.dragAmount = $0.translation } // Update drag amount as user drags
                .onEnded { value in
                    if value.translation.height < 0 && abs(value.translation.height) > 100 {
                        // If user drags up significantly, navigate to home
                        self.currentPath = .home
                    }
                    self.dragAmount = .zero // Reset drag amount after drag ends
                }
        )
    }
}

// Preview provider for RootView, used in Xcode previews
struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(currentPath: Binding.constant(AppNavigationPath.root)) // Provide a constant binding for preview
    }
}