//
//  ContentView.swift
//  Invocation
//
//  Created by Elaine Lyons on 2/10/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            InvocationsListView()
                .tabItem {
                    Label("Active", systemImage: "checklist")
                }
                .tag(0)

            ChecklistsListView()
                .tabItem {
                    Label("Templates", systemImage: "doc.on.doc")
                }
                .tag(1)

            HistoryListView()
                .tabItem {
                    Label("History", systemImage: "clock")
                }
                .tag(2)
        }
        .onReceive(NotificationCenter.default.publisher(for: .didCreateInvocation)) { _ in
            selectedTab = 0
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Checklist.self, Invocation.self], inMemory: true)
}
