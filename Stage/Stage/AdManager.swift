//
//  AdManager.swift
//  Stage
//
//  Created by Artem Menshikov on 01.01.2026.
//

import Foundation
import SwiftUI

// MARK: - Ad Provider
enum AdProvider: String, CaseIterable {
    case admob = "admob"
    case unityAds = "unity_ads"
    case yandex = "yandex"
    
    var displayName: String {
        switch self {
        case .admob: return "Google AdMob"
        case .unityAds: return "Unity Ads"
        case .yandex: return "Yandex Ads"
        }
    }
}

// MARK: - Ad Manager
class AdManager: ObservableObject {
    static let shared = AdManager()
    
    @Published var isAdEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isAdEnabled, forKey: "adEnabled")
            if isAdEnabled {
                initializeAds()
            } else {
                removeAds()
            }
        }
    }
    
    @Published var adFrequency: AdFrequency {
        didSet {
            UserDefaults.standard.set(adFrequency.rawValue, forKey: "adFrequency")
        }
    }
    
    @Published var selectedProvider: AdProvider {
        didSet {
            UserDefaults.standard.set(selectedProvider.rawValue, forKey: "adProvider")
            if isAdEnabled {
                initializeAds()
            }
        }
    }
    
    // MARK: - AdMob IDs
    private let admobBannerAdUnitID = "ca-app-pub-3940256099942544/2934735716" // Test ID
    private let admobInterstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910" // Test ID
    private let admobRewardedAdUnitID = "ca-app-pub-3940256099942544/1712485313" // Test ID
    private let admobAppID = "ca-app-pub-3940256099942544~1458002511" // Test App ID
    
    // MARK: - Unity Ads IDs
    private let unityAdsGameID = "1234567" // Replace with your Unity Ads Game ID
    private let unityAdsBannerPlacementID = "Banner_Android" // Replace with your placement ID
    private let unityAdsInterstitialPlacementID = "Interstitial_Android" // Replace with your placement ID
    private let unityAdsRewardedPlacementID = "Rewarded_Android" // Replace with your placement ID
    private let unityAdsTestMode = true // Set to false for production
    
    // MARK: - Yandex Ads IDs
    private let yandexAdUnitID = "R-M-XXXXXX-XX" // Replace with your Yandex Ad Unit ID
    private let yandexBannerBlockID = "R-M-XXXXXX-XX" // Replace with your banner block ID
    private let yandexInterstitialBlockID = "R-M-XXXXXX-XX" // Replace with your interstitial block ID
    private let yandexRewardedBlockID = "R-M-XXXXXX-XX" // Replace with your rewarded block ID
    
    // Ad state tracking
    @Published var isBannerAdReady = false
    @Published var isInterstitialAdReady = false
    @Published var isRewardedAdReady = false
    
    // Ad display counters
    private var calendarViewCount = 0
    private var statisticsViewCount = 0
    private var adDisplayThreshold = 3 // Show ad after N views
    
    private init() {
        // Load saved settings
        self.isAdEnabled = UserDefaults.standard.bool(forKey: "adEnabled")
        let savedFrequency = UserDefaults.standard.string(forKey: "adFrequency") ?? AdFrequency.normal.rawValue
        self.adFrequency = AdFrequency(rawValue: savedFrequency) ?? .normal
        let savedProvider = UserDefaults.standard.string(forKey: "adProvider") ?? AdProvider.admob.rawValue
        self.selectedProvider = AdProvider(rawValue: savedProvider) ?? .admob
        
        if isAdEnabled {
            initializeAds()
        }
    }
    
    // MARK: - Initialization
    private func initializeAds() {
        print("AdManager: Initializing ads with provider: \(selectedProvider.displayName)")
        
        switch selectedProvider {
        case .admob:
            initializeAdMob()
        case .unityAds:
            initializeUnityAds()
        case .yandex:
            initializeYandexAds()
        }
    }
    
    private func initializeAdMob() {
        // TODO: Initialize Google Mobile Ads SDK
        // GADMobileAds.sharedInstance().start(completionHandler: nil)
        // GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [/* test devices */]
        print("AdManager: Initializing AdMob with App ID: \(admobAppID)")
        isBannerAdReady = false
        isInterstitialAdReady = false
        isRewardedAdReady = false
    }
    
    private func initializeUnityAds() {
        // TODO: Initialize Unity Ads SDK
        // UnityAds.initialize(unityAdsGameID, testMode: unityAdsTestMode, initializationDelegate: self)
        print("AdManager: Initializing Unity Ads with Game ID: \(unityAdsGameID)")
        print("AdManager: Unity Ads Test Mode: \(unityAdsTestMode)")
        isBannerAdReady = false
        isInterstitialAdReady = false
        isRewardedAdReady = false
    }
    
    private func initializeYandexAds() {
        // TODO: Initialize Yandex Mobile Ads SDK
        // YMAMobileAds.initializeSDK()
        print("AdManager: Initializing Yandex Ads with Ad Unit ID: \(yandexAdUnitID)")
        isBannerAdReady = false
        isInterstitialAdReady = false
        isRewardedAdReady = false
    }
    
    private func removeAds() {
        // TODO: Remove/cleanup ads
        print("AdManager: Removing ads...")
        isBannerAdReady = false
        isInterstitialAdReady = false
        isRewardedAdReady = false
    }
    
    // MARK: - Ad Loading
    func loadBannerAd() {
        guard isAdEnabled else { return }
        
        switch selectedProvider {
        case .admob:
            loadAdMobBanner()
        case .unityAds:
            loadUnityAdsBanner()
        case .yandex:
            loadYandexBanner()
        }
    }
    
    func loadInterstitialAd() {
        guard isAdEnabled else { return }
        
        switch selectedProvider {
        case .admob:
            loadAdMobInterstitial()
        case .unityAds:
            loadUnityAdsInterstitial()
        case .yandex:
            loadYandexInterstitial()
        }
    }
    
    func loadRewardedAd() {
        guard isAdEnabled else { return }
        
        switch selectedProvider {
        case .admob:
            loadAdMobRewarded()
        case .unityAds:
            loadUnityAdsRewarded()
        case .yandex:
            loadYandexRewarded()
        }
    }
    
    // MARK: - AdMob Loading
    private func loadAdMobBanner() {
        // TODO: Load AdMob banner
        // let request = GADRequest()
        // bannerView.load(request)
        print("AdManager: Loading AdMob banner ad with ID: \(admobBannerAdUnitID)")
    }
    
    private func loadAdMobInterstitial() {
        // TODO: Load AdMob interstitial
        // let request = GADRequest()
        // interstitial.load(request)
        print("AdManager: Loading AdMob interstitial ad with ID: \(admobInterstitialAdUnitID)")
    }
    
    private func loadAdMobRewarded() {
        // TODO: Load AdMob rewarded
        // let request = GADRequest()
        // rewardedAd.load(request)
        print("AdManager: Loading AdMob rewarded ad with ID: \(admobRewardedAdUnitID)")
    }
    
    // MARK: - Unity Ads Loading
    private func loadUnityAdsBanner() {
        // TODO: Load Unity Ads banner
        // UnityAds.load(unityAdsBannerPlacementID, loadDelegate: self)
        print("AdManager: Loading Unity Ads banner with placement: \(unityAdsBannerPlacementID)")
    }
    
    private func loadUnityAdsInterstitial() {
        // TODO: Load Unity Ads interstitial
        // UnityAds.load(unityAdsInterstitialPlacementID, loadDelegate: self)
        print("AdManager: Loading Unity Ads interstitial with placement: \(unityAdsInterstitialPlacementID)")
    }
    
    private func loadUnityAdsRewarded() {
        // TODO: Load Unity Ads rewarded
        // UnityAds.load(unityAdsRewardedPlacementID, loadDelegate: self)
        print("AdManager: Loading Unity Ads rewarded with placement: \(unityAdsRewardedPlacementID)")
    }
    
    // MARK: - Yandex Ads Loading
    private func loadYandexBanner() {
        // TODO: Load Yandex banner
        // let adRequest = YMAMutableAdRequest()
        // bannerLoader.loadAd(with: adRequest)
        print("AdManager: Loading Yandex banner with block ID: \(yandexBannerBlockID)")
    }
    
    private func loadYandexInterstitial() {
        // TODO: Load Yandex interstitial
        // let adRequest = YMAMutableAdRequest()
        // interstitialLoader.loadAd(with: adRequest)
        print("AdManager: Loading Yandex interstitial with block ID: \(yandexInterstitialBlockID)")
    }
    
    private func loadYandexRewarded() {
        // TODO: Load Yandex rewarded
        // let adRequest = YMAMutableAdRequest()
        // rewardedLoader.loadAd(with: adRequest)
        print("AdManager: Loading Yandex rewarded with block ID: \(yandexRewardedBlockID)")
    }
    
    // MARK: - Ad Display Logic
    func shouldShowInterstitialAd(in view: AdPlacement) -> Bool {
        guard isAdEnabled, isInterstitialAdReady else { return false }
        
        switch view {
        case .calendar:
            calendarViewCount += 1
            return calendarViewCount % adFrequency.viewThreshold == 0
        case .statistics:
            statisticsViewCount += 1
            return statisticsViewCount % adFrequency.viewThreshold == 0
        case .settings:
            // Settings view typically doesn't show interstitial ads
            return false
        }
    }
    
    func showInterstitialAd(in view: AdPlacement) {
        guard shouldShowInterstitialAd(in: view) else { return }
        
        switch selectedProvider {
        case .admob:
            showAdMobInterstitial()
        case .unityAds:
            showUnityAdsInterstitial()
        case .yandex:
            showYandexInterstitial()
        }
    }
    
    func showRewardedAd(completion: @escaping (Bool) -> Void) {
        guard isAdEnabled, isRewardedAdReady else {
            completion(false)
            return
        }
        
        switch selectedProvider {
        case .admob:
            showAdMobRewarded(completion: completion)
        case .unityAds:
            showUnityAdsRewarded(completion: completion)
        case .yandex:
            showYandexRewarded(completion: completion)
        }
    }
    
    // MARK: - AdMob Display
    private func showAdMobInterstitial() {
        // TODO: Show AdMob interstitial
        // if interstitial.isReady {
        //     interstitial.present(fromRootViewController: rootViewController)
        // }
        print("AdManager: Showing AdMob interstitial ad")
    }
    
    private func showAdMobRewarded(completion: @escaping (Bool) -> Void) {
        // TODO: Show AdMob rewarded
        // if rewardedAd.isReady {
        //     rewardedAd.present(fromRootViewController: rootViewController, userDidEarnRewardHandler: {
        //         completion(true)
        //     })
        // }
        print("AdManager: Showing AdMob rewarded ad")
        completion(true)
    }
    
    // MARK: - Unity Ads Display
    private func showUnityAdsInterstitial() {
        // TODO: Show Unity Ads interstitial
        // UnityAds.show(UnityAdsManager.shared, placementId: unityAdsInterstitialPlacementID)
        print("AdManager: Showing Unity Ads interstitial")
    }
    
    private func showUnityAdsRewarded(completion: @escaping (Bool) -> Void) {
        // TODO: Show Unity Ads rewarded
        // UnityAds.show(UnityAdsManager.shared, placementId: unityAdsRewardedPlacementID)
        print("AdManager: Showing Unity Ads rewarded")
        completion(true)
    }
    
    // MARK: - Yandex Ads Display
    private func showYandexInterstitial() {
        // TODO: Show Yandex interstitial
        // interstitialAd?.show(from: rootViewController)
        print("AdManager: Showing Yandex interstitial")
    }
    
    private func showYandexRewarded(completion: @escaping (Bool) -> Void) {
        // TODO: Show Yandex rewarded
        // rewardedAd?.show(from: rootViewController)
        print("AdManager: Showing Yandex rewarded")
        completion(true)
    }
    
    // MARK: - Ad Placement Helpers
    func resetViewCounters() {
        calendarViewCount = 0
        statisticsViewCount = 0
    }
    
    // MARK: - Ad Unit IDs (for future SDK integration)
    func getBannerAdUnitID() -> String {
        switch selectedProvider {
        case .admob:
            return admobBannerAdUnitID
        case .unityAds:
            return unityAdsBannerPlacementID
        case .yandex:
            return yandexBannerBlockID
        }
    }
    
    func getInterstitialAdUnitID() -> String {
        switch selectedProvider {
        case .admob:
            return admobInterstitialAdUnitID
        case .unityAds:
            return unityAdsInterstitialPlacementID
        case .yandex:
            return yandexInterstitialBlockID
        }
    }
    
    func getRewardedAdUnitID() -> String {
        switch selectedProvider {
        case .admob:
            return admobRewardedAdUnitID
        case .unityAds:
            return unityAdsRewardedPlacementID
        case .yandex:
            return yandexRewardedBlockID
        }
    }
    
    func getAppID() -> String {
        switch selectedProvider {
        case .admob:
            return admobAppID
        case .unityAds:
            return unityAdsGameID
        case .yandex:
            return yandexAdUnitID
        }
    }
}

