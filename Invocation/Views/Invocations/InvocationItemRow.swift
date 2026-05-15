//
//  InvocationItemRow.swift
//  Invocation
//

import SwiftUI

struct InvocationItemRow: View {
    @Bindable var item: InvocationItem
    var isReadOnly: Bool = false

    var body: some View {
        Button {
            if !isReadOnly {
                item.isCompleted.toggle()
            }
        } label: {
            HStack {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.isCompleted ? .green : .secondary)
                    .imageScale(.large)

                Text(item.name.isEmpty ? "Untitled" : item.name)
                    .foregroundStyle(item.isCompleted ? .secondary : .primary)
                    .strikethrough(item.isCompleted)
            }
        }
        .disabled(isReadOnly)
        .buttonStyle(.plain)
    }
}

#Preview {
    List {
        InvocationItemRow(item: InvocationItem(name: "Incomplete Item"))
        InvocationItemRow(item: {
            let item = InvocationItem(name: "Completed Item")
            item.isCompleted = true
            return item
        }())
    }
}
