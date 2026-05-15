//
//  ChecklistsListView.swift
//  Invocation
//

import SwiftUI
import SwiftData

struct ChecklistsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Query(sort: \Checklist.createdAt, order: .reverse) private var checklists: [Checklist]

    @State private var showingNewChecklistSheet = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(checklists) { checklist in
                    NavigationLink(value: checklist) {
                        VStack(alignment: .leading) {
                            Text(checklist.name.isEmpty ? "Untitled" : checklist.name)
                            Text("\(checklist.items.count) items")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button("Invoke", systemImage: "play.fill") {
                            invoke(checklist)
                        }
                        .tint(.green)
                        .disabled(checklist.items.isEmpty)
                    }
                }
                .onDelete(perform: deleteChecklists)
            }
            .navigationTitle("Templates")
            .navigationDestination(for: Checklist.self) { checklist in
                ChecklistDetailView(checklist: checklist)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("New Template", systemImage: "plus") {
                        showingNewChecklistSheet = true
                    }
                }
            }
            .sheet(isPresented: $showingNewChecklistSheet) {
                ChecklistEditSheet(checklist: nil)
            }
            .overlay {
                if checklists.isEmpty {
                    ContentUnavailableView(
                        "No Templates",
                        systemImage: "checklist",
                        description: Text("Create a template to get started")
                    )
                }
            }
        }
    }

    private func deleteChecklists(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(checklists[index])
        }
    }

    private func invoke(_ checklist: Checklist) {
        let invocation = Invocation.from(checklist)
        modelContext.insert(invocation)
        appState.selectedTab = .active
    }
}

#Preview {
    ChecklistsListView()
        .environment(AppState())
        .modelContainer(for: Checklist.self, inMemory: true)
}
