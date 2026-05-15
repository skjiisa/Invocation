//
//  InvocationDetailView.swift
//  Invocation
//

import SwiftUI
import SwiftData

struct InvocationDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var invocation: Invocation
    var isReadOnly: Bool = false

    var body: some View {
        List {
            if invocation.isOrdered {
                OrderedInvocationSections(invocation: invocation, isReadOnly: isReadOnly)
            } else {
                UnorderedInvocationSections(invocation: invocation, isReadOnly: isReadOnly)
            }

            if !isReadOnly && invocation.status == .active {
                InvocationActionsSection(invocation: invocation)
            }
        }
        .navigationTitle(invocation.name.isEmpty ? "Untitled" : invocation.name)
        .toolbar {
            if !isReadOnly && invocation.status == .active {
                ToolbarItem(placement: .primaryAction) {
                    Menu("More", systemImage: "ellipsis.circle") {
                        Button("Archive", systemImage: "archivebox", action: archiveInvocation)
                    }
                }
            }
        }
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
