# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Paraquip is a Swift/SwiftUI iOS app for paragliding equipment management and check tracking. The app helps pilots keep track of their equipment, schedule regular checks, and monitor performance metrics like wing loading.

## Core Architecture

### App Structure
- **ParaquipApp.swift**: Main app entry point with Core Data setup, database migration, and notification service initialization
- **MainView.swift**: Tab-based navigation with Equipment, Checks, and Performance tabs
- **Core Data Model**: Located in `Paraquip/Model/Model.xcdatamodeld/` with migration support

### Key Models
- **Equipment**: Paragliding equipment (paragliders, harnesses, reserves, gear) with check scheduling and weight ranges
- **Profile**: Equipment sets/configurations with pilot weight and performance calculations
- **LogEntry**: Check and purchase logs for equipment tracking
- **Attachment**: File attachments for equipment records

### Services
- **NotificationService**: Handles equipment check reminders with configurable notification schedules
- **DatabaseMigration**: Manages Core Data schema migrations and legacy data migration
- **LegacyAppPersistence**: Migrates data from previous app versions

### View Structure
- **EquipmentTab/**: Equipment management, profiles, and editing
- **ChecksTab/**: Equipment check scheduling and logging
- **PerformanceTab/**: Wing loading calculations and performance metrics
- **SharedViews/**: Reusable UI components (DocumentPicker, ImagePicker, etc.)

## Development Commands

### Building and Testing
```bash
# Build the app
xcodebuild -scheme Paraquip -configuration Debug build

# Run tests
xcodebuild -scheme Paraquip -destination 'platform=iOS Simulator,name=iPhone 15' test

# Run unit tests specifically
xcodebuild -scheme Paraquip -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ParaquipTests test

# Run UI tests
xcodebuild -scheme Paraquip -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ParaquipUITests test
```

### Fastlane Automation
```bash
# Install fastlane dependencies
bundle install

# Release to App Store (interactive)
bundle exec fastlane release

# Update screenshots
bundle exec fastlane snapshot
```

## Key Patterns and Conventions

### Core Data Usage
- Use `NSManagedObjectContext` extensions for safe operations
- Equipment validation occurs in `validateForInsert()` and `validateForUpdate()`
- Preview contexts available via `.preview` extension
- In-memory containers for testing via `CoreData.inMemoryPersistentContainer`

### Equipment Management
- Equipment types: `.paraglider`, `.harness`, `.reserve`, `.gear`
- Weight ranges with validation: `minWeight`, `maxWeight`, `minRecommendedWeight`, `maxRecommendedWeight`
- Check scheduling based on configurable cycles (in months)
- Equipment can belong to multiple profiles

### UI Patterns
- SwiftUI with `@Observable` for services
- Undo/redo support via `BatchedUndoManager`
- Localization support for German and English
- Environment objects for Core Data context and services

### Testing
- Uses Swift Testing framework (not XCTest)
- Test utilities in `TestUtils.swift`
- Equipment-focused unit tests in `EquipmentTests.swift`
- UI tests with screenshot automation

## Performance Considerations

### Wing Loading Calculations
- Real-time wing loading calculations in `Profile.swift`
- Projected area required for accurate calculations
- Weight range validation and clamping
- Visualized ranges with buffer zones

### Core Data Performance
- Predicates for equipment filtering by profile
- Sorted descriptors for consistent ordering
- Batch operations for migrations
- Background contexts for heavy operations

## Key Files to Understand

- `Paraquip/Model/Equipment.swift`: Core equipment model with validation and check scheduling
- `Paraquip/Model/Profile.swift`: Equipment profiles with weight calculations
- `Paraquip/ParaquipApp.swift`: App initialization and Core Data setup
- `Paraquip/Services/Notification/NotificationService.swift`: Check reminder system
- `Paraquip/View/Utils/BatchedUndoManager.swift`: Undo/redo functionality
- `fastlane/Fastfile`: Build and release automation

## Environment Variables for Testing

- `animationsDisabled=true`: Disables UI animations for testing
- `stateSimulated=true`: Uses in-memory Core Data for testing
- `notificationsSimulated=true`: Uses fake notification plugin for testing