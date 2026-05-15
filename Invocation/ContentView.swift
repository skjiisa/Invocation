//
//  ContentView.swift
//  Invocation
//
//  Created by Elaine Lyons on 2/10/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var appState = appState

        TabView(selection: $appState.selectedTab) {
            Tab("Active", systemImage: "checklist", value: AppTab.active) {
                InvocationsListView()
            }
            Tab("Templates", systemImage: "doc.on.doc", value: AppTab.templates) {
                ChecklistsListView()
            }
            Tab("History", systemImage: "clock", value: AppTab.history) {
                HistoryListView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
        .modelContainer(for: [Checklist.self, Invocation.self], inMemory: true)
}
