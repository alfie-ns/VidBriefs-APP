import SwiftUI
//import SharedSettings

struct HomeView: View { // HomeView
    
    @Binding var currentPath: AppNavigationPath // bind to the currentPath
    @EnvironmentObject var settings: SharedSettings // link to environmental 'settingss' objects

    @State private var savedInsights: [VideoInsight] = [] // array to hold save initial insights conversational data
    @State private var currentRandomInsight: String = "No insights available" // current random insights
    @State private var appearanceCount = 0

    var randomInsight: String {
        if let randomInsight = savedInsights.randomElement() {
            // Assuming the AI's summarization is stored in the 'insight' property
            return randomInsight.insight
        }
        return "No insights available"
    }


    // main body of view
    var body: some View {
        ZStack(alignment: .topTrailing) { // Align content to the top trailing
            
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.customTeal, Color.gray]), // gradient colors with black, teal and gray
                startPoint: .top, // start point for gradient as it goes from top to bottom
                endPoint: .bottom // end
            )
            .edgesIgnoringSafeArea(.all) // ignore safe area edges to fill the screen

            ScrollView { // scroll view to allow for scrolling up && down
                VStack(spacing: 20) { // vertical stack with spacing of 20
                    // Greeting Section
                    VStack { // vertical stack
                        HStack { // horizontal stack
                            Spacer() // Spacer(used to push content to the right side of the screen)
                            Button(action: { // Back button
                                currentPath = .root // set current path to root(back-out of home view)
                            }) {
                                Image(systemName: "arrow.left") // arrow left icon
                                    .foregroundColor(.white) // color white
                                    .font(.system(size: 24)) // font size 24
                            }
                            Spacer() // Spacer (used to push content to the left side of the screen, centering the button horizontally)
                        }
                        .padding(.top, 50) // padding from the top

                        Text("Welcome") // 'Welcome' text
                            .font(.largeTitle) // font size large
                            .fontWeight(.bold) // font weight bold
                            .foregroundColor(.white) // font colour white
                        Text("Under Development...") // 'What would you like to learn about today?' text
                            .foregroundColor(.white) // font colour white
                            .font(.headline) // font type headline

                        // I need to add other things u could press here
                        // - [ ] perhaps another training room they can go more into different things they can leanr. 
                        // - [ ] make AI put all the different summarisations in categorys
                    }
                    .padding(.top, 50) // padding from the top AFTER greeting section

                    Text(LocalizedStringKey(currentRandomInsight)) // show current random insight
                        .padding() // padding first
                        .background(Color.customTeal) // background color teal
                        .opacity(0.75) // opacity 0.75 means 75% visible, 25% transparent
                        .foregroundColor(.white) // font color white
                        .cornerRadius(8) // corner radius 8 this rounds the corners of the view
                }
                .padding() // padding before button
            }

            // Randomize Button
            Button(action: { // action for the button
                self.currentRandomInsight = self.randomInsight // Randomize the current shown insight
            }) {
                Image(systemName: "die.face.2").font(.title) // dice image
            }
            .padding() // padding at the top
            .cornerRadius(20) // corner radius 20 VERY round
            .background(Color.customTeal) // background color teal
            .opacity(0.75) // opacity 0.75 means 75% visible, 25% transparent
            .foregroundColor(.white) // font color white
            .cornerRadius(10) // corner radius 10
            .padding(.trailing, 20) // padding from the trailing edge
            .padding(.top, 20) // padding from the top
            .onAppear {
                appearanceCount += 1
                UserDefaults.standard.set(appearanceCount, forKey: "appearanceCount")
                loadInsights()
                print("Appearance count: \(appearanceCount)")

                if appearanceCount % 5 == 0 || savedInsights.isEmpty {
                    if let savedData = UserDefaults.standard.data(forKey: "savedInsights"),
                       let decodedInsights = try? JSONDecoder().decode([VideoInsight].self, from: savedData) {
                        self.savedInsights = decodedInsights
                        print("Saved Insights: \(self.savedInsights)") // print the saved insights in the consol
                    } else {
                        print("No saved insights found")
                }
            }
        }
    }
}
    
    // Enhanced actionButton function to handle actions.
    func actionButton(title: String, iconName: String, action: @escaping () -> Void) -> some View {
        /*
            Defines a function called actionButton that takes three parameters:
            - title: A String representing the title of the button.
            - iconName: A String representing the name of the icon to display in the button.
            - action: A closure that represents the action to perform when the button is tapped.
            
            The function returns a View that represents the button.
        */
        Button(action: action) { // Button with action
            HStack { // horizontal stack
                Image(systemName: iconName) // image with system name = iconName
                    .font(.system(size: 24)) // font size 24
                Text(title) // title text
                    .fontWeight(.medium) // font weight medium
            }
            .padding() // padding
            .frame(maxWidth: .infinity) // frame with max width = infinity
            .background(Color.blue) // background color blue
            .foregroundColor(.white) // font color white
            .cornerRadius(10) // corner radius 10
        }
    }

    func loadInsights() {
        if let savedData = UserDefaults.standard.data(forKey: "savedInsights"),
        let decodedInsights = try? JSONDecoder().decode([VideoInsight].self, from: savedData) {
            self.savedInsights = decodedInsights
            if let randomInsight = decodedInsights.randomElement() {
                self.currentRandomInsight = randomInsight.insight
            } else {
                self.currentRandomInsight = "No insights available"
            }
        }
    }
}

//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView(currentPath: Binding.constant(AppNavigationPath.root), savedInsights: ["test", "test1"])
//    }
//}
