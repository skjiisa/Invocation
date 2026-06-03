//
//  ChecklistDetailView.swift
//  Invocation
//

import SwiftUI
import SwiftData

struct ChecklistDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Bindable var checklist: Checklist

    @State private var showingEditSheet = false
    @FocusState private var focusedItemID: UUID?

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
                    ChecklistItemRow(
                        item: item,
                        focusedItemID: $focusedItemID,
                        onSubmit: addItem
                    )
                }
                .onDelete(perform: deleteItems)
                .onMove(perform: moveItems)

                Button("Add Item", systemImage: "plus", action: addItem)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .onChange(of: focusedItemID) { oldValue, _ in
            removeEmptyItem(id: oldValue)
        }
        .navigationTitle(checklist.name.isEmpty ? "Untitled" : checklist.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu("More", systemImage: "ellipsis.circle") {
                    Button("Edit Template", systemImage: "pencil") {
                        showingEditSheet = true
                    }
                    Button("Invoke", systemImage: "play.fill", action: invokeChecklist)
                        .disabled(checklist.items.isEmpty)
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            ChecklistEditSheet(checklist: checklist)
        }
    }

    private func addItem() {
        let newItem = ChecklistItem(name: "", sortOrder: checklist.items.count)
        withAnimation {
            checklist.items.append(newItem)
        }
        focusedItemID = newItem.id
    }

    private func removeEmptyItem(id: UUID?) {
        guard let id,
              let item = checklist.items.first(where: { $0.id == id }),
              item.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else { return }
        withAnimation {
            checklist.items.removeAll { $0.id == id }
            modelContext.delete(item)
            reorderItems()
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
        let invocation = Invocation.from(checklist)
        modelContext.insert(invocation)
        appState.selectedTab = .active
    }
}

#Preview {
    NavigationStack {
        ChecklistDetailView(checklist: Checklist(name: "Sample", isOrdered: true))
    }
    .environment(AppState())
    .modelContainer(for: Checklist.self, inMemory: true)
}
