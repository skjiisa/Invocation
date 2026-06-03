//
//  InvocationsListView.swift
//  Invocation

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
    @State private var expandedInvocations: Set<UUID> = []
    @State private var recentlyCompleted: Set<UUID> = []
    @State private var pendingHide: DispatchWorkItem?

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
                            invocationHeader(for: invocation)
                                .swipeActions(edge: .leading) {
                                    Button("Archive", systemImage: "archivebox") {
                                        invocation.archive()
                                    }
                                    .tint(.orange)
                                }

                            if expandedInvocations.contains(invocation.id) {
                                expandedItems(for: invocation)
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

    @ViewBuilder
    private func invocationHeader(for invocation: Invocation) -> some View {
        let isExpanded = expandedInvocations.contains(invocation.id)

        HStack {
            Button {
                withAnimation(.snappy(duration: 0.25)) {
                    if isExpanded {
                        expandedInvocations.remove(invocation.id)
                    } else {
                        expandedInvocations.insert(invocation.id)
                    }
                }
            } label: {
                Label {
                    VStack(alignment: .leading) {
                        Text(invocation.name.isEmpty ? "Untitled" : invocation.name)
                        Text("\(invocation.completedItemsCount) of \(invocation.items.count) completed")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .rotationEffect(isExpanded ? .degrees(90) : .zero)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button {
                appState.activeTabPath.append(invocation)
            } label: {
                Image(systemName: "info.circle")
                    .font(.title3)
                    .foregroundStyle(.tint)
            }
            .buttonStyle(.borderless)
            .accessibilityLabel("Details for \(invocation.name.isEmpty ? "Untitled" : invocation.name)")
        }
    }

    @ViewBuilder
    private func expandedItems(for invocation: Invocation) -> some View {
        if invocation.isOrdered {
            orderedExpandedItems(for: invocation)
        } else {
            let visible = invocation.sortedItems.filter {
                !$0.isCompleted || recentlyCompleted.contains($0.id)
            }
            ForEach(visible) { item in
                InvocationItemRow(item: item) {
                    recentlyCompleted.insert(item.id)
                    scheduleHide()
                }
                .padding(.leading, 24)
            }
        }
    }

    @ViewBuilder
    private func orderedExpandedItems(for invocation: Invocation) -> some View {
        let total = invocation.items.count

        if invocation.allItemsCompleted {
            Text("All steps completed")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.leading, 24)
        } else {
            Text("Step \(invocation.completedItemsCount + 1) of \(total)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.leading, 24)
        }

        ForEach(orderedFadeEntries(for: invocation)) { entry in
            InvocationItemRow(item: entry.item) {
                recentlyCompleted.insert(entry.item.id)
                scheduleHide()
            }
            .opacity(entry.opacity)
            .padding(.leading, 24)
        }
    }

    /// Builds the visible queue for an ordered invocation: the next actionable
    /// item at full strength, each following step progressively faded, plus any
    /// just-completed item kept briefly visible for the toggle animation.
    private func orderedFadeEntries(for invocation: Invocation) -> [OrderedExpandedEntry] {
        let visible = invocation.sortedItems.filter {
            !$0.isCompleted || recentlyCompleted.contains($0.id)
        }
        var uncompletedRank = 0
        return visible.map { item in
            guard !item.isCompleted else {
                return OrderedExpandedEntry(item: item, opacity: 1)
            }
            let opacity = max(0.4, 1 - 0.25 * Double(uncompletedRank))
            uncompletedRank += 1
            return OrderedExpandedEntry(item: item, opacity: opacity)
        }
    }

    private func scheduleHide() {
        pendingHide?.cancel()
        let work = DispatchWorkItem {
            withAnimation(.snappy(duration: 0.25)) {
                recentlyCompleted.removeAll()
            }
        }
        pendingHide = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: work)
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

private struct OrderedExpandedEntry: Identifiable {
    let item: InvocationItem
    let opacity: Double
    var id: UUID { item.id }
}

#Preview {
    InvocationsListView()
        .environment(AppState())
        .modelContainer(for: Invocation.self, inMemory: true)
}
