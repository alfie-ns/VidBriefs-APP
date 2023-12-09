import SwiftUI
import AVKit

struct RootView: View {
    @Binding var currentPath: AppNavigationPath
    @State private var isContinueButtonPressed: Bool = false
    @State private var showingVideoPlayer = false
    @State private var dragAmount = CGSize.zero

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            // Image that moves with the drag gesture
            Image("libraryPicture")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .opacity(0.5)
                .blendMode(.overlay)
                .offset(y: dragAmount.height)
                .animation(.easeInOut)

            VStack {
                // Title View
                Text("VidBriefs")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(radius: 10)
                    .padding(.bottom, 20)

                // Continue Button
                Button(action: {
                    self.isContinueButtonPressed = true
                    self.currentPath = .home
                }) {
                    Text("Continue")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 200, height: 60)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.gray, Color.customTeal]), startPoint: .top, endPoint: .bottom)
                        )
                        .cornerRadius(15.0)
                        .shadow(radius: 10)
                }
                .padding(.bottom, 5)
                
                // "How to use" Button
                Button("How to use") {
                    showingVideoPlayer = true
                }
                .foregroundColor(.white)
                .padding()
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.gray, Color.customTeal]), startPoint: .top, endPoint: .bottom)
                )
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.top, 7)
            }
            .sheet(isPresented: $showingVideoPlayer) {
                VideoPlayerView(videoName: "ExampleVideo", videoType: "mov")
            }
        }
        .gesture(
            DragGesture()
                .onChanged { self.dragAmount = $0.translation }
                .onEnded { value in
                    if value.translation.height < 0 && abs(value.translation.height) > 100 {
                        // Swipe up detected
                        self.currentPath = .home
                    }
                    self.dragAmount = .zero // Reset drag amount
                }
        )
    }
}

// Preview
struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(currentPath: Binding.constant(AppNavigationPath.root))
    }
}
