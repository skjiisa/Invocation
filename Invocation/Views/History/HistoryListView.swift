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
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(invocation.name.isEmpty ? "Untitled" : invocation.name)
                                Spacer()
                                StatusBadgeView(status: invocation.status)
                            }
                            HStack {
                                Text("\(invocation.completedItemsCount) of \(invocation.items.count) completed")
                                Spacer()
                                Text(
                                    invocation.completedAt ?? invocation.createdAt,
                                    format: .dateTime.day().month().year().hour().minute()
                                )
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
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
