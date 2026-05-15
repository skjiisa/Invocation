//
//  StatusBadgeView.swift
//  Invocation
//

import SwiftUI

struct StatusBadgeView: View {
    let status: InvocationStatus

    var body: some View {
        switch status {
        case .completed:
            Label("Completed", systemImage: "checkmark.circle.fill")
                .labelStyle(.iconOnly)
                .foregroundStyle(.green)
        case .archived:
            Label("Archived", systemImage: "archivebox.fill")
                .labelStyle(.iconOnly)
                .foregroundStyle(.orange)
        case .active:
            EmptyView()
        }
    }
}
