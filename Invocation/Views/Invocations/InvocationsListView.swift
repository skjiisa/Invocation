//
//  InvocationsListView.swift
//  Invocation
//

import SwiftUI
import SwiftData

struct InvocationsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Query(
        filter: #Predicate<Invocation> { $0.statusRawValue == "active" },
        sort: \Invocation.createdAt,
        order: .reverse
    ) private var invocations: [Invocation]

    private var sections: [DateSection] {
        let groups = Dictionary(grouping: invocations) {
            Calendar.current.startOfDay(for: $0.createdAt)
        }
        return groups.keys.sorted(by: >).map { date in
            DateSection(date: date, invocations: groups[date] ?? [])
        }
    }

    var body: some View {
        @Bindable var appState = appState

        NavigationStack(path: $appState.activeTabPath) {
            List {
                ForEach(sections) { section in
                    Section(title(for: section.date)) {
                        ForEach(section.invocations) { invocation in
                            NavigationLink(value: invocation) {
                                VStack(alignment: .leading) {
                                    Text(invocation.name.isEmpty ? "Untitled" : invocation.name)
                                    Text("\(invocation.completedItemsCount) of \(invocation.items.count) completed")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button("Archive", systemImage: "archivebox") {
                                    invocation.archive()
                                }
                                .tint(.orange)
                            }
                        }
                        .onDelete { offsets in
                            delete(from: section.invocations, at: offsets)
                        }
                    }
                }
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
        }
    }

    private func delete(from group: [Invocation], at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(group[index])
        }
    }

    private func title(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        let daysAgo = calendar.dateComponents([.day], from: date, to: .now).day ?? 0
        if daysAgo < 7 {
            return date.formatted(.dateTime.weekday(.wide))
        }
        return date.formatted(date: .abbreviated, time: .omitted)
    }
}

private struct DateSection: Identifiable {
    let date: Date
    let invocations: [Invocation]
    var id: Date { date }
}

#Preview {
    InvocationsListView()
        .environment(AppState())
        .modelContainer(for: Invocation.self, inMemory: true)
}
