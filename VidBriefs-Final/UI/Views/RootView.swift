
import SwiftUI
import AVKit

struct RootView: View {
    @Binding var currentPath: AppNavigationPath
    @State private var isContinueButtonPressed: Bool = false
    @State private var showingVideoPlayer = false
    @State private var dragAmount = CGSize.zero

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                // Moving background image
                Image("libraryPicture")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.5)
                    .blendMode(.overlay)
                    .offset(y: dragAmount.height)
                    .animation(.easeInOut)

                VStack {
                    Spacer()

                    // Title
                    Text("VidBriefs")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 10, x: 0, y: 5)
                        .padding(.bottom, 50)

                    // Continue Button
                    Button(action: {
                        self.isContinueButtonPressed = true
                        self.currentPath = .home
                    }) {
                        Text("Continue")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 60)
                            .background(
                                LinearGradient(gradient: Gradient(colors: [Color.gray, Color.customTeal]), startPoint: .top, endPoint: .bottom)
                            )
                            .cornerRadius(30)
                            .shadow(color: .black, radius: 10, x: 0, y: 5)
                    }
                    .padding(.bottom, 20)
                    
                    // How to use Button
                    Button("How to use") {
                        showingVideoPlayer = true
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 30)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color.gray, Color.customTeal]), startPoint: .top, endPoint: .bottom)
                    )
                    .cornerRadius(20)
                    .shadow(color: .black, radius: 5, x: 0, y: 3)

                    Spacer()
                }
                .frame(width: geometry.size.width)
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
                        self.currentPath = .home
                    }
                    self.dragAmount = .zero
                }
        )
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(currentPath: .constant(.root))
    }
}
