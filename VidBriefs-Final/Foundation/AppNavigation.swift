/*
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
    
    
    
*/

import SwiftUI

@MainActor
struct AppNavigation: View { // main struct for the app navigation
    
    // State variable to track the current navigation path
    @State private var currentPath: AppNavigationPath = .root
    
    var body: some View {
        ZStack { // ZStack overlays views, allowing conditional navigation views to be layered
            if AppNavigationPath.tabs.contains(currentPath) { 
                // If the current path corresponds to a tab, create the tab view, creatomg a tab 
                createTabView() // setting up this entire tabbed interface structure for the respective view/
            } else {
                // Otherwise, create the corresponding view for the current path
                createView(for: currentPath)
            }
            // In a TabView, only one tab's content (Home, Insights, Library, Settings, Terms, Feedback, TedTalks)
            // is visible at a time. Switching tabs replaces the visible content entirely.
            // Views like 'about' that aren't in the tab bar would be navigated to separately,
            // typically pushing onto a navigation stack rather than being part of the TabView.
        }
        .background(Color.customTeal) // Set background color
        .edgesIgnoringSafeArea(.all) // Extend background to cover the entire screen
    }
    
    // Function to create the tab view for paths in the `tabs` list
    @ViewBuilder
    private func createTabView() -> some View {
        TabView(selection: $currentPath) { // TabView binding to `currentPath`
            ForEach(AppNavigationPath.tabs, id: \.self) { path in
                // Iterate over all tab paths, creating a view for each
                createView(for: path)
                    .tabItem {
                        // Set the tab's label and icon based on the enum's properties
                        Label(path.tabLabel, systemImage: path.tabIcon)
                    }
                    .tag(path) // Tag the tab item with its corresponding path
            }
        }
        .tabViewStyle(PageTabViewStyle()) // Use the page style for tabs
        .edgesIgnoringSafeArea(.all) // Ensure the tab view covers the entire screen
    }
    
    // Function to create the corresponding view for a given path
    @ViewBuilder
    private func createView(for path: AppNavigationPath) -> some View {
        switch path {
        case .root:
            RootView(currentPath: $currentPath) // Root view
        case .home:
            HomeView(currentPath: $currentPath) // Home view
        case .insights:
            InsightView(currentPath: $currentPath) // Insights view
        case .libary:
            LibraryView(currentPath: $currentPath) // Library view
        case .settings:
            SettingsView(currentPath: $currentPath) // Settings view
        case .about:
            AboutView(currentPath: $currentPath) // About view
        case .terms:
            TermsView(currentPath: $currentPath) // Terms view
        case .feedback:
            FeedbackView(currentPath: $currentPath) // Feedback view
        case .tedtalks:
            TedTalkView(currentPath: $currentPath) // TedTalks view
        default:
            EmptyView() // Handle unexpected paths gracefully
        }
    }
}

// Enum defining different navigation paths, conforming to `Hashable` for use in SwiftUI
enum AppNavigationPath: Hashable {
    case root, home, insights, libary, settings, about, terms, feedback, tedtalks

    // Static array of paths that should appear in the TabView
    static let tabs: [AppNavigationPath] = [.home, .insights, .libary, .settings]

    // Computed property to return the label for each tab
    var tabLabel: String {
        switch self {
        case .home: return "Home"
        case .insights: return "Insights"
        case .libary: return "Library"
        case .settings: return "Settings"
        default: return ""
        }
    }

    // Computed property to return the system image name for each tab's icon
    var tabIcon: String {
        switch self {
        case .home: return "house.fill"
        case .insights: return "lightbulb"
        case .libary: return "books.vertical"
        case .settings: return "gear"
        default: return ""
        }
    }
}
