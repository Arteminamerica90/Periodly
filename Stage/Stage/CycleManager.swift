//
//  CycleManager.swift
//  Stage
//
//  Created by Artem Menshikov on 01.01.2026.
//

import Foundation
import CoreData

class CycleManager: ObservableObject {
    @Published var currentCycle: Cycle?
    @Published var upcomingPeriodDate: Date?
    @Published var upcomingOvulationDate: Date?
    @Published var averageCycleLength: Int = 28
    @Published var averagePeriodLength: Int = 5
    
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        loadSettings()
        currentCycle = getCurrentCycle()
        updatePredictions()
    }
    
    // MARK: - Settings
    func loadSettings() {
        let request: NSFetchRequest<CycleSettings> = CycleSettings.fetchRequest()
        request.fetchLimit = 1
        
        do {
            let settings = try viewContext.fetch(request)
            if let settings = settings.first {
                averageCycleLength = Int(settings.averageCycleLength)
                averagePeriodLength = Int(settings.averagePeriodLength)
            } else {
                // Create default settings
                createDefaultSettings()
            }
        } catch {
            print("Error loading settings: \(error)")
            createDefaultSettings()
        }
    }
    
    private func createDefaultSettings() {
        let settings = CycleSettings(context: viewContext)
        settings.id = UUID()
        settings.averageCycleLength = 28
        settings.averagePeriodLength = 5
        settings.remindersEnabled = true
        settings.reminderDaysBefore = 1
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving default settings: \(error)")
        }
    }
    
    func updateSettings(cycleLength: Int, periodLength: Int) {
        let request: NSFetchRequest<CycleSettings> = CycleSettings.fetchRequest()
        request.fetchLimit = 1
        
        do {
            let settings = try viewContext.fetch(request).first ?? CycleSettings(context: viewContext)
            settings.id = settings.id ?? UUID()
            settings.averageCycleLength = Int16(cycleLength)
            settings.averagePeriodLength = Int16(periodLength)
            
            try viewContext.save()
            averageCycleLength = cycleLength
            averagePeriodLength = periodLength
            updatePredictions()
        } catch {
            print("Error updating settings: \(error)")
        }
    }
    
    // MARK: - Cycle Management
    func startCycle(startDate: Date = Date(), intensity: Int = 2, mood: Int = 3, energy: Int = 3, pain: Int = 0, notes: String? = nil) {
        // End current cycle if exists
        if let current = getCurrentCycle() {
            endCycle(cycle: current, endDate: startDate.addingTimeInterval(-86400))
        }
        
        let cycle = Cycle(context: viewContext)
        cycle.id = cycle.id ?? UUID()
        cycle.startDate = startDate
        cycle.intensity = Int16(intensity)
        cycle.mood = Int16(mood)
        cycle.energy = Int16(energy)
        cycle.pain = Int16(pain)
        cycle.notes = notes
        cycle.createdAt = cycle.createdAt ?? Date()
        
        do {
            try viewContext.save()
            currentCycle = cycle
            updatePredictions()
        } catch {
            print("Error starting cycle: \(error)")
        }
    }
    
    func endCycle(cycle: Cycle, endDate: Date = Date()) {
        cycle.endDate = endDate
        
        do {
            try viewContext.save()
            if cycle == currentCycle {
                currentCycle = nil
            }
            updatePredictions()
        } catch {
            print("Error ending cycle: \(error)")
        }
    }
    
    func getCurrentCycle() -> Cycle? {
        let request: NSFetchRequest<Cycle> = Cycle.fetchRequest()
        request.predicate = NSPredicate(format: "endDate == nil")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Cycle.startDate, ascending: false)]
        request.fetchLimit = 1
        
        do {
            return try viewContext.fetch(request).first
        } catch {
            print("Error fetching current cycle: \(error)")
            return nil
        }
    }
    
    func updateCycleSymptoms(cycle: Cycle, intensity: Int, mood: Int, energy: Int, pain: Int, notes: String?) {
        cycle.intensity = Int16(intensity)
        cycle.mood = Int16(mood)
        cycle.energy = Int16(energy)
        cycle.pain = Int16(pain)
        cycle.notes = notes
        
        do {
            try viewContext.save()
        } catch {
            print("Error updating cycle symptoms: \(error)")
        }
    }
    
    func deleteCycle(_ cycle: Cycle) {
        viewContext.delete(cycle)
        if cycle == currentCycle {
            currentCycle = nil
        }
        do {
            try viewContext.save()
            updatePredictions()
        } catch {
            print("Error deleting cycle: \(error)")
        }
    }
    
    func getAllCycles() -> [Cycle] {
        let request: NSFetchRequest<Cycle> = Cycle.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Cycle.startDate, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching cycles: \(error)")
            return []
        }
    }
    
    func getCyclesForMonth(_ date: Date) -> [Cycle] {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
        
        let request: NSFetchRequest<Cycle> = Cycle.fetchRequest()
        request.predicate = NSPredicate(format: "startDate >= %@ AND startDate < %@", startOfMonth as NSDate, endOfMonth as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Cycle.startDate, ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching cycles for month: \(error)")
            return []
        }
    }
    
    // MARK: - Predictions
    func updatePredictions() {
        let cycles = getAllCycles()
        guard !cycles.isEmpty else {
            // Use default if no cycles
            if let lastCycle = getCurrentCycle() {
                upcomingPeriodDate = Calendar.current.date(byAdding: .day, value: averageCycleLength, to: lastCycle.startDate!)
            }
            return
        }
        
        // Calculate average cycle length from history
        var totalDays = 0
        var count = 0
        
        for i in 0..<cycles.count - 1 {
            if let start1 = cycles[i].startDate,
               let start2 = cycles[i + 1].startDate {
                let days = Calendar.current.dateComponents([.day], from: start1, to: start2).day ?? 0
                if days > 0 && days < 50 { // Reasonable range
                    totalDays += days
                    count += 1
                }
            }
        }
        
        if count > 0 {
            averageCycleLength = totalDays / count
        }
        
        // Predict next period
        if let lastCycle = cycles.first, let lastStart = lastCycle.startDate {
            upcomingPeriodDate = Calendar.current.date(byAdding: .day, value: averageCycleLength, to: lastStart)
            
            // Predict ovulation (typically 14 days before next period)
            if let nextPeriod = upcomingPeriodDate {
                upcomingOvulationDate = Calendar.current.date(byAdding: .day, value: -14, to: nextPeriod)
            }
        }
        
        currentCycle = getCurrentCycle()
        
        // Обновить напоминания после обновления прогнозов
        ReminderManager.shared.scheduleReminders(for: self)
    }
    
    // MARK: - Phase Calculation
    func getPhase(for date: Date) -> CyclePhase {
        guard let lastCycle = getAllCycles().first,
              let lastStart = lastCycle.startDate else {
            return .follicular
        }
        
        let daysSinceStart = Calendar.current.dateComponents([.day], from: lastStart, to: date).day ?? 0
        
        if daysSinceStart < 0 {
            return .follicular
        }
        
        // If cycle is active and within period length
        if lastCycle.endDate == nil && daysSinceStart < averagePeriodLength {
            return .period
        }
        
        // Calculate phase based on cycle day
        let cycleDay = daysSinceStart % averageCycleLength
        
        if cycleDay < averagePeriodLength {
            return .period
        } else if cycleDay < averagePeriodLength + 7 {
            return .follicular
        } else if cycleDay >= averagePeriodLength + 7 && cycleDay < averagePeriodLength + 10 {
            return .ovulation
        } else {
            return .luteal
        }
    }
    
    // MARK: - Statistics
    func getAverageCycleLength() -> Int {
        let cycles = getAllCycles()
        guard cycles.count > 1 else { return averageCycleLength }
        
        var totalDays = 0
        var count = 0
        
        for i in 0..<cycles.count - 1 {
            if let start1 = cycles[i].startDate,
               let start2 = cycles[i + 1].startDate {
                let days = Calendar.current.dateComponents([.day], from: start1, to: start2).day ?? 0
                if days > 0 && days < 50 {
                    totalDays += days
                    count += 1
                }
            }
        }
        
        return count > 0 ? totalDays / count : averageCycleLength
    }
}

