//
//  InvocationDetailView.swift
//  Invocation
//

import SwiftUI
import SwiftData

struct InvocationDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var invocation: Invocation

    var isReadOnly: Bool = false

    var body: some View {
        List {
            if invocation.isOrdered {
                orderedContent
            } else {
                unorderedContent
            }

            if !isReadOnly && invocation.status == .active {
                actionsSection
            }
        }
        .navigationTitle(invocation.name.isEmpty ? "Untitled" : invocation.name)
        .toolbar {
            if !isReadOnly && invocation.status == .active {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(role: .destructive) {
                            archiveInvocation()
                        } label: {
                            Label("Archive", systemImage: "archivebox")
                        }
                    } label: {
                        Label("More", systemImage: "ellipsis.circle")
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var orderedContent: some View {
        Section {
            if let nextItem = invocation.nextUncompletedItem {
                InvocationItemRow(item: nextItem, isReadOnly: isReadOnly)
            } else {
                Text("All items completed!")
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Current Item")
        } footer: {
            Text("\(invocation.completedItemsCount) of \(invocation.items.count) completed")
        }

        Section("Completed") {
            ForEach(invocation.sortedItems.filter { $0.isCompleted }) { item in
                InvocationItemRow(item: item, isReadOnly: true)
            }
        }
    }

    @ViewBuilder
    private var unorderedContent: some View {
        Section {
            ForEach(invocation.sortedItems) { item in
                InvocationItemRow(item: item, isReadOnly: isReadOnly)
            }
        } footer: {
            Text("\(invocation.completedItemsCount) of \(invocation.items.count) completed")
        }
    }

    @ViewBuilder
    private var actionsSection: some View {
        if invocation.allItemsCompleted {
            Section {
                Button {
                    completeInvocation()
                } label: {
                    Label("Mark Complete", systemImage: "checkmark.circle.fill")
                }
                .foregroundStyle(.green)
            }
        }
    }

    private func completeInvocation() {
        invocation.markComplete()
        dismiss()
    }

    private func archiveInvocation() {
        invocation.archive()
        dismiss()
    }
}

#Preview("Ordered") {
    let invocation = Invocation(name: "Sample", isOrdered: true)
    invocation.items = [
        InvocationItem(name: "First", sortOrder: 0),
        InvocationItem(name: "Second", sortOrder: 1),
        InvocationItem(name: "Third", sortOrder: 2)
    ]

    return NavigationStack {
        InvocationDetailView(invocation: invocation)
    }
    .modelContainer(for: Invocation.self, inMemory: true)
}

#Preview("Unordered") {
    let invocation = Invocation(name: "Sample", isOrdered: false)
    invocation.items = [
        InvocationItem(name: "First", sortOrder: 0),
        InvocationItem(name: "Second", sortOrder: 1),
        InvocationItem(name: "Third", sortOrder: 2)
    ]

    return NavigationStack {
        InvocationDetailView(invocation: invocation)
    }
    .modelContainer(for: Invocation.self, inMemory: true)
}
