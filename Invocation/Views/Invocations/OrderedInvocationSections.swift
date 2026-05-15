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
            Section {
                if let nextItem = invocation.nextUncompletedItem {
                    InvocationItemRow(item: nextItem)
                } else {
                    Text("All items completed!")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Current Item")
            } footer: {
                Text("\(invocation.completedItemsCount) of \(invocation.items.count) completed")
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
