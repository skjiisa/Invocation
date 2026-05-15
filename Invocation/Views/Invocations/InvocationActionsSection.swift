//
//  InvocationActionsSection.swift
//  Invocation
//

import SwiftUI

struct InvocationActionsSection: View {
    let invocation: Invocation
    @Environment(\.dismiss) private var dismiss
    @State private var completionCount = 0

    var body: some View {
        if invocation.allItemsCompleted {
            Section {
                Button("Mark Complete", systemImage: "checkmark.circle.fill") {
                    invocation.markComplete()
                    completionCount += 1
                    dismiss()
                }
                .foregroundStyle(.green)
            }
            .sensoryFeedback(.success, trigger: completionCount)
        }
    }
}
