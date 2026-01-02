//
//  UnifiedCalendarView.swift
//  Stage
//
//  Created by Artem Menshikov on 01.01.2026.
//

import SwiftUI
import CoreData
import UIKit

struct UnifiedCalendarView: View {
    @ObservedObject var cycleManager: CycleManager
    @ObservedObject var localizationManager = LocalizationManager.shared
    @ObservedObject var adManager = AdManager.shared
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var showingSymptomsSheet = false
    @State private var selectedIntensity = 2
    @State private var selectedMood = 3
    @State private var selectedEnergy = 3
    @State private var selectedPain = 0
    @State private var notes = ""
    @State private var editingDate: Date?
    @AppStorage("hasSeenInstructions") private var hasSeenInstructions = false
    
    private var shouldShowInstructions: Bool {
        !hasSeenInstructions && cycleManager.getAllCycles().isEmpty
    }
    
    private let calendar = Calendar.current
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = localizationManager.getLocale()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    
    @Environment(\.colorScheme) var colorScheme
    
    // Определяем, iPad ли это
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    // Размеры для iPad
    private var dayCellSize: CGFloat {
        isIPad ? 60 : 40
    }
    
    private var indicatorSize: CGFloat {
        isIPad ? 10 : 6
    }
    
    private var dropIconSize: CGFloat {
        isIPad ? 14 : 9
    }
    
    private var dayFontSize: CGFloat {
        isIPad ? 18 : 15
    }
    
    // Интервалы для iPad
    private var gridSpacing: CGFloat {
        isIPad ? 12 : 6
    }
    
    private var gridItemSpacing: CGFloat {
        isIPad ? 8 : 4
    }
    
