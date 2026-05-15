//
//  ChecklistDetailView.swift
//  Invocation
//

import SwiftUI
import SwiftData

struct ChecklistDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var checklist: Checklist

    @State private var showingEditSheet = false
    @State private var showingAddItemSheet = false
    @State private var navigationPath = NavigationPath()

    var body: some View {
        List {
            Section {
                Toggle("Ordered", isOn: $checklist.isOrdered)
            } footer: {
                Text(checklist.isOrdered
                    ? "Items will be shown one at a time in order"
                    : "All items will be shown at once")
            }

            Section("Items") {
                ForEach(checklist.sortedItems) { item in
                    ChecklistItemRow(item: item)
                }
                .onDelete(perform: deleteItems)
                .onMove(perform: moveItems)

                Button {
                    showingAddItemSheet = true
                } label: {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
        .navigationTitle(checklist.name.isEmpty ? "Untitled" : checklist.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showingEditSheet = true
                    } label: {
                        Label("Edit Template", systemImage: "pencil")
                    }

                    Button {
                        invokeChecklist()
                    } label: {
                        Label("Invoke", systemImage: "play.fill")
                    }
                } label: {
                    Label("More", systemImage: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            ChecklistEditSheet(checklist: checklist)
        }
        .sheet(isPresented: $showingAddItemSheet) {
            ChecklistItemEditSheet(checklist: checklist, item: nil)
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        let sortedItems = checklist.sortedItems
        for index in offsets {
            modelContext.delete(sortedItems[index])
        }
        reorderItems()
    }

    private func moveItems(from source: IndexSet, to destination: Int) {
        var sortedItems = checklist.sortedItems
        sortedItems.move(fromOffsets: source, toOffset: destination)
        for (index, item) in sortedItems.enumerated() {
            item.sortOrder = index
        }
    }

    private func reorderItems() {
        for (index, item) in checklist.sortedItems.enumerated() {
            item.sortOrder = index
        }
    }

    private func invokeChecklist() {
        let invocation = Invocation(
            name: checklist.name,
            isOrdered: checklist.isOrdered,
            sourceChecklistId: checklist.id
        )

        for item in checklist.sortedItems {
            let invocationItem = InvocationItem(
                name: item.name,
                sortOrder: item.sortOrder
            )
            invocation.items.append(invocationItem)
        }

        modelContext.insert(invocation)

        NotificationCenter.default.post(
            name: .didCreateInvocation,
            object: invocation.id
        )
    }
}

extension Notification.Name {
    static let didCreateInvocation = Notification.Name("didCreateInvocation")
}

#Preview {
    NavigationStack {
        ChecklistDetailView(checklist: Checklist(name: "Sample", isOrdered: true))
    }
    .modelContainer(for: Checklist.self, inMemory: true)
}
