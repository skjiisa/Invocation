//
//  HistoryListView.swift
//  Invocation
//

import SwiftUI
import SwiftData

struct HistoryListView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(
        filter: #Predicate<Invocation> { $0.statusRawValue != "active" },
        sort: \Invocation.createdAt,
        order: .reverse
    ) private var invocations: [Invocation]

    var body: some View {
        NavigationStack {
            List {
                ForEach(invocations) { invocation in
                    NavigationLink(value: invocation) {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(invocation.name.isEmpty ? "Untitled" : invocation.name)

                                Spacer()

                                statusBadge(for: invocation)
                            }

                            if let completedAt = invocation.completedAt {
                                Text(completedAt, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text(invocation.createdAt, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteInvocations)
            }
            .navigationTitle("History")
            .navigationDestination(for: Invocation.self) { invocation in
                InvocationDetailView(invocation: invocation, isReadOnly: true)
            }
            .overlay {
                if invocations.isEmpty {
                    ContentUnavailableView(
                        "No History",
                        systemImage: "clock",
                        description: Text("Completed and archived invocations will appear here")
                    )
                }
            }
        }
    }

    @ViewBuilder
    private func statusBadge(for invocation: Invocation) -> some View {
        switch invocation.status {
        case .completed:
            Label("Completed", systemImage: "checkmark.circle.fill")
                .labelStyle(.iconOnly)
                .foregroundStyle(.green)
        case .archived:
            Label("Archived", systemImage: "archivebox.fill")
                .labelStyle(.iconOnly)
                .foregroundStyle(.orange)
        case .active:
            EmptyView()
        }
    }

    private func deleteInvocations(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(invocations[index])
        }
    }
}

#Preview {
    HistoryListView()
        .modelContainer(for: Invocation.self, inMemory: true)
}
