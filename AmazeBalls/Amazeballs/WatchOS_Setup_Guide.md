# Complete Guide: Adding watchOS App Target to Amazeballs

## Step 1: Adding the watchOS App Target in Xcode

### Manual Steps in Xcode:

1. **Open your Amazeballs project in Xcode**

2. **Add the watchOS App target:**
   - Select your project in the navigator (top-level "Amazeballs" item)
   - Click the "+" button at the bottom of the targets list
   - Choose **watchOS** → **App**
   - Configure the target:
     - **Product Name:** `Amazeballs Watch App`
     - **Bundle Identifier:** `com.yourcompany.Amazeballs.watchkitapp` (adjust your company identifier)
     - **Language:** Swift
     - **Use SwiftUI:** Yes (checked)
     - **Minimum Deployment:** watchOS 11.0

3. **Clean up the generated files:**
   - Delete the default generated `ContentView.swift` in the watch target (we'll create our own)
   - Keep the generated app file but we'll replace its contents

## Step 2: Configuring Shared Framework Access

### Add Shared Files to Watch Target:

1. **Select the following files in your main app target:**
   - `GameSettings.swift`
   - `BallAssetManager.swift` 
   - `BallAssetManager+GameSettings.swift` (if it exists)

2. **For each file:**
   - Select the file in Project Navigator
   - In the File Inspector (right panel), under "Target Membership"
   - **Check the box** for your new "Amazeballs Watch App" target
   - Ensure the main iOS target remains checked as well

## Step 3: Setting up iCloud Capability for Watch Target

### Add CloudKit capability:

1. **Select your watchOS app target** in the project settings
2. **Go to "Signing & Capabilities" tab**
3. **Click "+ Capability"**
4. **Add "iCloud"**
5. **Check "CloudKit"**
6. **Set the same container as your main app** (usually automatically matched)
   - This ensures settings sync between iPhone and Apple Watch

## Step 4: Creating the Folder Structure

### In Xcode Project Navigator:

1. **Right-click on your project** and select "New Group"
2. **Name it:** `Watch App`
3. **Create subgroups within "Watch App":**
   - `Views` (for watch-specific SwiftUI views)
   - `Models` (for watch-specific data models if needed)
   - `Resources` (for watch-specific assets)

### File Organization:
```
Amazeballs/
├── Shared/
│   ├── GameSettings.swift (shared with watch)
│   ├── BallAssetManager.swift (shared with watch)
│   └── BallAssetManager+GameSettings.swift (if exists)
├── iOS App/
│   ├── AmazeballsApp.swift
│   ├── ContentView.swift
│   └── ... (other iOS files)
└── Watch App/
    ├── WatchApp.swift (main app file)
    ├── Views/
    │   ├── WatchContentView.swift
    │   └── WatchQuickSettingsView.swift
    └── Resources/
        └── Assets.xcassets (if needed)
```

## Step 5: Replace the Generated Watch App File

**Replace the generated app file contents** with the WatchApp.swift I created above. The generated file is typically named something like `Amazeballs_Watch_AppApp.swift` - rename it to `WatchApp.swift` and replace its contents.

## Step 6: Add the Watch-Specific Views

**Add the three files I created:**
1. `WatchApp.swift` - Main app entry point
2. `WatchContentView.swift` - Main watch interface
3. `WatchQuickSettingsView.swift` - Settings overlay

**To add these files to your project:**
1. Right-click the "Watch App/Views" group
2. Choose "Add Files to 'Amazeballs'"
3. Create new Swift files with the provided code

## Step 7: Configure Watch Target Settings

### Build Settings:
1. **Select the watchOS target**
2. **Set minimum deployment target:** watchOS 11.0
3. **Verify Swift version:** Swift 6 (or latest)

### Info.plist Configuration:
The watch target's Info.plist should include:
```xml
<key>WKWatchOnly</key>
<true/>
<key>CFBundleDisplayName</key>
<string>Amazeballs</string>
```

## Step 8: Testing the Watch App

### In Xcode:
1. **Select the watch app target** from the scheme selector
2. **Choose a paired Apple Watch simulator**
3. **Build and run** the project

### On Device:
1. **Install the iOS app** on your iPhone first
2. **The watch app will automatically appear** on your paired Apple Watch
3. **Test the Digital Crown interaction** and double-tap gestures

## Step 9: Verify CloudKit Sync

### Test Settings Sync:
1. **Change a setting on iPhone** (like gravity or bounciness)
2. **Open the watch app** - settings should sync
3. **Change a setting on watch** using Digital Crown
4. **Check iPhone app** - changes should appear there too

### Debug CloudKit:
- Check the debug console for CloudKit sync messages
- Ensure both devices are signed into the same iCloud account
- Settings sync may take a few seconds

## Step 10: Asset Management (Optional)

### If you want watch-specific ball assets:
1. **Add a separate Assets.xcassets** to the watch target
2. **Include smaller/simplified ball images** optimized for watch screen
3. **Update BallAssetManager** to detect watch platform if needed

## Expected User Experience

### On Apple Watch:
- **Single tap anywhere:** Drop a ball
- **Rotate Digital Crown:** Adjust gravity (0.0-2.0) or bounciness (0.0-1.0)
- **Double-tap anywhere:** Toggle walls on/off
- **Long press:** Show quick settings overlay
- **Settings automatically sync** with paired iPhone

### Controls Summary:
- **Crown Control Toggle:** In quick settings, choose whether Digital Crown controls gravity or bounciness
- **Visual Indicators:** Small indicators show current crown control and walls status
- **Status Bar:** Shows current gravity and bounciness values

## Troubleshooting

### Common Issues:

1. **"GameSettings not found"**
   - Ensure GameSettings.swift is checked for watch target membership
   - Clean build folder (Cmd+Shift+K) and rebuild

2. **CloudKit not syncing**
   - Check iCloud capability is enabled for both targets
   - Verify same CloudKit container is used
   - Check device is signed into iCloud

3. **Digital Crown not working**
   - Ensure `.focusable(true)` is set on the main view
   - Check `.digitalCrownRotation()` modifier parameters

4. **App not appearing on watch**
   - Install iOS app first
   - Check watch target deployment target (watchOS 11.0+)
   - Restart watch if needed

### Build Settings Check:
- **Product Bundle Identifier:** Should end with `.watchkitapp`
- **Skip Install:** Should be NO
- **Wrapper Extension:** Should be `app`

## Summary

The watchOS app provides a simplified but complete physics experience:
- **Essential controls** optimized for watch interaction
- **Shared settings model** with automatic CloudKit sync
- **Digital Crown integration** for precise value control
- **Gesture-based interaction** for quick actions
- **Minimal but informative UI** perfect for glanceable interaction

The implementation leverages SwiftUI's built-in watch capabilities while maintaining consistency with your existing iOS app through shared models and CloudKit synchronization.