//
//  CalendarView.swift
//  Stage
//
//  Created by Artem Menshikov on 01.01.2026.
//

import SwiftUI
import CoreData

struct CalendarView: View {
    @ObservedObject var cycleManager: CycleManager
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignColors.backgroundGradient(colorScheme: colorScheme)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Month header
                    monthHeader
                    
                    // Weekday headers
                    weekdayHeaders
                    
                    // Calendar grid
                    calendarGrid
                    
                    // Legend
                    legend
                }
            }
            .navigationTitle("Календарь")
        }
    }
    
    // MARK: - Month Header
    private var monthHeader: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(DesignColors.purpleMedium)
            }
            
            Spacer()
            
            Text(dateFormatter.string(from: currentMonth).capitalized)
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(DesignColors.purpleMedium)
            }
        }
        .padding()
    }
    
    // MARK: - Weekday Headers
    private var weekdayHeaders: some View {
        HStack(spacing: 0) {
            ForEach(["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"], id: \.self) { day in
                Text(day)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Calendar Grid
    private var calendarGrid: some View {
        let days = getDaysForMonth(currentMonth)
        let columns = Array(repeating: GridItem(.flexible()), count: 7)
        
        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(Array(days.enumerated()), id: \.offset) { index, date in
                if let date = date {
                    dayCell(date: date)
                } else {
                    Color.clear
                        .frame(height: 44)
                }
            }
        }
        .padding()
    }
    
    // MARK: - Day Cell
    private func dayCell(date: Date) -> some View {
        let phase = cycleManager.getPhase(for: date)
        let isToday = calendar.isDateInToday(date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let hasCycle = hasCycleOnDate(date)
        
        // Определяем цвет фона в зависимости от фазы
        let backgroundColor: Color = {
            if isSelected {
                return DesignColors.purpleMedium
            } else {
                // Яркий фон для каждой фазы
                switch phase {
                case .period:
                    return DesignColors.periodColor.opacity(0.4) // Красный фон
                case .ovulation:
                    return DesignColors.ovulationColor.opacity(0.4) // Зеленый фон
                case .follicular:
                    return DesignColors.follicularColor.opacity(0.3) // Синий фон
                case .luteal:
                    return DesignColors.lutealColor.opacity(0.3) // Оранжевый фон
                }
            }
        }()
        
        // Цвет текста
        let textColor: Color = {
            if isSelected {
                return .white
            } else if isToday {
                return DesignColors.purpleMedium
            } else {
                // Для ярких фонов используем белый текст
                switch phase {
                case .period, .ovulation:
                    return .white
                default:
                    return .primary
                }
            }
        }()
        
        return Button(action: {
            selectedDate = date
        }) {
            VStack(spacing: 4) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 16, weight: isToday ? .bold : .regular))
                    .foregroundColor(textColor)
                
                // Индикатор фазы
                Circle()
                    .fill(phase.color)
                    .frame(width: 8, height: 8)
            }
            .frame(width: 44, height: 44)
            .background(
                Group {
                    if isToday && !isSelected {
                        // Сегодня - обводка
                        RoundedRectangle(cornerRadius: 8)
                            .fill(backgroundColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(DesignColors.purpleMedium, lineWidth: 2)
                            )
                    } else {
                        // Обычный день - цветной фон
                        RoundedRectangle(cornerRadius: 8)
                            .fill(backgroundColor)
                    }
                }
            )
        }
    }
    
    // MARK: - Legend
    private var legend: some View {
        GlassCard {
            VStack(spacing: 12) {
                HStack {
                    Text("Легенда фаз")
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                }
                
                // Менструация
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(DesignColors.periodColor.opacity(0.4))
                        .frame(width: 30, height: 30)
                        .overlay(
                            Circle()
                                .fill(DesignColors.periodColor)
                                .frame(width: 8, height: 8)
                        )
                    Text("Менструация")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                }
                
                // Фолликулярная
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(DesignColors.follicularColor.opacity(0.3))
                        .frame(width: 30, height: 30)
                        .overlay(
                            Circle()
                                .fill(DesignColors.follicularColor)
                                .frame(width: 8, height: 8)
                        )
                    Text("Фолликулярная фаза")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                }
                
                // Овуляция
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(DesignColors.ovulationColor.opacity(0.4))
                        .frame(width: 30, height: 30)
                        .overlay(
                            Circle()
                                .fill(DesignColors.ovulationColor)
                                .frame(width: 8, height: 8)
                        )
                    Text("Овуляция")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                }
                
                // Лютеиновая
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(DesignColors.lutealColor.opacity(0.3))
                        .frame(width: 30, height: 30)
                        .overlay(
                            Circle()
                                .fill(DesignColors.lutealColor)
                                .frame(width: 8, height: 8)
                        )
                    Text("Лютеиновая фаза")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                }
            }
            .padding()
        }
        .padding()
    }
    
    // MARK: - Helpers
    private func getDaysForMonth(_ date: Date) -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let firstDay = calendar.dateInterval(of: .month, for: date)?.start else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let adjustedFirstWeekday = (firstWeekday + 5) % 7 // Convert to Monday = 0
        
        var days: [Date?] = Array(repeating: nil, count: adjustedFirstWeekday)
        
        var currentDate = firstDay
        while calendar.isDate(currentDate, equalTo: date, toGranularity: .month) {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        // Fill remaining cells
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days
    }
    
    private func hasCycleOnDate(_ date: Date) -> Bool {
        let cycles = cycleManager.getCyclesForMonth(date)
        return cycles.contains { cycle in
            guard let start = cycle.startDate else { return false }
            let daysSinceStart = calendar.dateComponents([.day], from: start, to: date).day ?? 0
            return daysSinceStart >= 0 && daysSinceStart < cycleManager.averagePeriodLength
        }
    }
    
    private func previousMonth() {
        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }
    
    private func nextMonth() {
        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }
}

