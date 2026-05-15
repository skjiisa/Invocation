//
//  InvocationsListView.swift
//  Invocation
//

import SwiftUI
import SwiftData

struct InvocationsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Query(
        filter: #Predicate<Invocation> { $0.statusRawValue == "active" },
        sort: \Invocation.createdAt,
        order: .reverse
    ) private var invocations: [Invocation]

    var body: some View {
        @Bindable var appState = appState

        NavigationStack(path: $appState.activeTabPath) {
            List {
                ForEach(invocations) { invocation in
                    NavigationLink(value: invocation) {
                        VStack(alignment: .leading) {
                            Text(invocation.name.isEmpty ? "Untitled" : invocation.name)
                            Text("\(invocation.completedItemsCount) of \(invocation.items.count) completed")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button("Archive", systemImage: "archivebox") {
                            invocation.archive()
                        }
                        .tint(.orange)
                    }
                }
                .onDelete(perform: deleteInvocations)
            }
            .navigationTitle("Active")
            .navigationDestination(for: Invocation.self) { invocation in
                InvocationDetailView(invocation: invocation)
            }
            .overlay {
                if invocations.isEmpty {
                    ContentUnavailableView(
                        "No Active Invocations",
                        systemImage: "checklist.checked",
                        description: Text("Invoke a template to get started")
                    )
                }
            }
        }
    }

    private func deleteInvocations(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(invocations[index])
        }
    }
}

#Preview {
    InvocationsListView()
        .environment(AppState())
        .modelContainer(for: Invocation.self, inMemory: true)
}
