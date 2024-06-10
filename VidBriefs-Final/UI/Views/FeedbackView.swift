//
//  FeedbackView.swift
//  Youtube-Summarizer
//
//  Created by Alfie Nurse on 02/09/2023.
//

import SwiftUI
import MessageUI
// Import SwiftUI for building the user interface
// Import MessageUI for sending feedback via email

struct FeedbackView: View {
    
    @Binding var currentPath: AppNavigationPath // Binds the current navigation path
    
    @State private var feedbackText: String = "" // State variable to store the feedback text
    @State private var isShowingMailView: Bool = false // State variable to show the mail view, starts as false
    @State private var alertNoMail = false // State variable to show alert if no mail accounts are set up
    @State private var result: Result<MFMailComposeResult, Error>? = nil // State variable to store the result of sending feedback, starts as nil
    @State private var showThankYouAlert = false // State variable to show thank you alert, starts as false

    
    var body: some View { // Body of the view
        ZStack { // ZStack for layering views
            // Your background setup
            LinearGradient(gradient: Gradient(colors: [Color.mint, Color.gray]), startPoint: .top, endPoint: .bottom) // Gradient background
            
            VStack(alignment: .leading, spacing: 16) { // Vertical stack with leading alignment and spacing of 16
                Button(action: { // Back button action
                    currentPath = .settings // Navigates back to the settings screen
                }) { // Back button visual
                    Image(systemName: "arrow.left") // Back arrow icon
                        .foregroundColor(.white) // White color
                        .font(.system(size: 24)) // Font size 24
                        .padding() // Adds padding
                }
                
                Text("Feedback") // Title
                    .font(.largeTitle) // Large title font
                    .fontWeight(.bold) // Bold weight
                    .padding(.top, 5) // Adds top padding of 5
                    .foregroundColor(.white) // White color
                
                Text("Share your feedback! Help improve the app by suggesting ideas, features, and fixes!") // Description
                    .font(.subheadline) // Subheadline font
                    .fontWeight(.bold) // Bold weight
                    .padding(.top, 5) // Adds top padding of 5
                    .foregroundColor(.white) // White color

                
                TextEditor(text: $feedbackText) 
                    .frame(height: 200)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.secondary, lineWidth: 1)
                    )
                    .padding()
                
                Button("Send Feedback") {
                    self.sendFeedback()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .alert(isPresented: $alertNoMail) {
            Alert(title: Text("No Mail Accounts"), message: Text("Please set up a Mail account in order to send feedback."), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $isShowingMailView) {
            if MFMailComposeViewController.canSendMail() {
                MailView(isShowing: self.$isShowingMailView, result: self.$result, feedbackText: self.feedbackText)
            } else {
                Text("Unable to send emails from this device")
            }
        }
    }
    
    func sendFeedback() {
        if MFMailComposeViewController.canSendMail() {
            self.isShowingMailView = true
        } else {
            self.alertNoMail = true
        }
    }
}

// Helper struct to integrate MFMailComposeViewController with SwiftUI
struct MailView: UIViewControllerRepresentable {
    @Binding var isShowing: Bool
    @Binding var result: Result<MFMailComposeResult, Error>?
    var feedbackText: String
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var isShowing: Bool
        @Binding var result: Result<MFMailComposeResult, Error>?
        
        init(isShowing: Binding<Bool>, result: Binding<Result<MFMailComposeResult, Error>?>) {
            _isShowing = isShowing
            _result = result
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            defer {
                isShowing = false
            }
            guard error == nil else {
                self.result = .failure(error!)
                return
            }
            self.result = .success(result)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(isShowing: $isShowing, result: $result)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients(["alfienurse@gmail.com"])
        vc.setSubject("App Feedback")
        vc.setMessageBody(feedbackText, isHTML: false)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: UIViewControllerRepresentableContext<MailView>) {
        // No update currently needed
    }
}
