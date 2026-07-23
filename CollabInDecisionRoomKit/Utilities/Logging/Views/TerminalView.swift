////  TerminalView.swift
////  OcclusionVision
////
////  Created by AidanCarrier on 10/02/25.
////
//
//import Combine
//import SwiftUI
//import os.log
//
//// MARK: - Terminal View
//
///// The terminal view which contains a terminal that shows logs logged by ``OutputLogger``
//public struct TerminalView: View {
//    
//    /// The AppLogic that this view uses
//    var appLogic: AppLogic
//    
//    /// The key that emulates untagged as a tag
//    private let untaggedSelectionKey = "untagged"
//
//    /// A string list of all tags in the store
//    private var allTags: [String] {
//        Array(Set(store.entries.compactMap { $0.tag })).sorted()
//    }
//
//    /// The LogStore shared singleton that interfaces between the ``OutputLogger`` and ``TerminalView``
//    @ObservedObject private var store : LogStore = LogStore.shared
//    
//    /// The setting of whether to follow the tail.
//    @State private var followTail: Bool = true //TODO: Currently this resets every time the view is exited and re-entered. Move to AppModel or Settings to save setting.
//
//    public var body: some View {
//        VStack(spacing: 0) {
//            header
//            divider
//            scrollArea
//        }
//        .background(Color(.systemBackground))
//    }
//
//    /// The header
//    private var header: some View {
//        HStack {
//            Text("Terminal")
//                .font(.headline)
//            Spacer()
//
//            Menu {
//                // Quick presets
//                Section("Presets") {
//                    Button("Show All") {
//                        appLogic.enabledPriorities = Set(Priority.allCases)
//                    }
//                    Button("Only Warnings & Above") {
//                        appLogic.enabledPriorities = [
//                            .warning, .error, .critical,
//                        ]
//                    }
//                    Button("Only Errors & Critical") {
//                        appLogic.enabledPriorities = [.error, .critical]
//                    }
//                }
//                Section("Select Priorities") {
//                    ForEach(Priority.allCases, id: \.self) { p in
//                        let isOn = appLogic.enabledPriorities.contains(p)
//                        Button(action: { toggle(p) }) {
//                            Label(
//                                p.label,
//                                systemImage: isOn
//                                    ? "checkmark.circle.fill" : "circle"
//                            )
//                        }
//                    }
//                }
//            } label: {
//                Label(
//                    "Filter",
//                    systemImage: "line.3.horizontal.decrease.circle"
//                )
//            }
//            .menuOrder(.fixed)
//
//            Menu {
//                Section("Presets") {
//                    Button("Show All") {
//                        appLogic.enabledTags.removeAll()
//                        appLogic.onlyTagged = false
//                        appLogic.onlyUntagged = false
//                    }
//                    Button("Only Tagged") {
//                        appLogic.enabledTags.removeAll()
//                        appLogic.onlyTagged = true
//                        appLogic.onlyUntagged = false
//                    }
//                    Button("Only Untagged") {
//                        appLogic.enabledTags.removeAll()
//                        appLogic.onlyTagged = false
//                        appLogic.onlyUntagged = true
//                    }
//                }
//
//                // Multi-select tags (auto-populated)
//                Section("Select Tags") {
//                    if allTags.isEmpty {
//                        Text("No tags yet")
//                            .foregroundStyle(.secondary)
//                    } else {
//                        let untaggedIsOn = appLogic.enabledTags.contains(
//                            untaggedSelectionKey
//                        )
//                        Button {
//                            // Selecting explicit tags cancels the presets
//                            appLogic.onlyTagged = false
//                            appLogic.onlyUntagged = false
//
//                            if untaggedIsOn {
//                                appLogic.enabledTags.remove(
//                                    untaggedSelectionKey
//                                )
//                            } else {
//                                appLogic.enabledTags.insert(
//                                    untaggedSelectionKey
//                                )
//                            }
//                        } label: {
//                            Label(
//                                "Untagged",
//                                systemImage: untaggedIsOn
//                                    ? "checkmark.circle.fill" : "circle"
//                            )
//                        }
//                        ForEach(allTags, id: \.self) { t in
//                            let isOn = appLogic.enabledTags.contains(t)
//                            Button {
//                                appLogic.onlyTagged = false
//                                appLogic.onlyUntagged = false
//                                if appLogic.enabledTags.contains(t) {
//                                    appLogic.enabledTags.remove(t)
//                                } else {
//                                    appLogic.enabledTags.insert(t)
//                                }
//                            } label: {
//                                Label(
//                                    t,
//                                    systemImage: isOn
//                                        ? "checkmark.circle.fill" : "circle"
//                                )
//                            }
//                        }
//                    }
//                }
//
//                // clear tag selection
//                if !appLogic.enabledTags.isEmpty || appLogic.onlyTagged
//                    || appLogic.onlyUntagged
//                {
//                    Section {
//                        Button("Clear Tag Filters") {
//                            appLogic.enabledTags.removeAll()
//                            appLogic.onlyTagged = false
//                            appLogic.onlyUntagged = false
//                        }
//                    }
//                }
//            } label: {
//                Label("Tags", systemImage: "tag")
//            }
//            .menuOrder(.fixed)
//
//            Button {
//                store.setPaused(!store.isPaused)
//                if store.isPaused == false {
//                    // resuming: re-enable follow tail to jump to the bottom on next batch
//                    followTail = true
//                }
//            } label: {
//                if store.isPaused {
//                    Label(
//                        "",
//                        systemImage: "pause.circle.fill"
//                    )
//                } else {
//                    Label("", systemImage: "play.circle.fill")
//                }
//            }
//            .buttonStyle(.borderedProminent)
//            .tint(store.isPaused ? .orange : .green)
//
//            Button(role: .none) {
//                LogStore.shared.clear()
//            } label: {
//                Text("Clear")
//            }
//            .buttonStyle(.bordered)
//        }
//        .padding(.horizontal)
//        .padding(.top, 8)
//        .padding(.bottom, 6)
//    }
//
//    /// A divider view
//    private var divider: some View {
//        Divider().padding(.bottom, 4)
//    }
//
//    /// The scroll area for the ``LogRow``s for each ``LogEntry``
//    private var scrollArea: some View {
//        ScrollViewReader { proxy in
//            ScrollView {
//                LazyVStack(alignment: .leading, spacing: 8) {
//                    ForEach(filteredEntries) { entry in
//                        LogRow(entry: entry)
//                            .id(entry.id)
//                    }
//                }
//                .padding(.horizontal)
//                .padding(.bottom)
//            }
//            .simultaneousGesture(
//                DragGesture(minimumDistance: 1).onChanged { _ in
//                    // user started scrolling -> stop auto-follow
//                    if followTail { followTail = false }
//                    if !store.isPaused { store.setPaused(true) }
//                }
//            )
//            .onChange(of: filteredEntries.count) {
//                guard !store.isPaused, followTail,
//                    let lastID = filteredEntries.last?.id
//                else { return }
//                withAnimation(.easeOut(duration: 0.1)) {
//                    proxy.scrollTo(lastID, anchor: .bottom)
//                }
//
//            }
//        }
//    }
//
//    /// Filters the the entries from the ``LogStore``
//    private var filteredEntries: [LogEntry] {
//        store.entries.filter {
//            appLogic.enabledPriorities.contains($0.priority)
//        }.filter { entry in
//            if appLogic.onlyUntagged { return entry.tag == nil }
//            if appLogic.onlyTagged { return entry.tag != nil }
//            if !appLogic.enabledTags.isEmpty {
//                if entry.tag == nil {
//                    return appLogic.enabledTags.contains(untaggedSelectionKey)
//                }
//                guard let tg = entry.tag else { return false }
//                return appLogic.enabledTags.contains(tg)
//            }
//            return true
//        }
//    }
//    
//    /// Toggles the priority
//    private func toggle(_ p: Priority) {
//        if appLogic.enabledPriorities.contains(p) {
//            appLogic.enabledPriorities.remove(p)
//        } else {
//            appLogic.enabledPriorities.insert(p)
//        }
//    }
//}
//
//
//#Preview(windowStyle: .automatic) {
//    TerminalView(appLogic: AppLogic())
//}
