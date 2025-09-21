//
//  ConditionalCompilation.swift
//  MomCare
//
//  Created by RITIK RANJAN on 21/09/25.
//

import Foundation

// MARK: - Platform Detection Macros

// These are compile-time constants that can be used in #if statements

// MARK: - Framework Availability Helper Functions

public enum PlatformCapabilities {
    
    /// Check if current platform supports UI alerts
    public static var supportsUIAlerts: Bool {
        #if os(iOS) && canImport(UIKit)
        return true
        #else
        return false
        #endif
    }
    
    /// Check if current platform supports health data
    public static var supportsHealthData: Bool {
        #if canImport(HealthKit) && (os(iOS) || os(watchOS))
        return true
        #else
        return false
        #endif
    }
    
    /// Check if current platform supports calendar integration
    public static var supportsCalendar: Bool {
        #if canImport(EventKit) && os(iOS)
        return true
        #else
        return false
        #endif
    }
    
    /// Check if current platform supports watch connectivity
    public static var supportsWatchConnectivity: Bool {
        #if canImport(WatchConnectivity) && (os(iOS) || os(watchOS))
        return true
        #else
        return false
        #endif
    }
    
    /// Check if current platform supports notifications
    public static var supportsNotifications: Bool {
        #if canImport(UserNotifications)
        return true
        #else
        return false
        #endif
    }
    
    /// Check if current platform supports widgets
    public static var supportsWidgets: Bool {
        #if canImport(WidgetKit)
        return true
        #else
        return false
        #endif
    }
    
    /// Check if current platform is an extension
    public static var isExtension: Bool {
        #if EXTENSION
        return true
        #else
        return false
        #endif
    }
    
    /// Check if running in debug mode
    public static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    /// Check if running on simulator
    public static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    /// Get platform-specific logging subsystem prefix
    public static var loggingSubsystemPrefix: String {
        #if os(watchOS)
        return "com.MomCare.WatchApp"
        #elseif EXTENSION && os(iOS)
        return "com.MomCare.Widget"
        #elseif INTENTS_EXTENSION
        return "com.MomCare.Intents"
        #else
        return "com.MomCare"
        #endif
    }
}

// MARK: - Commonly Used Conditional Compilation Patterns

/// iOS main app conditional compilation macro
/// Usage: #if IOS_MAIN_APP
public let IOS_MAIN_APP_FLAG = 1
#if os(iOS) && !EXTENSION
// Code for iOS main app
#endif

/// watchOS app conditional compilation macro  
/// Usage: #if WATCHOS_APP
public let WATCHOS_APP_FLAG = 1
#if os(watchOS)
// Code for watchOS app
#endif

/// Widget extension conditional compilation macro
/// Usage: #if WIDGET_EXTENSION
public let WIDGET_EXTENSION_FLAG = 1
#if EXTENSION && os(iOS)
// Code for widget extension
#endif

/// iOS with UIKit conditional compilation macro
/// Usage: #if IOS_UIKIT
public let IOS_UIKIT_FLAG = 1
#if os(iOS) && canImport(UIKit)
// Code for iOS with UIKit
#endif

/// HealthKit available conditional compilation macro
/// Usage: #if HAS_HEALTHKIT
public let HAS_HEALTHKIT_FLAG = 1
#if canImport(HealthKit)
// Code that uses HealthKit
#endif

/// EventKit available conditional compilation macro
/// Usage: #if HAS_EVENTKIT
public let HAS_EVENTKIT_FLAG = 1
#if canImport(EventKit)
// Code that uses EventKit
#endif

/// EventKitUI available conditional compilation macro
/// Usage: #if HAS_EVENTKIT_UI
public let HAS_EVENTKIT_UI_FLAG = 1
#if canImport(EventKitUI)
// Code that uses EventKitUI
#endif

/// WatchConnectivity available conditional compilation macro
/// Usage: #if HAS_WATCH_CONNECTIVITY
public let HAS_WATCH_CONNECTIVITY_FLAG = 1
#if canImport(WatchConnectivity)
// Code that uses WatchConnectivity
#endif

/// CoreImage available conditional compilation macro
/// Usage: #if HAS_COREIMAGE
public let HAS_COREIMAGE_FLAG = 1
#if canImport(CoreImage)
// Code that uses CoreImage
#endif