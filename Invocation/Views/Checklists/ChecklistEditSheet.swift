//
//  ChecklistEditSheet.swift
//  Invocation
//

import SwiftUI
import SwiftData

struct ChecklistEditSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let checklist: Checklist?

    @State private var name: String = ""
    @State private var isOrdered: Bool = false

    private var isNewChecklist: Bool { checklist == nil }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)

                Toggle("Ordered", isOn: $isOrdered)
            }
            .navigationTitle(isNewChecklist ? "New Template" : "Edit Template")
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
                if let checklist {
                    name = checklist.name
                    isOrdered = checklist.isOrdered
                }
            }
        }
    }

    private func save() {
        if let checklist {
            checklist.name = name
            checklist.isOrdered = isOrdered
        } else {
            let newChecklist = Checklist(name: name, isOrdered: isOrdered)
            modelContext.insert(newChecklist)
        }
    }
}

#Preview("New") {
    ChecklistEditSheet(checklist: nil)
        .modelContainer(for: Checklist.self, inMemory: true)
}

#Preview("Edit") {
    ChecklistEditSheet(checklist: Checklist(name: "Existing", isOrdered: true))
        .modelContainer(for: Checklist.self, inMemory: true)
}
