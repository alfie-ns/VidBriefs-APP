//
//  SettingsView.swift
//  Youtube-Summarizer
//
//  Created by Alfie Nurse on 02/09/2023.
//

import SwiftUI
import AVKit

struct SettingsView: View {
    
    @EnvironmentObject var settings: SharedSettings
    
    @Binding var currentPath: AppNavigationPath
    
    // Variables for managing different settings functionalities
    @State private var showLogoutAlert: Bool = false
    
    @State private var navigateToLandingView: Bool = false
    
    @State private var showTermsAlert: Bool = false
    
    @State private var showAPIKeyPopup: Bool = false
    
    // @State private var openai_apikey: String = UserDefaults.standard.string(forKey: "openai_apikey") ?? ""
    
    @State private var showingVideoPlayer: Bool = false
    
   

    
    var body: some View {
        
        
        ZStack {
            
            LinearGradient(gradient: Gradient(colors: [Color.gray, Color.customTeal]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            ZStack {
                ZStack {
                    VStack {
                        VStack(spacing: 20) {
                            VStack {// Title Section
                                Text("Settings")
                                    .font(.largeTitle) // large title font
                                    .fontWeight(.bold) // bold font
                                    .foregroundColor(Color.white)
                            }.padding(.top, 50)
                            
                            // Settings Action Buttons
                            VStack(spacing: 15) {
                                
                                // SAVE FOR DEVELOPER MODE
                                
//                                ZStack {
//                                    actionButton(title: "Change API Key", iconName: "wrench.fill", action: {
//                                        if termsAccepted {
//                                            showAPIKeyPopup = true
//                                        } else {
//                                            showTermsAlert = true
//                                        }
//                                    })
//                                    
//                                    Button(action: {
//                                        showingVideoPlayer = true // Trigger the video player presentation
//                                    }) {
//                                        Image(systemName: "questionmark.circle.fill") // question mark image
//                                            .font(.system(size: 24)) // size 24 system font
//                                            .foregroundColor(.white) // make colour white
//                                    }
//                                    .padding(.leading, 245)
//                                    
//                                    
//                                    .sheet(isPresented: $showingVideoPlayer) { // Presents the video player sheet when showingVideoPlayer is true
//                                        VideoPlayerView(videoName: "ApiKeyDemo2", videoType: "mov")
//                                    }
//                                }
                                
                                actionButton(title: "Terms and Conditions", iconName: "shield.lefthalf.fill", action: {
                                    currentPath = .terms
                                })
                                actionButton(title: "Feedback", iconName: "bubble.left.fill", action: {
                                    currentPath = .feedback
                                })
                                actionButton(title: "About", iconName: "info.circle.fill", action: {
                                    currentPath = .about
                                })
                                
                            }
                            .padding(.horizontal)
                            .alert(isPresented: $showTermsAlert) {
                                Alert(
                                    title: Text("Terms and Conditions Required"),
                                    message: Text("Please review and accept the terms and conditions to use **VidBriefs**"),
                                    dismissButton: .default(Text("OK"))
                                )
                            }
                            
                            
                            // Push content to the top
                            Text("Welcome to **VidBriefs**\n\nDive into the heart of long videos with **GPT-4** swiftly pinpointing and encapsulating **key points tailored to your interests.** Embrace clarity and insight in every video, the end of **clickbait!**")
                                .padding()
                                .font(.footnote)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(Color.customTeal.opacity(0.7))
                                .cornerRadius(12)
                                .padding(.horizontal)
                            
                        }
                        .padding()
                        .navigationBarBackButtonHidden(true)
                        
                    } // End of navigation view
                    
                    
                    // Popup Textbox for API Key
//                    if showAPIKeyPopup {
//                        VStack {
//                            TextField("Enter New API Key", text: $openai_apikey) // Text from the input
//                                .textFieldStyle(RoundedBorderTextFieldStyle()) // Rounded border text field
//                                .padding() // given it's own paddings
//                                .disabled(!termsAccepted) // termsAccept
//                            
//                            Button("Enter") {
//                                UserDefaults.standard.setValue(openai_apikey, forKey: "openai_apikey")
//                                print("New API Key: \(openai_apikey)")
//                                showAPIKeyPopup = false
//                                @EnvironmentObject var appEnvironment: AppEnvironment
//                                appEnvironment.shouldRestart = true
//                                
//                            }
//                        }
//                        .frame(width: 300, height: 150)
//                        .background(Color.white)
//                        .cornerRadius(20)
//                        .shadow(radius: 20)
//                    }
                }
            }
        }
    }
    
    // Action Button View
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
                .background(Color.customTeal.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        
        func handleLogout(){
            currentPath = .root
            print("currentPath set to rootview")
        }
    }

struct VideoPlayerView: View {
    var videoName: String
    var videoType: String // "mov" or "mp4"
    
    var body: some View {
        // Attempt to get the URL for the video
        guard let videoURL = Bundle.main.url(forResource: videoName, withExtension: videoType) else {
            // If the video URL is nil, show an error message
            return Text("Unable to find \(videoName).\(videoType) in the app bundle.").toAnyView()
        }
        // Use AVPlayer to play the video
        let player = AVPlayer(url: videoURL)
        return VideoPlayer(player: player)
            .onAppear {
                player.play() // Play the video when the view appears
            }
            .toAnyView()
    }
}

// Extension to convert View to AnyView
extension View {
    func toAnyView() -> AnyView { AnyView(self) }
}


