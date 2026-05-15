//
//  Invocation.swift
//  Invocation
//

import Foundation
import SwiftData

@Model
final class Invocation {
    var id: UUID
    var name: String
    var isOrdered: Bool
    var statusRawValue: String
    var createdAt: Date
    var completedAt: Date?
    var sourceChecklistId: UUID?

    @Relationship(deleteRule: .cascade, inverse: \InvocationItem.invocation)
    var items: [InvocationItem]

    var status: InvocationStatus {
        get { InvocationStatus(rawValue: statusRawValue) ?? .active }
        set { statusRawValue = newValue.rawValue }
    }

    init(name: String = "", isOrdered: Bool = false, sourceChecklistId: UUID? = nil) {
        self.id = UUID()
        self.name = name
        self.isOrdered = isOrdered
        self.statusRawValue = InvocationStatus.active.rawValue
        self.createdAt = Date()
        self.completedAt = nil
        self.sourceChecklistId = sourceChecklistId
        self.items = []
    }

    var sortedItems: [InvocationItem] {
        items.sorted { $0.sortOrder < $1.sortOrder }
    }

    var completedItemsCount: Int {
        items.filter { $0.isCompleted }.count
    }

    var allItemsCompleted: Bool {
        !items.isEmpty && items.allSatisfy { $0.isCompleted }
    }

    var nextUncompletedItem: InvocationItem? {
        sortedItems.first { !$0.isCompleted }
    }

    func markComplete() {
        status = .completed
        completedAt = Date()
    }

    func archive() {
        status = .archived
    }
}
