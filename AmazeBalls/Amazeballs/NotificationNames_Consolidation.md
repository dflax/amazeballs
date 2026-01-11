# Notification Names Consolidation

## Problem
The notification names were defined in multiple files, causing "Invalid redeclaration" errors:

1. `ContentView+macOS.swift` - defined 5 notifications
2. `MacOSCommands.swift` - defined the same 5 notifications (duplicate)
3. `SpriteKitSceneView.swift` - defined 1 notification (`clearAllBalls`) (duplicate)

This caused compiler errors because you cannot define the same extension property multiple times in the same target.

## Solution
Created a centralized `NotificationNames.swift` file that:

1. **Single source of truth** - All notification names are defined in one place
2. **Namespaced identifiers** - Uses `amazeballs.*` prefix to avoid conflicts with other frameworks
3. **Well-documented** - Clear comments explaining each notification's purpose
4. **Accessible everywhere** - Imported via Foundation, available throughout the app

## Changes Made

### Created
- `NotificationNames.swift` - Centralized notification name definitions

### Modified
- `MacOSCommands.swift` - Removed duplicate notification name definitions
- `ContentView+macOS.swift` - Removed duplicate notification name definitions  
- `SpriteKitSceneView.swift` - Removed duplicate notification name definitions

## Benefits

1. **No more conflicts** - Single definition prevents redeclaration errors
2. **Easier maintenance** - Update notification names in one place
3. **Better namespacing** - Prefixed with `amazeballs.` to avoid collisions
4. **Platform-agnostic** - Works across iOS, iPadOS, and macOS
5. **Clear documentation** - Each notification is documented with its purpose

## Usage

All files can now use the notification names without defining them:

```swift
// Posting a notification
NotificationCenter.default.post(name: .clearAllBalls, object: nil)

// Observing a notification
NotificationCenter.default.addObserver(
    forName: .toggleWalls,
    object: nil,
    queue: .main
) { _ in
    // Handle the notification
}
```

## Note
Make sure `NotificationNames.swift` is included in all targets (main app, tests, etc.) in your Xcode project.
