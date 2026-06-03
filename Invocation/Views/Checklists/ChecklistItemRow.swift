//
//  ChecklistItemRow.swift
//  Invocation
//

import SwiftUI

struct ChecklistItemRow: View {
    @Bindable var item: ChecklistItem
    var focusedItemID: FocusState<UUID?>.Binding
    var onSubmit: () -> Void

    var body: some View {
        TextField("Item", text: $item.name)
            .focused(focusedItemID, equals: item.id)
            .submitLabel(.next)
            .onSubmit(onSubmit)
    }
}

#Preview {
    @Previewable @FocusState var focusedItemID: UUID?
    List {
        ChecklistItemRow(
            item: ChecklistItem(name: "Sample Item"),
            focusedItemID: $focusedItemID,
            onSubmit: {}
        )
    }
}
