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
struct AppNavigation: View {
    @State private var currentPath: AppNavigationPath = .root
    @State private var showingTedTalkView = false

    var body: some View {
        NavigationView {
            ZStack {
                if AppNavigationPath.tabs.contains(currentPath) {
                    createTabView()
                } else {
                    createView(for: currentPath)
                }
            }
            .background(Color.customTeal)
            .edgesIgnoringSafeArea(.all)
            .fullScreenCover(isPresented: $showingTedTalkView) {
                TedTalkView(currentPath: $currentPath)
            }
        }
    }

    @ViewBuilder
    private func createTabView() -> some View {
        TabView(selection: $currentPath) {
            ForEach(AppNavigationPath.tabs, id: \.self) { path in
                createView(for: path)
                    .tabItem {
                        Label(path.tabLabel, systemImage: path.tabIcon)
                    }
                    .tag(path)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .edgesIgnoringSafeArea(.all)
    }

    @ViewBuilder
    private func createView(for path: AppNavigationPath) -> some View {
        switch path {
        case .root:
            RootView(currentPath: $currentPath)
        case .home:
            HomeView(currentPath: $currentPath)
        case .insights:
            InsightView(currentPath: $currentPath)
        case .libary:
            LibraryView(currentPath: $currentPath)
        case .settings:
            SettingsView(currentPath: $currentPath)
        case .about:
            AboutView(currentPath: $currentPath)
        case .terms:
            TermsView(currentPath: $currentPath)
        case .feedback:
            FeedbackView(currentPath: $currentPath)
        case .tedtalks:
            Button("Open TED Talks") {
                showingTedTalkView = true
            }
        default:
            EmptyView()
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
