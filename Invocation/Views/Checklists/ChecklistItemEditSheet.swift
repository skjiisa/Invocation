//
//  ChecklistItemEditSheet.swift
//  Invocation
//

import SwiftUI
import SwiftData

struct ChecklistItemEditSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let checklist: Checklist
    let item: ChecklistItem?

    @State private var name: String = ""

    private var isNewItem: Bool { item == nil }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
            }
            .navigationTitle(isNewItem ? "New Item" : "Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let item {
                    name = item.name
                }
            }
        }
    }

    private func save() {
        if let item {
            item.name = name
        } else {
            let newItem = ChecklistItem(
                name: name,
                sortOrder: checklist.items.count
            )
            checklist.items.append(newItem)
        }
    }
}

#Preview("New") {
    ChecklistItemEditSheet(checklist: Checklist(name: "Test"), item: nil)
        .modelContainer(for: Checklist.self, inMemory: true)
}

#Preview("Edit") {
    ChecklistItemEditSheet(
        checklist: Checklist(name: "Test"),
        item: ChecklistItem(name: "Existing Item")
    )
    .modelContainer(for: Checklist.self, inMemory: true)
}