// MARK: - Ad Frequency
enum AdFrequency: String, CaseIterable {
    case low = "low"
    case normal = "normal"
    case high = "high"
    
    var displayName: String {
        switch self {
        case .low: return "low".localized
        case .normal: return "normal".localized
        case .high: return "high".localized
        }
    }
    
    var viewThreshold: Int {
        switch self {
        case .low: return 5
        case .normal: return 3
        case .high: return 2
        }
    }
}

// MARK: - Ad Placement
enum AdPlacement {
    case calendar
    case statistics
    case settings
}

// MARK: - Ad View Placeholder (for future use)
struct AdBannerPlaceholder: View {
    @ObservedObject var adManager = AdManager.shared
    
    var body: some View {
        Group {
            if adManager.isAdEnabled && adManager.isBannerAdReady {
                // TODO: Replace with actual ad view when SDK is integrated
                // AdBannerView(adUnitID: adManager.getBannerAdUnitID())
                EmptyView()
            } else {
                EmptyView()
            }
        }
    }
}

struct AdInterstitialPlaceholder: View {
    @ObservedObject var adManager = AdManager.shared
    let placement: AdPlacement
    
    var body: some View {
        Group {
            if adManager.isAdEnabled {
                // This will be called when ad should be shown
                // TODO: Show interstitial ad when SDK is integrated
                EmptyView()
            } else {
                EmptyView()
            }
        }
        .onAppear {
            adManager.showInterstitialAd(in: placement)
        }
    }
}

