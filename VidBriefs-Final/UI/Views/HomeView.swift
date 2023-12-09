import SwiftUI

struct HomeView: View {
    
    @Binding var currentPath: AppNavigationPath
    @EnvironmentObject var settings: SharedSettings

    @State private var savedInsights: [String] = []
    @State private var currentRandomInsight: String = "No insights available"
    @State private var appearanceCount = 0

    var randomInsight: String {
        savedInsights.randomElement() ?? "No insights available"
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) { // Align content to the top trailing
            
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.customTeal, Color.gray]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 20) {
                    // Greeting Section
                    VStack {
                        HStack {
                            Spacer()
                            // Back button
                            Button(action: {
                                currentPath = .root
                            }) {
                                Image(systemName: "arrow.left")
                                    .foregroundColor(.white)
                                    .font(.system(size: 24))
                            }
                            Spacer()
                        }
                        .padding(.top, 50)

                        Text("Welcome")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("What would you like to learn about today?")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .padding(.top, 50)

                    Text(LocalizedStringKey(currentRandomInsight))
                        .padding()
                        .background(Color.customTeal)
                        .opacity(0.75)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }

            // Randomize Button
            Button(action: {
                self.currentRandomInsight = self.randomInsight // Randomise the current shown insight
            }) {
                Image(systemName: "die.face.2").font(.title)
            }
            .padding()
            .cornerRadius(20)
            .background(Color.customTeal)
            .opacity(0.75)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.trailing, 20)
            .padding(.top, 20)
            .onAppear {
                appearanceCount += 1
                UserDefaults.standard.set(appearanceCount, forKey: "appearanceCount")

                print("Appearance Count: \(appearanceCount)")

                // Load insights initially or every 5 appearances
                if appearanceCount % 5 == 0 || savedInsights.isEmpty {
                    if let insights = UserDefaults.standard.object(forKey: "savedInsights") as? [String] {
                        self.savedInsights = insights
                        print("Saved Insights: \(self.savedInsights)")
                    } else {
                        print("No saved insights found in UserDefaults")
                    }
                }
            }
        }
    }
    
    // Enhanced actionButton to handle actions.
    func actionButton(title: String, iconName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: iconName)
                    .font(.system(size: 24))
                Text(title)
                    .fontWeight(.medium)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}

//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView(currentPath: Binding.constant(AppNavigationPath.root), savedInsights: ["test", "test1"])
//    }
//}
