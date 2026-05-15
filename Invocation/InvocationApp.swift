//
//  InvocationApp.swift
//  Invocation
//
//  Created by Elaine Lyons on 2/10/26.
//

import SwiftUI
import SwiftData

@main
struct InvocationApp: App {
    @State private var appState = AppState()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Checklist.self,
            ChecklistItem.self,
            Invocation.self,
            InvocationItem.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
        .modelContainer(sharedModelContainer)
    }
}
