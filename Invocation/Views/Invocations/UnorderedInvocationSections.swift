//
//  UnorderedInvocationSections.swift
//  Invocation
//

import SwiftUI

struct UnorderedInvocationSections: View {
    let invocation: Invocation
    var isReadOnly: Bool = false

    var body: some View {
        Section {
            ForEach(invocation.sortedItems) { item in
                InvocationItemRow(item: item, isReadOnly: isReadOnly)
            }
        } footer: {
            Text("\(invocation.completedItemsCount) of \(invocation.items.count) completed")
        }
    }
}
