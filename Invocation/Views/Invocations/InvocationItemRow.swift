//
//  InvocationItemRow.swift
//  Invocation
//

import SwiftUI

struct InvocationItemRow: View {
    @Bindable var item: InvocationItem
    var isReadOnly: Bool = false
    var onToggle: (() -> Void)?

    var body: some View {
        Button {
            onToggle?()
            withAnimation(.snappy(duration: 0.25)) {
                item.isCompleted.toggle()
            }
        } label: {
            HStack {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.isCompleted ? .green : .secondary)
                    .imageScale(.large)
                    .contentTransition(.symbolEffect(.replace))

                Text(item.name.isEmpty ? "Untitled" : item.name)
                    .foregroundStyle(item.isCompleted ? .secondary : .primary)
                    .strikethrough(item.isCompleted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .disabled(isReadOnly)
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: item.isCompleted)
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
