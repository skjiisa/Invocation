//
//  OrderedInvocationSections.swift
//  Invocation
//

import SwiftUI

struct OrderedInvocationSections: View {
    let invocation: Invocation
    var isReadOnly: Bool = false

    var body: some View {
        if isReadOnly {
            Section {
                ForEach(invocation.sortedItems) { item in
                    InvocationItemRow(item: item, isReadOnly: true)
                }
            } footer: {
                Text("\(invocation.completedItemsCount) of \(invocation.items.count) completed")
            }
        } else {
            let remaining = invocation.sortedItems.filter { !$0.isCompleted }

            Section {
                if let nextItem = remaining.first {
                    InvocationItemRow(item: nextItem, emphasis: .next)
                } else {
                    Text("All items completed!")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Up Next")
            } footer: {
                Text("\(invocation.completedItemsCount) of \(invocation.items.count) completed")
            }

            let later = Array(remaining.dropFirst())
            if !later.isEmpty {
                Section("Then") {
                    ForEach(later) { item in
                        InvocationItemRow(item: item, isReadOnly: true, emphasis: .upcoming)
                    }
                }
            }

            if !invocation.completedItems.isEmpty {
                Section("Completed") {
                    ForEach(invocation.completedItems) { item in
                        InvocationItemRow(item: item, isReadOnly: true)
                    }
                }
            }
        }
    }
}
