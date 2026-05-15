//
//  InvocationItem.swift
//  Invocation
//

import Foundation
import SwiftData

@Model
final class InvocationItem {
    var id: UUID
    var name: String
    var sortOrder: Int
    var isCompleted: Bool
    var invocation: Invocation?

    init(name: String = "", sortOrder: Int = 0) {
        self.id = UUID()
        self.name = name
        self.sortOrder = sortOrder
        self.isCompleted = false
    }
}
