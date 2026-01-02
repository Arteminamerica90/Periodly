//
//  ReminderManager.swift
//  Stage
//
//  Created by Artem Menshikov on 01.01.2026.
//

import Foundation
import UserNotifications

class ReminderManager: ObservableObject {
    static let shared = ReminderManager()
    
    @Published var remindersEnabled = true
    
    private init() {
        checkAuthorization()
    }
    
    // MARK: - Authorization
    func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.remindersEnabled = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                self.remindersEnabled = granted
            }
        }
    }
    
    // MARK: - Schedule Reminders
    func scheduleReminders(for cycleManager: CycleManager) {
        guard remindersEnabled else { return }
        
        // Remove existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Schedule 5 reminders for period
        if let nextPeriod = cycleManager.upcomingPeriodDate {
            schedulePeriodReminders(date: nextPeriod)
        }
        
        // Schedule ovulation reminders
        if let nextOvulation = cycleManager.upcomingOvulationDate {
            scheduleOvulationReminders(date: nextOvulation)
        }
    }
    
    private func schedulePeriodReminders(date: Date) {
        let calendar = Calendar.current
        let defaultHour = 9
        let localizationManager = LocalizationManager.shared
        
        // 1. 3 days before period
        if let reminderDate = calendar.date(byAdding: .day, value: -3, to: date),
           reminderDate > Date() {
            scheduleReminder(
                identifier: "periodReminder3Days",
                title: "period_reminder".localized,
                body: "period_in_3_days".localized,
                date: reminderDate,
                hour: defaultHour
            )
        }
        
        // 2. 1 day before period
        if let reminderDate = calendar.date(byAdding: .day, value: -1, to: date),
           reminderDate > Date() {
            scheduleReminder(
                identifier: "periodReminder1Day",
                title: "period_reminder".localized,
                body: "period_tomorrow".localized,
                date: reminderDate,
                hour: defaultHour
            )
        }
        
        // 3. On period day
        if date > Date() {
            scheduleReminder(
                identifier: "periodReminderToday",
                title: "menstruation".localized,
                body: "period_today".localized,
                date: date,
                hour: defaultHour
            )
        }
    }
    
    private func scheduleOvulationReminders(date: Date) {
        let calendar = Calendar.current
        let defaultHour = 10
        
        // 4. 1 day before ovulation
        if let reminderDate = calendar.date(byAdding: .day, value: -1, to: date),
           reminderDate > Date() {
            scheduleReminder(
                identifier: "ovulationReminder1Day",
                title: "ovulation_reminder".localized,
                body: "ovulation_tomorrow".localized,
                date: reminderDate,
                hour: defaultHour
            )
        }
        
        // 5. On ovulation day
        if date > Date() {
            scheduleReminder(
                identifier: "ovulationReminderToday",
                title: "ovulation_phase".localized,
                body: "ovulation_today".localized,
                date: date,
                hour: defaultHour
            )
        }
    }
    
    private func scheduleReminder(identifier: String, title: String, body: String, date: Date, hour: Int) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1
        
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = hour
        components.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling reminder \(identifier): \(error)")
            }
        }
    }
    
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

