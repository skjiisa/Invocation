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
            let nextItem = remaining.first

            Section {
                UpNextRow(nextItem: nextItem)
            } header: {
                Text("Up Next")
            } footer: {
                Text("\(invocation.completedItemsCount) of \(invocation.items.count) completed")
            }

            // The full list below shows every item — including a dimmed copy of
            // the promoted "Up Next" item — in fixed order. Keeping membership and
            // order stable means completing or undoing anything out of sequence
            // only morphs that row's color/symbol/opacity in place; nothing shifts.
            if !invocation.items.isEmpty {
                Section {
                    ForEach(invocation.sortedItems) { item in
                        InvocationItemRow(item: item, emphasis: item.isCompleted ? .normal : .upcoming)
                    }
                }
            }
        }
    }
}

/// The "Up Next" hero row. Renders the next item's title — or the completion
/// message when nothing remains — through a single `Text`, so the numeric-text
/// transition carries smoothly from the last item into "All items completed!".
private struct UpNextRow: View {
    var nextItem: InvocationItem?

    private var title: String {
        guard let nextItem else { return "All items completed!" }
        return nextItem.name.isEmpty ? "Untitled" : nextItem.name
    }

    var body: some View {
        Button {
            guard let nextItem else { return }
            withAnimation(.snappy(duration: 0.25)) {
                nextItem.isCompleted.toggle()
            }
        } label: {
            HStack {
                Image(systemName: nextItem == nil ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(nextItem == nil ? Color.green : .accentColor)
                    .imageScale(.large)
                    .contentTransition(.symbolEffect(.replace))

                Text(title)
                    .fontWeight(nextItem == nil ? .regular : .semibold)
                    .foregroundStyle(nextItem == nil ? Color.secondary : .primary)
                    .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(nextItem == nil)
        .sensoryFeedback(.selection, trigger: nextItem?.isCompleted ?? false)
    }
}
