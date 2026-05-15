//
//  AppState.swift
//  Invocation
//

import Foundation

@MainActor
@Observable
final class AppState {
    var selectedTab: AppTab = .active
}
