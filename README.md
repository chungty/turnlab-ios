# Turn Lab

A ski instruction iOS app that guides skiers through structured progression from Beginner to Expert, featuring curated video content, self-assessments, and skill tracking.

## Features

- **Skill Progression**: 20 skills across 4 levels (Beginner, Novice, Intermediate, Expert)
- **5 Domains**: Balance, Edge Control, Rotary Movements, Pressure Management, Terrain Adaptation
- **Curated Content**: YouTube videos, tips, drills, and checklists for each skill
- **Self-Assessment**: Track your progress with context-aware ratings
- **Onboarding Quiz**: 12-question assessment to determine starting level
- **Premium Unlock**: $4.99 one-time purchase for Novice+ content
- **Home Screen Widget**: Quick access to your focus skill

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Project Setup

### 1. Create Xcode Project

1. Open Xcode
2. File → New → Project
3. Select "App" under iOS
4. Configure:
   - Product Name: `TurnLab`
   - Organization Identifier: `com.turnlab`
   - Interface: SwiftUI
   - Language: Swift
   - Storage: Core Data ✓
   - Include Tests ✓

### 2. Add Source Files

1. Remove the auto-generated ContentView.swift
2. Drag the following folders into your project:
   - `TurnLab/` (all subdirectories)
   - `TurnLabTests/`
   - `TurnLabWidget/`

### 3. Configure App Groups

1. Select your project in the navigator
2. Select TurnLab target → Signing & Capabilities
3. Add "App Groups" capability
4. Add group: `group.com.turnlab.app`
5. Repeat for TurnLabWidget target

### 4. Add Widget Extension

1. File → New → Target
2. Select "Widget Extension"
3. Product Name: `TurnLabWidget`
4. Include Configuration Intent: No
5. Replace generated files with files from `TurnLabWidget/`

### 5. Configure Core Data Model

1. Create `TurnLab.xcdatamodeld` if not already present
2. Add entities:
   - **UserEntity**: id (UUID), currentLevel (Int16), focusSkillId (String?), createdAt (Date), updatedAt (Date)
   - **AssessmentEntity**: id (UUID), skillId (String), context (Int16), rating (Int16), date (Date), notes (String?)
   - **PreferencesEntity**: id (UUID), isPremiumUnlocked (Bool), premiumUnlockedAt (Date?), notificationsEnabled (Bool)

### 6. Add StoreKit Configuration (for testing)

1. File → New → File
2. Select "StoreKit Configuration File"
3. Name: `Configuration.storekit`
4. Add product:
   - Reference Name: Premium
   - Product ID: `com.turnlab.premium`
   - Type: Non-Consumable
   - Price: $4.99

## Project Structure

```
TurnLab/
├── App/                    # App entry point, DI, state
├── Design/                 # Colors, Typography, Spacing
├── Components/             # Reusable UI components
├── Domain/
│   ├── Models/             # Data models (Skill, Rating, etc.)
│   └── Protocols/          # Repository protocols
├── Data/
│   └── Repositories/       # Data access implementations
├── Services/               # Business logic services
├── Infrastructure/
│   ├── CoreData/           # Persistence layer
│   └── StoreKit/           # In-app purchases
├── Features/
│   ├── Onboarding/         # Quiz and level selection
│   ├── Home/               # Dashboard
│   ├── SkillBrowser/       # Skill catalog
│   ├── SkillDetail/        # Skill content view
│   ├── Assessment/         # Rating input
│   ├── Profile/            # Progress tracking
│   └── Settings/           # Preferences & premium
├── Navigation/             # Router and routes
└── Resources/
    └── Content/            # JSON content files
```

## Architecture

- **MVVM + Repository Pattern**: ViewModels access data through repository protocols
- **Protocol-based DI**: DIContainer provides concrete implementations
- **Offline-first**: All non-video content bundled in app
- **NavigationStack**: iOS 17+ type-safe navigation

## Content

The app includes:
- **20 Skills**: 5 per level, covering all PSIA skill domains
- **12 Quiz Questions**: Scenario-based for level determination
- **22 Video References**: Curated from Stomp It Tutorials and Ski School by Elate Media

## Testing

```bash
xcodebuild test -project TurnLab.xcodeproj -scheme TurnLab \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  CODE_SIGNING_ALLOWED=NO
```

## Build

```bash
xcodebuild -project TurnLab.xcodeproj -scheme TurnLab \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  clean build CODE_SIGNING_ALLOWED=NO
```

## License

Copyright © 2024 Turn Lab. All rights reserved.
