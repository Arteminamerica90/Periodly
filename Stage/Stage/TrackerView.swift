//
//  TrackerView.swift
//  Stage
//
//  Created by Artem Menshikov on 01.01.2026.
//

import SwiftUI
import CoreData

struct TrackerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var cycleManager: CycleManager
    @State private var showingStartCycle = false
    @State private var showingEndCycle = false
    @State private var selectedIntensity = 2
    @State private var selectedMood = 3
    @State private var selectedEnergy = 3
    @State private var selectedPain = 0
    @State private var notes = ""
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                DesignColors.backgroundGradient(colorScheme: colorScheme)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Current status card
                        if let currentCycle = cycleManager.currentCycle {
                            currentCycleCard(cycle: currentCycle)
                        } else {
                            noCycleCard
                        }
                        
                        // Predictions card
                        predictionsCard
                        
                        // Quick actions
                        if cycleManager.currentCycle == nil {
                            quickStartButton
                        } else {
                            quickEndButton
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Трекер")
            .sheet(isPresented: $showingStartCycle) {
                startCycleSheet
                    .onAppear {
                        resetForm()
                    }
            }
            .sheet(isPresented: $showingEndCycle) {
                endCycleSheet
            }
        }
    }
    
    // MARK: - Current Cycle Card
    private func currentCycleCard(cycle: Cycle) -> some View {
        GlassCard {
            VStack(spacing: 16) {
                HStack {
                    Text("Текущий цикл")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    PhaseBadge(phase: .period)
                }
                
                HStack {
                    if let startDate = cycle.startDate {
                        Text("Начало: \(startDate, style: .date)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                
                HStack {
                    if let days = daysSinceStart(cycle.startDate) {
                        Text("День \(days)")
                            .font(.headline)
                            .foregroundColor(DesignColors.purpleMedium)
                    }
                    Spacer()
                }
                
                Divider()
                
                // Symptoms
                VStack(spacing: 12) {
                    HStack {
                        Text("Интенсивность")
                        Spacer()
                        IntensityIndicator(intensity: Int(cycle.intensity))
                    }
                    
                    HStack {
                        Text("Настроение")
                        Spacer()
                        HStack(spacing: 4) {
                            ForEach(1...5, id: \.self) { index in
                                Image(systemName: index <= cycle.mood ? "star.fill" : "star")
                                    .foregroundColor(index <= cycle.mood ? DesignColors.purpleAccent : Color.gray.opacity(0.3))
                                    .font(.caption)
                            }
                        }
                    }
                    
                    HStack {
                        Text("Энергия")
                        Spacer()
                        HStack(spacing: 4) {
                            ForEach(1...5, id: \.self) { index in
                                Image(systemName: index <= cycle.energy ? "star.fill" : "star")
                                    .foregroundColor(index <= cycle.energy ? DesignColors.purpleAccent : Color.gray.opacity(0.3))
                                    .font(.caption)
                            }
                        }
                    }
                    
                    HStack {
                        Text("Боль")
                        Spacer()
                        HStack(spacing: 4) {
                            ForEach(1...5, id: \.self) { index in
                                Image(systemName: index <= cycle.pain ? "star.fill" : "star")
                                    .foregroundColor(index <= cycle.pain ? DesignColors.periodColor : Color.gray.opacity(0.3))
                                    .font(.caption)
                            }
                        }
                    }
                }
                
                if let notes = cycle.notes, !notes.isEmpty {
                    Divider()
                    HStack {
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - No Cycle Card
    private var noCycleCard: some View {
        GlassCard {
            VStack(spacing: 16) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 50))
                    .foregroundColor(DesignColors.purpleMedium)
                
                Text("Нет активного цикла")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Начните отслеживание, чтобы записать начало менструации")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
    }
    
    // MARK: - Predictions Card
    private var predictionsCard: some View {
        GlassCard {
            VStack(spacing: 16) {
                HStack {
                    Text("Прогнозы")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                }
                
                if let nextPeriod = cycleManager.upcomingPeriodDate {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(DesignColors.periodColor)
                        VStack(spacing: 4) {
                            HStack {
                                Text("Следующая менструация")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            HStack {
                                Text(nextPeriod, style: .date)
                                    .font(.headline)
                                Spacer()
                            }
                        }
                        Spacer()
                        if let days = daysUntil(nextPeriod) {
                            Text("через \(days) дн.")
                                .font(.caption)
                                .foregroundColor(DesignColors.purpleMedium)
                        }
                    }
                }
                
                if let nextOvulation = cycleManager.upcomingOvulationDate {
                    HStack {
                        Image(systemName: "circle.fill")
                            .foregroundColor(DesignColors.ovulationColor)
                        VStack(spacing: 4) {
                            HStack {
                                Text("Овуляция")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            HStack {
                                Text(nextOvulation, style: .date)
                                    .font(.headline)
                                Spacer()
                            }
                        }
                        Spacer()
                        if let days = daysUntil(nextOvulation) {
                            Text("через \(days) дн.")
                                .font(.caption)
                                .foregroundColor(DesignColors.ovulationColor)
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Quick Actions
    private var quickStartButton: some View {
        NeumorphicButton("Начать цикл", icon: "plus.circle.fill") {
            showingStartCycle = true
        }
    }
    
    private var quickEndButton: some View {
        NeumorphicButton("Завершить цикл", icon: "checkmark.circle.fill") {
            showingEndCycle = true
        }
    }
    
    // MARK: - Sheets
    private var startCycleSheet: some View {
        NavigationView {
            Form {
                Section(header: Text("Симптомы")) {
                    VStack(spacing: 16) {
                        SymptomRatingView(title: "Интенсивность", icon: "drop.fill", rating: $selectedIntensity)
                        SymptomRatingView(title: "Настроение", icon: "heart.fill", rating: $selectedMood)
                        SymptomRatingView(title: "Энергия", icon: "bolt.fill", rating: $selectedEnergy)
                        SymptomRatingView(title: "Боль", icon: "exclamationmark.triangle.fill", rating: $selectedPain)
                    }
                }
                
                Section(header: Text("Заметки")) {
                    TextField("Добавить заметку...", text: $notes)
                        .lineLimit(6)
                }
            }
            .navigationTitle("Начать цикл")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Отмена") {
                showingStartCycle = false
            })
            .navigationBarItems(trailing: Button("Сохранить") {
                cycleManager.startCycle(
                    intensity: selectedIntensity,
                    mood: selectedMood,
                    energy: selectedEnergy,
                    pain: selectedPain,
                    notes: notes.isEmpty ? nil : notes
                )
                resetForm()
                showingStartCycle = false
            })
        }
    }
    
    private var endCycleSheet: some View {
        NavigationView {
            Form {
                Section {
                    DatePicker("Дата окончания", selection: .constant(Date()), displayedComponents: .date)
                }
            }
            .navigationTitle("Завершить цикл")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Отмена") {
                showingEndCycle = false
            })
            .navigationBarItems(trailing: Button("Завершить") {
                if let cycle = cycleManager.currentCycle {
                    cycleManager.endCycle(cycle: cycle)
                }
                showingEndCycle = false
            })
        }
    }
    
    // MARK: - Helpers
    private func daysSinceStart(_ date: Date?) -> Int? {
        guard let date = date else { return nil }
        return Calendar.current.dateComponents([.day], from: date, to: Date()).day
    }
    
    private func daysUntil(_ date: Date) -> Int? {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day
        return days
    }
    
    private func resetForm() {
        selectedIntensity = 2
        selectedMood = 3
        selectedEnergy = 3
        selectedPain = 0
        notes = ""
    }
}

