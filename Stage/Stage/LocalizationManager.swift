//
//  LocalizationManager.swift
//  Stage
//
//  Created by Artem Menshikov on 01.01.2026.
//

import Foundation
import SwiftUI

enum AppLanguage: String, CaseIterable {
    case english = "en"
    case russian = "ru"
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .russian: return "Русский"
        }
    }
    
    var locale: Locale {
        Locale(identifier: rawValue)
    }
}

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "appLanguage")
            updateLocale()
        }
    }
    
    private var locale: Locale
    
    private init() {
        let savedLanguage = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        let language = AppLanguage(rawValue: savedLanguage) ?? .english
        // Initialize locale first, then currentLanguage to avoid using self before all properties are initialized
        locale = language.locale
        currentLanguage = language
    }
    
    private func updateLocale() {
        locale = currentLanguage.locale
    }
    
    func getLocale() -> Locale {
        return locale
    }
    
    func localizedString(_ key: String) -> String {
        return LocalizedStrings.shared.getString(key: key, language: currentLanguage)
    }
}

// MARK: - Localized Strings
class LocalizedStrings {
    static let shared = LocalizedStrings()
    
    private let strings: [AppLanguage: [String: String]] = [
        .english: [
            // Navigation
            "calendar": "Calendar",
            "statistics": "Statistics",
            "settings": "Settings",
            "symptoms": "Symptoms",
            
            // Calendar
            "how_to_use": "How to use",
            "mark_period_day": "Mark period day",
            "mark_period_description": "Tap on a day in the calendar to mark the start of your period. The day will turn red with a drop icon.",
            "add_symptoms": "Add symptoms",
            "add_symptoms_description": "Long press on a day to open the menu: add symptoms or delete the mark.",
            "view_predictions": "View predictions",
            "view_predictions_description": "The app will automatically calculate your next period and ovulation based on your data.",
            
            // Weekdays
            "mon": "Mon",
            "tue": "Tue",
            "wed": "Wed",
            "thu": "Thu",
            "fri": "Fri",
            "sat": "Sat",
            "sun": "Sun",
            
            // Predictions
            "predictions": "Predictions",
            "next_period": "Next period",
            "days_in": "in {days} days",
            "days_ago": "{days} days ago",
            
            // Legend
            "legend": "Legend",
            "menstruation_tap": "Menstruation (tap to mark)",
            "follicular": "Follicular",
            "ovulation": "Ovulation",
            "luteal": "Luteal",
            "short_tap": "Short tap = mark menstruation",
            "long_tap": "Long tap = menu (symptoms/delete)",
            
            // Context Menu
            "edit_symptoms": "Edit symptoms",
            "delete_mark": "Delete mark",
            "add_symptoms_menu": "Add symptoms",
            
            // Symptoms Sheet
            "symptoms_for": "Symptoms for {date}",
            "intensity": "Intensity",
            "mood": "Mood",
            "energy": "Energy",
            "pain": "Pain",
            "notes": "Notes",
            "add_note": "Add note...",
            "cancel": "Cancel",
            "save": "Save",
            
            // Statistics
            "overall_statistics": "Overall statistics",
            "total_cycles": "Total cycles",
            "average_cycle_length": "Average cycle length",
            "average_period_length": "Average period length",
            "days": "days",
            "no_records": "No records",
            "mark_days_in_calendar": "Mark period days in the calendar",
            "recent_cycles": "Recent cycles",
            "current": "Current",
            "until": "until",
            
            // Settings
            "cycle": "Cycle",
            "average_cycle_length_label": "Average cycle length",
            "average_period_length_label": "Average period length",
            "reminders": "Reminders",
            "enable_reminders": "Enable reminders",
            "language": "Language",
            
            // Reminders
            "period_reminder": "Period reminder",
            "period_in_3_days": "Period expected in 3 days",
            "period_tomorrow": "Period expected tomorrow",
            "period_today": "Period expected today",
            "ovulation_reminder": "Ovulation reminder",
            "ovulation_tomorrow": "Ovulation expected tomorrow",
            "ovulation_today": "Ovulation expected today",
            
            // Phase names
            "menstruation": "Menstruation",
            "follicular_phase": "Follicular",
            "ovulation_phase": "Ovulation",
            "luteal_phase": "Luteal",
            
            // Ad settings
            "ads": "Ads",
            "enable_ads": "Enable ads",
            "ad_provider": "Ad provider",
            "ad_frequency": "Ad frequency",
            "low": "Low",
            "normal": "Normal",
            "high": "High",
            
            // Blog
            "blog": "Blog",
            "read_more": "Read more",
            "close": "Close"
        ],
        .russian: [
            // Navigation
            "calendar": "Календарь",
            "statistics": "Статистика",
            "settings": "Настройки",
            "symptoms": "Симптомы",
            
            // Calendar
            "how_to_use": "Как пользоваться",
            "mark_period_day": "Отметьте день менструации",
            "mark_period_description": "Нажмите на день в календаре, чтобы отметить начало менструации. День станет красным с иконкой капли.",
            "add_symptoms": "Добавьте симптомы",
            "add_symptoms_description": "Долго нажмите на день, чтобы открыть меню: добавить симптомы или удалить отметку.",
            "view_predictions": "Смотрите прогнозы",
            "view_predictions_description": "Приложение автоматически рассчитает следующую менструацию и овуляцию на основе ваших данных.",
            
            // Weekdays
            "mon": "Пн",
            "tue": "Вт",
            "wed": "Ср",
            "thu": "Чт",
            "fri": "Пт",
            "sat": "Сб",
            "sun": "Вс",
            
            // Predictions
            "predictions": "Прогнозы",
            "next_period": "Следующая менструация",
            "days_in": "через {days} дн.",
            "days_ago": "{days} дн. назад",
            
            // Legend
            "legend": "Легенда",
            "menstruation_tap": "Менструация (тап для отметки)",
            "follicular": "Фолликулярная",
            "ovulation": "Овуляция",
            "luteal": "Лютеиновая",
            "short_tap": "Короткий тап = отметить менструацию",
            "long_tap": "Долгий тап = меню (симптомы/удалить)",
            
            // Context Menu
            "edit_symptoms": "Изменить симптомы",
            "delete_mark": "Удалить отметку",
            "add_symptoms_menu": "Добавить симптомы",
            
            // Symptoms Sheet
            "symptoms_for": "Симптомы для {date}",
            "intensity": "Интенсивность",
            "mood": "Настроение",
            "energy": "Энергия",
            "pain": "Боль",
            "notes": "Заметки",
            "add_note": "Добавить заметку...",
            "cancel": "Отмена",
            "save": "Сохранить",
            
            // Statistics
            "overall_statistics": "Общая статистика",
            "total_cycles": "Всего циклов",
            "average_cycle_length": "Средняя длина цикла",
            "average_period_length": "Средняя длина менструации",
            "days": "дней",
            "no_records": "Нет записей",
            "mark_days_in_calendar": "Отмечайте дни менструации в календаре",
            "recent_cycles": "Последние циклы",
            "current": "Текущий",
            "until": "до",
            
            // Settings
            "cycle": "Цикл",
            "average_cycle_length_label": "Средняя длина цикла",
            "average_period_length_label": "Средняя длина менструации",
            "reminders": "Напоминания",
            "enable_reminders": "Включить напоминания",
            "language": "Язык",
            
            // Reminders
            "period_reminder": "Напоминание о менструации",
            "period_in_3_days": "Через 3 дня ожидается начало менструации",
            "period_tomorrow": "Завтра ожидается начало менструации",
            "period_today": "Сегодня ожидается начало менструации",
            "ovulation_reminder": "Напоминание об овуляции",
            "ovulation_tomorrow": "Завтра ожидается овуляция",
            "ovulation_today": "Сегодня ожидается овуляция",
            
            // Phase names
            "menstruation": "Менструация",
            "follicular_phase": "Фолликулярная",
            "ovulation_phase": "Овуляция",
            "luteal_phase": "Лютеиновая",
            
            // Ad settings
            "ads": "Реклама",
            "enable_ads": "Включить рекламу",
            "ad_provider": "Провайдер рекламы",
            "ad_frequency": "Частота рекламы",
            "low": "Низкая",
            "normal": "Обычная",
            "high": "Высокая",
            
            // Blog
            "blog": "Блог",
            "read_more": "Читать далее",
            "close": "Закрыть"
        ]
    ]
    
    func getString(key: String, language: AppLanguage) -> String {
        return strings[language]?[key] ?? key
    }
    
    func getString(key: String, language: AppLanguage, replacements: [String: String]) -> String {
        var text = strings[language]?[key] ?? key
        for (placeholder, value) in replacements {
            text = text.replacingOccurrences(of: "{\(placeholder)}", with: value)
        }
        return text
    }
}

// MARK: - String Extension
extension String {
    var localized: String {
        return LocalizationManager.shared.localizedString(self)
    }
    
    func localized(replacements: [String: String]) -> String {
        return LocalizedStrings.shared.getString(key: self, language: LocalizationManager.shared.currentLanguage, replacements: replacements)
    }
}

