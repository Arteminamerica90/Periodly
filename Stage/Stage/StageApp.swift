//
//  StageApp.swift
//  Stage
//
//  Created by Artem Menshikov on 01.01.2026.
//

import SwiftUI

@main
struct StageApp: App {
    let persistenceController = PersistenceController.shared

    init() {
        // Request notification permissions on app launch
        ReminderManager.shared.requestAuthorization()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
