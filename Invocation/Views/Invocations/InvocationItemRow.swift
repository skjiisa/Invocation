//
//  InvocationItemRow.swift
//  Invocation
//

import SwiftUI

struct InvocationItemRow: View {
    /// Visual weighting for an item within an ordered invocation.
    enum Emphasis {
        /// Default treatment (unordered items, completed items).
        case normal
        /// The next item to act on — drawn prominently.
        case next
        /// A later step in the queue — dimmed and de-emphasized.
        case upcoming
    }

    @Bindable var item: InvocationItem
    var isReadOnly: Bool = false
    var emphasis: Emphasis = .normal
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
                    .foregroundStyle(circleColor)
                    .imageScale(.large)
                    .contentTransition(.symbolEffect(.replace))

                Text(item.name.isEmpty ? "Untitled" : item.name)
                    .font(.body)
                    .fontWeight(emphasis == .next ? .semibold : .regular)
                    .foregroundStyle(textColor)
                    .strikethrough(item.isCompleted)
                    .contentTransition(emphasis == .next ? .numericText() : .identity)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .disabled(isReadOnly)
        .buttonStyle(.plain)
        .opacity(emphasis == .upcoming ? 0.7 : 1)
        .sensoryFeedback(.selection, trigger: item.isCompleted)
    }

    private var circleColor: Color {
        if item.isCompleted { return .green }
        return emphasis == .next ? .accentColor : .secondary
    }

    private var textColor: Color {
        if item.isCompleted || emphasis == .upcoming { return .secondary }
        return .primary
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
