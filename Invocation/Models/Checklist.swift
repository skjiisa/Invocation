//
//  Checklist.swift
//  Invocation
//

import Foundation
import SwiftData

@Model
final class Checklist {
    var id: UUID
    var name: String
    var isOrdered: Bool
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \ChecklistItem.checklist)
    var items: [ChecklistItem]

    init(name: String = "", isOrdered: Bool = false) {
        self.id = UUID()
        self.name = name
        self.isOrdered = isOrdered
        self.createdAt = Date()
        self.items = []
    }

    var sortedItems: [ChecklistItem] {
        items.sorted { $0.sortOrder < $1.sortOrder }
    }
}
