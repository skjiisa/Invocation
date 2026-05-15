//
//  ChecklistItemRow.swift
//  Invocation
//

import SwiftUI

struct ChecklistItemRow: View {
    @Bindable var item: ChecklistItem

    @State private var showingEditSheet = false

    var body: some View {
        Button {
            showingEditSheet = true
        } label: {
            Text(item.name.isEmpty ? "Untitled" : item.name)
                .foregroundStyle(.primary)
        }
        .sheet(isPresented: $showingEditSheet) {
            if let checklist = item.checklist {
                ChecklistItemEditSheet(checklist: checklist, item: item)
            }
        }
    }
}

#Preview {
    List {
        ChecklistItemRow(item: ChecklistItem(name: "Sample Item"))
    }
}
