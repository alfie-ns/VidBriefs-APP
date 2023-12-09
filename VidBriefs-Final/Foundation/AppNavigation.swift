//
//  AppNavigator.swift
//  Youtube-Summarizer
//
//  Created by Alfie Nurse  on 02/09/2023.
//


import SwiftUI

@MainActor
struct AppNavigation: View {
    
    @State private var currentPath: AppNavigationPath = .root
    
    var body: some View {
        
        ZStack {

            if currentPath == .home || currentPath == .libary || currentPath == .settings || currentPath == .insights {
                
                // TabView
                TabView(selection: $currentPath) {
                    HomeView(currentPath: $currentPath)
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                        .tag(AppNavigationPath.home)
                    
                    InsightView(currentPath: $currentPath)
                        .tabItem {
                            Label("Insights", systemImage: "lightbulb")
                        }
                        .tag(AppNavigationPath.insights)
                    
                    LibraryView(currentPath: $currentPath)
                        .tabItem {
                            Label("Library", systemImage: "books.vertical")
                        }
                        .tag(AppNavigationPath.libary)
                    
                    SettingsView(currentPath: $currentPath)
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                        .tag(AppNavigationPath.settings)
                }
                .tabViewStyle(PageTabViewStyle())
                .edgesIgnoringSafeArea(.all)
                
            } else {
                switch currentPath {
                case .root:
                    RootView(currentPath: $currentPath)
                case .about:
                    AboutView(currentPath: $currentPath)
                case .terms:
                    TermsView(currentPath: $currentPath)
                case .feedback:
                    FeedbackView(currentPath: $currentPath)
                default:
                    EmptyView()
                }
            }
            
            
        }
        .background(Color.customTeal)
        .edgesIgnoringSafeArea(.all)
    }
    }



    
    enum AppNavigationPath: Hashable {
        case root
        case register
        case login
        case settings
        case home
        case insights
        case libary
        case about
        case terms
        case feedback
        case donate
    }
    
    // Actions to represent navigation events.
    struct RegisterAction: Identifiable, Hashable {
        let id = UUID()
    }
    
    struct LoginAction: Identifiable, Hashable {
        let id = UUID()
    }
    
    
    struct SettingsAction: Identifiable, Hashable {
        let id = UUID()
    }
    
    
    

