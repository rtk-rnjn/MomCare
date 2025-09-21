# Conditional Compilation Guide for MomCare

This guide explains how to use conditional compilation macros for cross-target file sharing in the MomCare project.

## Overview

The MomCare project consists of multiple targets:
- **MomCare** - Main iOS app
- **MomCare+Watch** - watchOS companion app  
- **MomCare+PregnancyTracker** - WidgetKit extension
- **MomCare+Intents** - Intents extension

Many files in the `Common/` directory are shared between these targets, requiring conditional compilation to handle platform-specific code.

## Available Macros

### Platform Detection

Use these standard Swift conditional compilation directives:

```swift
#if os(iOS)
// iOS-specific code
#elseif os(watchOS)
// watchOS-specific code
#elseif os(macOS)
// macOS-specific code (if needed)
#endif
```

### Framework Availability

Check if frameworks are available before using them:

```swift
#if canImport(UIKit)
import UIKit
// UIKit-specific code
#endif

#if canImport(HealthKit)
import HealthKit
// HealthKit-specific code
#endif

#if canImport(EventKit)
import EventKit
// EventKit-specific code
#endif

#if canImport(EventKitUI)
import EventKitUI
// EventKitUI-specific code (iOS only)
#endif

#if canImport(WatchConnectivity)
import WatchConnectivity
// Watch connectivity code
#endif

#if canImport(WidgetKit)
import WidgetKit
// Widget-specific code
#endif
```

### Target Detection

Distinguish between main app and extensions:

```swift
#if EXTENSION
// Extension-specific code (Widget or Intents)
#else
// Main app code
#endif

#if INTENTS_EXTENSION
// Intents extension specific code
#endif
```

### Combined Conditions

Use multiple conditions for more specific targeting:

```swift
#if os(iOS) && canImport(UIKit) && !EXTENSION
// iOS main app with UIKit
#endif

#if canImport(HealthKit) && (os(iOS) || os(watchOS))
// HealthKit code for iOS or watchOS
#endif

#if os(iOS) && canImport(EventKit) && canImport(EventKitUI)
// Calendar integration with UI (iOS main app only)
#endif
```

## Helper Utilities

The `PlatformCapabilities` enum provides runtime capability detection:

```swift
// Runtime capability checks
if PlatformCapabilities.supportsUIAlerts {
    // Show UI alert (iOS main app)
}

if PlatformCapabilities.supportsHealthData {
    // Access HealthKit
}

if PlatformCapabilities.supportsCalendar {
    // Access EventKit
}

if PlatformCapabilities.supportsWatchConnectivity {
    // Use WatchConnectivity
}

if PlatformCapabilities.supportsNotifications {
    // Send notifications
}

if PlatformCapabilities.isExtension {
    // Extension-specific behavior
}

// Get appropriate logging subsystem
let logger = Logger(subsystem: PlatformCapabilities.loggingSubsystemPrefix, category: "YourCategory")
```

## Common Patterns

### Logging

Use platform-appropriate logging subsystems:

```swift
import OSLog

private let logger = Logger(
    subsystem: PlatformCapabilities.loggingSubsystemPrefix,
    category: "YourComponent"
)
```

### Notifications

Platform-appropriate notification titles:

```swift
public static func createNotification(title: String? = nil, body: String? = nil) {
    #if canImport(UserNotifications)
    let content = UNMutableNotificationContent()
    
    #if os(watchOS)
    content.title = title ?? "MomCare+"
    #else  
    content.title = title ?? "MomCare"
    #endif
    
    // Rest of notification code
    #endif
}
```

### UI Code

Separate UI code by platform:

```swift
#if os(iOS) && canImport(UIKit)
func showAlert(title: String, message: String) {
    // UIKit alert implementation
}
#endif

#if os(watchOS) && canImport(SwiftUI)
func showAlert(title: String, message: String) {
    // SwiftUI alert for watchOS
}
#endif
```

### Health Data

Safely access HealthKit:

```swift
#if canImport(HealthKit)
func requestHealthPermissions() {
    #if os(iOS) || os(watchOS)
    guard PlatformCapabilities.supportsHealthData else { return }
    // HealthKit code here
    #endif
}
#endif
```

## File Organization

### Shared Files
Place shared code in `/Common/` directories with proper conditional compilation.

### Platform-Specific Extensions
Use file suffixes to indicate platform-specific extensions:
- `WatchConnector+iOS.swift` - iOS-specific extensions
- `WatchConnector+WatchOS.swift` - watchOS-specific extensions

### Target-Specific Files
Keep target-specific files in their respective directories:
- `/MomCare/` - Main iOS app
- `/MomCare+Watch/` - watchOS app
- `/MomCare+PregnancyTracker/` - Widget extension
- `/MomCare+Intents/` - Intents extension

## Best Practices

1. **Use `canImport` for framework availability** - Always check if a framework is available before importing it.

2. **Combine conditions for specificity** - Use multiple conditions to target specific platform/framework combinations.

3. **Provide graceful fallbacks** - Ensure code works even when optional frameworks aren't available.

4. **Use runtime checks for dynamic behavior** - Use `PlatformCapabilities` for runtime decisions based on platform capabilities.

5. **Keep platform-specific code minimal** - Try to abstract platform differences into shared interfaces when possible.

6. **Document conditional code** - Use comments to explain why conditional compilation is needed.

7. **Test on all targets** - Ensure conditional compilation works correctly across all app targets.

## Examples

### WatchConnector Implementation

```swift
#if canImport(WatchConnectivity)
import WatchConnectivity

class WatchConnector: NSObject {
    // Shared implementation
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        // iOS-specific delegate method
    }
    #endif
}
#endif
```

### Utils with Platform Support

```swift
enum Utils {
    #if os(iOS) && canImport(UIKit)
    static func getAlert(title: String, message: String) -> UIAlertController {
        // iOS alert implementation
    }
    #endif
    
    static func createNotification(title: String? = nil) {
        #if canImport(UserNotifications)
        guard PlatformCapabilities.supportsNotifications else { return }
        // Notification implementation
        #endif
    }
}
```

This conditional compilation approach ensures that shared code works correctly across all MomCare app targets while maintaining platform-specific functionality where needed.