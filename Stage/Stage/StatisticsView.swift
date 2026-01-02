//
//  StatisticsView.swift
//  Stage
//
//  Created by Artem Menshikov on 01.01.2026.
//

import SwiftUI
import CoreData

struct StatisticsView: View {
    @ObservedObject var cycleManager: CycleManager
    @ObservedObject var localizationManager = LocalizationManager.shared
    @ObservedObject var adManager = AdManager.shared
    @State private var showingSettings = false
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignColors.backgroundGradient(colorScheme: colorScheme)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Overview stats
                        overviewStats
                        
                        // Recent cycles
                        recentCycles
                        
                        // Settings button
                        settingsButton
                    }
                    .padding()
                }
            }
            .navigationTitle("statistics".localized)
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingSettings) {
                SettingsView(cycleManager: cycleManager)
            }
            .onAppear {
                // Track view for ad display logic (no visual ad shown yet)
                if adManager.shouldShowInterstitialAd(in: .statistics) {
                    adManager.showInterstitialAd(in: .statistics)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Для iPad - всегда stack style
    }
    
    // MARK: - Overview Stats
    private var overviewStats: some View {
        GlassCard {
            VStack(spacing: 16) {
                HStack {
                    Text("overall_statistics".localized)
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                }
                
                StatRow(title: "total_cycles".localized, value: "\(cycleManager.getAllCycles().count)")
                StatRow(title: "average_cycle_length".localized, value: "\(cycleManager.getAverageCycleLength()) \("days".localized)")
                StatRow(title: "average_period_length".localized, value: "\(cycleManager.averagePeriodLength) \("days".localized)")
                
                if let nextPeriod = cycleManager.upcomingPeriodDate {
                    StatRow(title: "next_period".localized, value: "", style: .date, date: nextPeriod)
                }
            }
            .padding()
        }
    }
    
    // MARK: - Recent Cycles
    private var recentCycles: some View {
        GlassCard {
            VStack(spacing: 16) {
                HStack {
                    Text("recent_cycles".localized)
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                }
                
                Group {
                    let cycles = Array(cycleManager.getAllCycles().prefix(5))
                    
                    if cycles.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 40))
                                .foregroundColor(DesignColors.purpleMedium.opacity(0.5))
                            Text("no_records".localized)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("mark_days_in_calendar".localized)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    } else {
                        ForEach(Array(cycles.enumerated()), id: \.element.id) { index, cycle in
                            CycleRow(cycle: cycle)
                            if index < cycles.count - 1 {
                                Divider()
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Settings Button
    private var settingsButton: some View {
        NeumorphicButton("settings".localized, icon: "gearshape.fill") {
            showingSettings = true
        }
    }
}

// MARK: - Stat Row
struct StatRow: View {
    let title: String
    let value: String
    var style: Text.DateStyle?
    var date: Date?
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            if let style = style, let date = date {
                Text(date, style: style)
                    .font(.headline)
            } else {
                Text(value)
                    .font(.headline)
            }
        }
    }
}

// MARK: - Cycle Row
struct CycleRow: View {
    let cycle: Cycle
    
    var body: some View {
        HStack {
            VStack(spacing: 4) {
                HStack {
                    if let startDate = cycle.startDate {
                        Text(startDate, style: .date)
                            .font(.headline)
                    }
                    Spacer()
                }
                
                HStack {
                    if let endDate = cycle.endDate {
                        Text("\("until".localized) \(endDate, style: .date)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("current".localized)
                            .font(.caption)
                            .foregroundColor(DesignColors.purpleMedium)
                    }
                    Spacer()
                }
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                HStack {
                    Spacer()
                    IntensityIndicator(intensity: Int(cycle.intensity))
                }
                HStack(spacing: 8) {
                    Spacer()
                    if cycle.pain > 0 {
                        Label("\(cycle.pain)", systemImage: "exclamationmark.triangle.fill")
                            .font(.caption2)
                            .foregroundColor(DesignColors.periodColor)
                    }
                }
            }
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @ObservedObject var cycleManager: CycleManager
    @ObservedObject var localizationManager = LocalizationManager.shared
    @ObservedObject var adManager = AdManager.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var cycleLength: String = "28"
    @State private var periodLength: String = "5"
    @State private var remindersEnabled = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("cycle".localized)) {
                    HStack {
                        Text("average_cycle_length_label".localized)
                        Spacer()
                        TextField("days".localized, text: $cycleLength)
                            .keyboardType(.numberPad)
                            .frame(width: 60)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("average_period_length_label".localized)
                        Spacer()
                        TextField("days".localized, text: $periodLength)
                            .keyboardType(.numberPad)
                            .frame(width: 60)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section(header: Text("reminders".localized)) {
                    Toggle("enable_reminders".localized, isOn: $remindersEnabled)
                }
                
                Section(header: Text("language".localized)) {
                    Picker("language".localized, selection: $localizationManager.currentLanguage) {
                        ForEach(AppLanguage.allCases, id: \.self) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                }
                
                Section(header: Text("ads".localized)) {
                    Toggle("enable_ads".localized, isOn: $adManager.isAdEnabled)
                    
                    if adManager.isAdEnabled {
                        Picker("ad_provider".localized, selection: $adManager.selectedProvider) {
                            ForEach(AdProvider.allCases, id: \.self) { provider in
                                Text(provider.displayName).tag(provider)
                            }
                        }
                        
                        Picker("ad_frequency".localized, selection: $adManager.adFrequency) {
                            ForEach(AdFrequency.allCases, id: \.self) { frequency in
                                Text(frequency.displayName).tag(frequency)
                            }
                        }
                    }
                }
            }
            .navigationTitle("settings".localized)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("cancel".localized) {
                presentationMode.wrappedValue.dismiss()
            })
            .navigationBarItems(trailing: Button("save".localized) {
                if let cycle = Int(cycleLength),
                   let period = Int(periodLength) {
                    cycleManager.updateSettings(cycleLength: cycle, periodLength: period)
                }
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                cycleLength = "\(cycleManager.averageCycleLength)"
                periodLength = "\(cycleManager.averagePeriodLength)"
            }
        }
    }
}

