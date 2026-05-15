//
//  AppState.swift
//  Invocation
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class AppState {
    var selectedTab: AppTab = .active
    var activeTabPath = NavigationPath()
}
