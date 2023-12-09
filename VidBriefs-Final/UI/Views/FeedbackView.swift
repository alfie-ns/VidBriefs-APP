//
//  FeedbackView.swift
//  Youtube-Summarizer
//
//  Created by Alfie Nurse on 02/09/2023.
//

import SwiftUI
import MessageUI

struct FeedbackView: View {
    
    @Binding var currentPath: AppNavigationPath
    
    @State private var feedbackText: String = ""
    @State private var isShowingMailView: Bool = false
    @State private var alertNoMail = false
    @State private var result: Result<MFMailComposeResult, Error>? = nil
    @State private var showThankYouAlert = false

    
    var body: some View {
        ZStack {
            // Your background setup
            LinearGradient(gradient: Gradient(colors: [Color.mint, Color.gray]), startPoint: .top, endPoint: .bottom)

            // Your other background layers...
            
            VStack(alignment: .leading, spacing: 16) {
                Button(action: {
                    currentPath = .settings
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                        .padding()
                }
                
                Text("Feedback")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 5)
                    .foregroundColor(.white)
                
                Text("Share your feedback! Help improve the app by suggesting ideas, features, and fixes!")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .padding(.top, 5)
                    .foregroundColor(.white)

                
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
