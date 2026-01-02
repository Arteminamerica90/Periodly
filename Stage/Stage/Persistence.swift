//
//  Persistence.swift
//  Stage
//
//  Created by Artem Menshikov on 01.01.2026.
//

import CoreData

class PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample cycles for preview
        let cycle1 = Cycle(context: viewContext)
        cycle1.id = UUID()
        cycle1.startDate = Calendar.current.date(byAdding: .day, value: -10, to: Date())
        cycle1.intensity = 3
        cycle1.mood = 4
        cycle1.energy = 3
        cycle1.pain = 1
        cycle1.createdAt = Date()
        
        let cycle2 = Cycle(context: viewContext)
        cycle2.id = UUID()
        cycle2.startDate = Calendar.current.date(byAdding: .day, value: -38, to: Date())
        cycle2.endDate = Calendar.current.date(byAdding: .day, value: -33, to: Date())
        cycle2.intensity = 2
        cycle2.mood = 3
        cycle2.energy = 4
        cycle2.pain = 0
        cycle2.createdAt = Date()
        
        let settings = CycleSettings(context: viewContext)
        settings.id = UUID()
        settings.averageCycleLength = 28
        settings.averagePeriodLength = 5
        settings.remindersEnabled = true
        settings.reminderDaysBefore = 1
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Stage")
        
        // Configure for iCloud if not in-memory
        if !inMemory {
            let storeDescription = container.persistentStoreDescriptions.first
            storeDescription?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            storeDescription?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            
            // CloudKit disabled by default - requires entitlements and Info.plist configuration
            // To enable CloudKit:
            // 1. Add iCloud capability in Xcode
            // 2. Add CloudKit entitlement
            // 3. Add 'remote-notification' to UIBackgroundModes in Info.plist
            // Then uncomment the following:
            /*
            if #available(iOS 13.0, *) {
                storeDescription?.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
                    containerIdentifier: "iCloud.artmenshi.Stage"
                )
            }
            */
        }
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Handle error gracefully
                print("Error loading persistent store: \(error), \(error.userInfo)")
                
                // For production, you might want to show an alert to the user
                // For now, we'll just log the error
                #if DEBUG
                fatalError("Unresolved error \(error), \(error.userInfo)")
                #else
                // In production, handle gracefully - maybe show alert or use fallback
                #endif
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
