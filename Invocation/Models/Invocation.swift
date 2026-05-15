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
        self.createdAt = .now
        self.completedAt = nil
        self.sourceChecklistId = sourceChecklistId
        self.items = []
    }

    var sortedItems: [InvocationItem] {
        items.sorted { $0.sortOrder < $1.sortOrder }
    }

    var completedItems: [InvocationItem] {
        sortedItems.filter(\.isCompleted)
    }

    var completedItemsCount: Int {
        items.count(where: \.isCompleted)
    }

    var allItemsCompleted: Bool {
        !items.isEmpty && items.allSatisfy(\.isCompleted)
    }

    var nextUncompletedItem: InvocationItem? {
        sortedItems.first { !$0.isCompleted }
    }

    func markComplete() {
        status = .completed
        completedAt = .now
    }

    func archive() {
        status = .archived
    }
}

extension Invocation {
    static func from(_ checklist: Checklist) -> Invocation {
        let invocation = Invocation(
            name: checklist.name,
            isOrdered: checklist.isOrdered,
            sourceChecklistId: checklist.id
        )
        for item in checklist.sortedItems {
            invocation.items.append(
                InvocationItem(name: item.name, sortOrder: item.sortOrder)
            )
        }
        return invocation
    }
}
