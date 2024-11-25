//
//  ContentView.swift
//  aura
//
//  Created by Ishan Ramrakhiani on 11/22/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
            
            IndustryExplorerView()
                .tabItem {
                    Label("Industries", systemImage: "building.2.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    ContentView()
}