    private var calendarPadding: CGFloat {
        isIPad ? 24 : 12
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignColors.backgroundGradient(colorScheme: colorScheme)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Instructions card (show if no cycles or first time)
                        if shouldShowInstructions {
                            instructionsCard
                        }
                        
                        // Month header
                        monthHeader
                        
                        // Weekday headers
                        weekdayHeaders
                        
                        // Calendar grid
                        calendarGrid
                        
                        // Predictions and info
                        predictionsCard
                        
                        // Legend
                        legend
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("calendar".localized)
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingSymptomsSheet) {
                symptomsSheet
            }
            .onAppear {
                // Track view for ad display logic (no visual ad shown yet)
                if adManager.shouldShowInterstitialAd(in: .calendar) {
                    adManager.showInterstitialAd(in: .calendar)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Для iPad - всегда stack style
    }
    
    // MARK: - Instructions Card
    private var instructionsCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("how_to_use".localized)
                        .font(.title3)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: {
                        hasSeenInstructions = true
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    instructionStep(
                        number: "1",
                        icon: "hand.tap.fill",
                        title: "mark_period_day".localized,
                        description: "mark_period_description".localized
                    )
                    
                    instructionStep(
                        number: "2",
                        icon: "hand.point.up.left.fill",
                        title: "add_symptoms".localized,
                        description: "add_symptoms_description".localized
                    )
                    
                    instructionStep(
                        number: "3",
                        icon: "chart.line.uptrend.xyaxis",
                        title: "view_predictions".localized,
                        description: "view_predictions_description".localized
                    )
                }
            }
            .padding()
        }
        .padding(.horizontal, 16)
    }
    
    private func instructionStep(number: String, icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(DesignColors.purpleMedium.opacity(0.2))
                    .frame(width: 32, height: 32)
                Text(number)
                    .font(.headline)
                    .foregroundColor(DesignColors.purpleMedium)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(DesignColors.purpleMedium)
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
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
            
            Text(dateFormatter.string(from: currentMonth))
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
            ForEach(["mon".localized, "tue".localized, "wed".localized, "thu".localized, "fri".localized, "sat".localized, "sun".localized], id: \.self) { day in
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
        let columns = Array(repeating: GridItem(.flexible(), spacing: gridItemSpacing), count: 7)
        
        return LazyVGrid(columns: columns, spacing: gridSpacing) {
            ForEach(Array(days.enumerated()), id: \.offset) { index, date in
                if let date = date {
                    dayCell(date: date)
                } else {
                    Color.clear
                        .frame(height: dayCellSize)
                }
            }
        }
        .padding(.horizontal, calendarPadding)
    }
    
    // MARK: - Day Cell
    private func dayCell(date: Date) -> some View {
        let phase = cycleManager.getPhase(for: date)
        let isToday = calendar.isDateInToday(date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let hasPeriod = hasPeriodOnDate(date)
        
        // Определяем цвет фона
        let backgroundColor: Color = {
            if isSelected {
                return DesignColors.purpleMedium
            } else if hasPeriod {
                // Только реально отмеченные дни - ярко-красные
                return DesignColors.periodColor.opacity(0.6)
            } else {
                // Для неотмеченных дней показываем фазы с легким фоном
                switch phase {
                case .period:
                    // Прогнозируемый период - легкий фон, но видимый
                    return DesignColors.periodColor.opacity(0.15)
                case .ovulation:
                    return DesignColors.ovulationColor.opacity(0.3)
                case .follicular:
                    return DesignColors.follicularColor.opacity(0.2)
                case .luteal:
                    return DesignColors.lutealColor.opacity(0.2)
                }
            }
        }()
        
        let textColor: Color = {
            if isSelected {
                return .white
            } else if hasPeriod {
                return .white
            } else if isToday {
                return DesignColors.purpleMedium
            } else {
                switch phase {
                case .ovulation:
                    return .white
                case .period:
                    // Прогнозируемый период - обычный цвет текста
                    return .primary
                default:
                    return .primary
                }
            }
        }()
        
        return Button(action: {
            selectedDate = date
            // Тап = отметить/снять менструацию
            togglePeriod(date: date)
        }) {
            VStack(spacing: 4) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: dayFontSize, weight: isToday ? .bold : .regular))
                    .foregroundColor(textColor)
                
                // Индикатор - всегда показываем для всех дней
                Group {
                    if hasPeriod {
                        Image(systemName: "drop.fill")
                            .font(.system(size: dropIconSize))
                            .foregroundColor(.white)
                    } else {
                        // Кружочек для фазы - всегда видимый, даже если фон прозрачный
                        Circle()
                            .fill(phase.color)
                            .frame(width: indicatorSize, height: indicatorSize)
                            .shadow(color: phase.color.opacity(0.4), radius: 2, x: 0, y: 1)
                            .overlay(
                                Circle()
                                    .stroke(phase.color.opacity(0.6), lineWidth: 0.5)
                            )
                    }
                }
                .frame(height: indicatorSize + 4) // Гарантируем место для индикатора
            }
            .frame(width: dayCellSize, height: dayCellSize)
            .background(
                Group {
                    if isToday && !isSelected {
                        Circle()
                            .fill(backgroundColor)
                            .overlay(
                                Circle()
                                    .stroke(DesignColors.purpleMedium, lineWidth: 2)
                            )
                    } else {
                        Circle()
                            .fill(backgroundColor)
                    }
                }
            )
        }
        .contextMenu {
            // Меню для отмеченного дня
            if hasPeriod {
                Button(action: {
                    editingDate = date
                    loadSymptomsForDate(date)
                    showingSymptomsSheet = true
                }) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("edit_symptoms".localized)
                    }
                }
                
                Button(action: {
                    deletePeriod(date: date)
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("delete_mark".localized)
                    }
                }
            } else {
                // Меню для неотмеченного дня
                Button(action: {
                    editingDate = date
                    loadSymptomsForDate(date)
                    showingSymptomsSheet = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("add_symptoms_menu".localized)
                    }
                }
            }
        }
    }
    
    // MARK: - Predictions Card
    private var predictionsCard: some View {
        GlassCard {
            VStack(spacing: 10) {
                HStack {
                    Text("predictions".localized)
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                }
                
                if let nextPeriod = cycleManager.upcomingPeriodDate {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .foregroundColor(DesignColors.periodColor)
                            .font(.system(size: 16))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("next_period".localized)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(nextPeriod, style: .date)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        Spacer()
                        if let days = daysUntil(nextPeriod) {
                            Text("days_in".localized.replacingOccurrences(of: "{days}", with: "\(days)"))
                                .font(.caption2)
                                .foregroundColor(DesignColors.purpleMedium)
                        }
                    }
                }
            }
            .padding(12)
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Legend
    private var legend: some View {
        GlassCard {
            VStack(spacing: 10) {
                HStack {
                    Text("legend".localized)
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                }
                
                VStack(spacing: 8) {
                    legendRow(
                        color: DesignColors.periodColor.opacity(0.5),
                        isPeriod: true,
                        text: "menstruation_tap".localized
                    )
                    
                    legendRow(
                        color: DesignColors.follicularColor.opacity(0.2),
                        isPeriod: false,
                        text: "follicular".localized
                    )
                    
                    legendRow(
                        color: DesignColors.ovulationColor.opacity(0.3),
                        isPeriod: false,
                        text: "ovulation".localized
                    )
                    
                    legendRow(
                        color: DesignColors.lutealColor.opacity(0.2),
                        isPeriod: false,
                        text: "luteal".localized
                    )
                }
                
                VStack(spacing: 6) {
                    HStack {
                        Image(systemName: "hand.tap.fill")
                            .font(.caption)
                            .foregroundColor(DesignColors.purpleMedium)
                        Text("short_tap".localized)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    
                    HStack {
                        Image(systemName: "hand.point.up.left.fill")
                            .font(.caption)
                            .foregroundColor(DesignColors.purpleMedium)
                        Text("long_tap".localized)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                .padding(.top, 4)
            }
            .padding(12)
        }
        .padding(.horizontal, 16)
    }
    
    private func legendRow(color: Color, isPeriod: Bool, text: String) -> some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 5)
                .fill(color)
                .frame(width: 24, height: 24)
                .overlay(
                    Group {
                        if isPeriod {
                            Image(systemName: "drop.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.white)
                        } else {
                            // Для фаз используем яркий цвет точки
                            let dotColor: Color = {
                                if color == DesignColors.follicularColor.opacity(0.2) {
                                    return DesignColors.follicularColor
                                } else if color == DesignColors.ovulationColor.opacity(0.3) {
                                    return DesignColors.ovulationColor
                                } else {
                                    return DesignColors.lutealColor
                                }
                            }()
                            Circle()
                                .fill(dotColor)
                                .frame(width: 6, height: 6)
                        }
                    }
                )
            Text(text)
                .font(.caption)
                .lineLimit(1)
            Spacer()
        }
    }
    
    // MARK: - Symptoms Sheet
    private var symptomsSheet: some View {
        NavigationView {
            Form {
                Section(header: Text("symptoms_for".localized.replacingOccurrences(of: "{date}", with: editingDate != nil ? formatDate(editingDate!) : ""))) {
                    VStack(spacing: 16) {
                        SymptomRatingView(title: "intensity".localized, icon: "drop.fill", rating: $selectedIntensity)
                        SymptomRatingView(title: "mood".localized, icon: "heart.fill", rating: $selectedMood)
                        SymptomRatingView(title: "energy".localized, icon: "bolt.fill", rating: $selectedEnergy)
                        SymptomRatingView(title: "pain".localized, icon: "exclamationmark.triangle.fill", rating: $selectedPain)
                    }
                }
                
                Section(header: Text("notes".localized)) {
                    TextField("add_note".localized, text: $notes)
                        .lineLimit(6)
                }
            }
            .navigationTitle("symptoms".localized)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("cancel".localized) {
                showingSymptomsSheet = false
            })
            .navigationBarItems(trailing: Button("save".localized) {
                if let date = editingDate {
                    saveSymptomsForDate(date)
                }
                showingSymptomsSheet = false
            })
            .onAppear {
                if editingDate == nil {
                    editingDate = selectedDate
                    loadSymptomsForDate(selectedDate)
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func getDaysForMonth(_ date: Date) -> [Date?] {
        guard let firstDay = calendar.dateInterval(of: .month, for: date)?.start else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let adjustedFirstWeekday = (firstWeekday + 5) % 7
        
        var days: [Date?] = Array(repeating: nil, count: adjustedFirstWeekday)
        
        var currentDate = firstDay
        while calendar.isDate(currentDate, equalTo: date, toGranularity: .month) {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days
    }
    
    private func hasPeriodOnDate(_ date: Date) -> Bool {
        let cycles = cycleManager.getAllCycles()
        return cycles.contains { cycle in
            guard let start = cycle.startDate else { return false }
            
            // Проверяем точное совпадение даты с началом цикла
            if calendar.isDate(start, inSameDayAs: date) {
                return true
            }
            
            // Если endDate установлен, проверяем, входит ли дата в диапазон
            if let end = cycle.endDate {
                let daysSinceStart = calendar.dateComponents([.day], from: start, to: date).day ?? 0
                let daysSinceEnd = calendar.dateComponents([.day], from: end, to: date).day ?? 0
                // Дата должна быть между start и end (включительно)
                return daysSinceStart >= 0 && daysSinceEnd <= 0
            }
            
            return false
        }
    }
    
    private func togglePeriod(date: Date) {
        if hasPeriodOnDate(date) {
            // Удалить отметку
            deletePeriod(date: date)
        } else {
            // Добавить отметку - начать новый цикл только на один день
            cycleManager.startCycle(startDate: date)
            // Сразу завершить цикл на тот же день, чтобы отметить только один день
            if let cycle = cycleManager.getCurrentCycle(), 
               let start = cycle.startDate,
               calendar.isDate(start, inSameDayAs: date) {
                cycleManager.endCycle(cycle: cycle, endDate: date)
            }
            // Обновить напоминания после изменения цикла
            ReminderManager.shared.scheduleReminders(for: cycleManager)
        }
    }
    
    private func deletePeriod(date: Date) {
        let cycles = cycleManager.getAllCycles()
        // Найти циклы, которые точно соответствуют этой дате
        let cyclesToDelete = cycles.filter { cycle in
            guard let start = cycle.startDate else { return false }
            // Проверяем точное совпадение даты
            if calendar.isDate(start, inSameDayAs: date) {
                // Если endDate не установлен или совпадает с датой
                if cycle.endDate == nil {
                    return true
                }
                if let end = cycle.endDate, calendar.isDate(end, inSameDayAs: date) {
                    return true
                }
            }
            // Если это диапазон, проверяем, входит ли дата в него
            if let end = cycle.endDate {
                let daysSinceStart = calendar.dateComponents([.day], from: start, to: date).day ?? 0
                let daysSinceEnd = calendar.dateComponents([.day], from: end, to: date).day ?? 0
                return daysSinceStart >= 0 && daysSinceEnd <= 0
            }
            return false
        }
        
        // Удалить найденные циклы
        for cycle in cyclesToDelete {
            cycleManager.deleteCycle(cycle)
        }
        
        // Обновить напоминания после изменения цикла
        ReminderManager.shared.scheduleReminders(for: cycleManager)
    }
    
    private func loadSymptomsForDate(_ date: Date) {
        let cycles = cycleManager.getAllCycles()
        if let cycle = cycles.first(where: { cycle in
            guard let start = cycle.startDate else { return false }
            let daysSinceStart = calendar.dateComponents([.day], from: start, to: date).day ?? 0
            return daysSinceStart == 0 // Только первый день цикла
        }) {
            selectedIntensity = Int(cycle.intensity)
            selectedMood = Int(cycle.mood)
            selectedEnergy = Int(cycle.energy)
            selectedPain = Int(cycle.pain)
            notes = cycle.notes ?? ""
        } else {
            resetForm()
        }
    }
    
    private func saveSymptomsForDate(_ date: Date) {
        let cycles = cycleManager.getAllCycles()
        if let cycle = cycles.first(where: { cycle in
            guard let start = cycle.startDate else { return false }
            let daysSinceStart = calendar.dateComponents([.day], from: start, to: date).day ?? 0
            return daysSinceStart == 0
        }) {
            // Сохранение через CycleManager
            cycleManager.updateCycleSymptoms(
                cycle: cycle,
                intensity: selectedIntensity,
                mood: selectedMood,
                energy: selectedEnergy,
                pain: selectedPain,
                notes: notes.isEmpty ? nil : notes
            )
        } else {
            // Создать новый цикл с симптомами
            cycleManager.startCycle(
                startDate: date,
                intensity: selectedIntensity,
                mood: selectedMood,
                energy: selectedEnergy,
                pain: selectedPain,
                notes: notes.isEmpty ? nil : notes
            )
        }
        // Обновить напоминания после изменения цикла
        ReminderManager.shared.scheduleReminders(for: cycleManager)
    }
    
    private func resetForm() {
        selectedIntensity = 2
        selectedMood = 3
        selectedEnergy = 3
        selectedPain = 0
        notes = ""
    }
    
    private func daysUntil(_ date: Date) -> Int? {
        return calendar.dateComponents([.day], from: Date(), to: date).day
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = localizationManager.getLocale()
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: date)
    }
    
    private func previousMonth() {
        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }
    
    private func nextMonth() {
        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }
}


