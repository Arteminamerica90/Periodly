# Periodly - Period Tracking App

A minimalist and private period tracking application for iOS, built with SwiftUI.

## Features

- 📅 **Smart Calendar** - Track your period with a single tap
- 📊 **Symptom Tracking** - Monitor mood, energy, pain, and intensity
- 🔮 **Accurate Predictions** - Automatic calculation of next period and ovulation
- 📈 **Statistics & Analytics** - View your cycle history and patterns
- 🔔 **Smart Reminders** - Personalized notifications for period and ovulation
- 🌍 **Multilingual** - English and Russian language support
- 🎨 **Modern Design** - Glassmorphism and neumorphism effects with purple gradient
- 📖 **Educational Blog** - Helpful articles about menstrual health
- 🔒 **Privacy First** - All data stored locally on your device
- 💯 **Free & Ad-Free** - No subscriptions or hidden fees

## Requirements

- iOS 14.0+
- Xcode 14.0+
- Swift 5.0+

## Installation

1. Clone the repository:
```bash
git clone https://github.com/Arteminamerica90/Periodly.git
```

2. Open `Stage.xcodeproj` in Xcode

3. Select your development team in project settings

4. Build and run on simulator or device

## Project Structure

```
Stage/
├── Stage/
│   ├── StageApp.swift          # App entry point
│   ├── ContentView.swift        # Main tab view
│   ├── UnifiedCalendarView.swift # Calendar with tracking
│   ├── StatisticsView.swift     # Statistics and settings
│   ├── BlogView.swift          # Educational articles
│   ├── CycleManager.swift      # Cycle data management
│   ├── ReminderManager.swift   # Notification handling
│   ├── LocalizationManager.swift # Language management
│   ├── AdManager.swift         # Ad infrastructure (Unity Ads, Yandex, AdMob)
│   ├── DesignSystem.swift      # UI components and colors
│   ├── Persistence.swift       # Core Data setup
│   └── Assets.xcassets/        # App icons and colors
└── Stage.xcdatamodeld/         # Core Data model
```

## Technologies

- **SwiftUI** - Modern UI framework
- **Core Data** - Local data persistence
- **UserNotifications** - Reminder system
- **UIKit** - Device detection and compatibility

## Design

- Glassmorphism effects with blur and transparency
- Neumorphism for interactive elements
- Purple gradient background
- Adaptive UI for iPhone and iPad
- Dark and light mode support

## Privacy

All user data is stored locally on the device. No cloud synchronization or data sharing with third parties.

## License

Copyright © 2026 Artem Menshikov. All rights reserved.

## Contact

For questions or support, please open an issue on GitHub.

