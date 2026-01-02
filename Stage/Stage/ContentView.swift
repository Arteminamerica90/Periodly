//
//  ContentView.swift
//  Stage
//
//  Created by Artem Menshikov on 01.01.2026.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var cycleManager: CycleManager
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _cycleManager = StateObject(wrappedValue: CycleManager(context: context))
    }
    
    var body: some View {
        TabView {
            UnifiedCalendarView(cycleManager: cycleManager)
                .tabItem {
                    Label("calendar".localized, systemImage: "calendar")
                }
            
            StatisticsView(cycleManager: cycleManager)
                .tabItem {
                    Label("statistics".localized, systemImage: "chart.bar")
                }
            
            BlogView()
                .tabItem {
                    Label("blog".localized, systemImage: "book.fill")
                }
        }
        .accentColor(DesignColors.purpleMedium)
        .onAppear {
            // Schedule reminders when app appears
            ReminderManager.shared.scheduleReminders(for: cycleManager)
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
