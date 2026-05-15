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
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(checklists) { checklist in
                    ChecklistRow(
                        checklist: checklist,
                        onTap: {
                            if checklist.items.isEmpty {
                                path.append(checklist)
                            } else {
                                invoke(checklist)
                            }
                        },
                        onEdit: { path.append(checklist) }
                    )
                    .contextMenu {
                        Button("Invoke", systemImage: "play.fill") {
                            invoke(checklist)
                        }
                        .disabled(checklist.items.isEmpty)

                        Button("Edit", systemImage: "pencil") {
                            path.append(checklist)
                        }

                        Button("Delete", systemImage: "trash", role: .destructive) {
                            modelContext.delete(checklist)
                        }
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

private struct ChecklistRow: View {
    let checklist: Checklist
    let onTap: () -> Void
    let onEdit: () -> Void

    var body: some View {
        HStack {
            Button(action: onTap) {
                VStack(alignment: .leading) {
                    Text(checklist.name.isEmpty ? "Untitled" : checklist.name)
                    Text("\(checklist.items.count) items")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button(action: onEdit) {
                Image(systemName: "info.circle")
                    .font(.title3)
                    .foregroundStyle(.tint)
            }
            .buttonStyle(.borderless)
            .accessibilityLabel("Edit \(checklist.name.isEmpty ? "Untitled" : checklist.name)")
        }
    }
}

#Preview {
    ChecklistsListView()
        .environment(AppState())
        .modelContainer(for: Checklist.self, inMemory: true)
}
