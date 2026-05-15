//
//  InvocationsListView.swift
//  Invocation
//

import SwiftUI
import SwiftData

struct InvocationsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(
        filter: #Predicate<Invocation> { $0.statusRawValue == "active" },
        sort: \Invocation.createdAt,
        order: .reverse
    ) private var invocations: [Invocation]

    @State private var selectedInvocationId: UUID?

    var body: some View {
        NavigationStack {
            List {
                ForEach(invocations) { invocation in
                    NavigationLink(value: invocation) {
                        VStack(alignment: .leading) {
                            Text(invocation.name.isEmpty ? "Untitled" : invocation.name)
                            Text("\(invocation.completedItemsCount) of \(invocation.items.count) completed")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteInvocations)
            }
            .navigationTitle("Active")
            .navigationDestination(for: Invocation.self) { invocation in
                InvocationDetailView(invocation: invocation)
            }
            .overlay {
                if invocations.isEmpty {
                    ContentUnavailableView(
                        "No Active Invocations",
                        systemImage: "checklist.checked",
                        description: Text("Invoke a template to get started")
                    )
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .didCreateInvocation)) { notification in
                if let invocationId = notification.object as? UUID {
                    selectedInvocationId = invocationId
                }
            }
            .onChange(of: selectedInvocationId) { _, newValue in
                if let id = newValue,
                   let invocation = invocations.first(where: { $0.id == id }) {
                    selectedInvocationId = nil
                    // Navigate to the invocation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        NotificationCenter.default.post(
                            name: .navigateToInvocation,
                            object: invocation
                        )
                    }
                }
            }
        }
    }

    private func deleteInvocations(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(invocations[index])
        }
    }
}

extension Notification.Name {
    static let navigateToInvocation = Notification.Name("navigateToInvocation")
}

#Preview {
    InvocationsListView()
        .modelContainer(for: Invocation.self, inMemory: true)
}
