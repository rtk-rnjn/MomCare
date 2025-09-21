//
//  ExampleSharedComponent.swift
//  MomCare
//
//  Created by RITIK RANJAN on 21/09/25.
//  
//  This file demonstrates how to use conditional compilation macros
//  for components shared between different app targets.

import Foundation
import OSLog

// Use platform-appropriate logging
private let logger: Logger = .init(
    subsystem: "\(PlatformCapabilities.loggingSubsystemPrefix).ExampleComponent",
    category: "ExampleSharedComponent"
)

// Import frameworks conditionally
#if canImport(UIKit)
import UIKit
#endif

#if canImport(HealthKit)
import HealthKit
#endif

#if canImport(UserNotifications)
import UserNotifications
#endif

/// Example of a component that works across all MomCare targets
/// with appropriate conditional compilation for platform-specific features
class ExampleSharedComponent {
    
    static let shared = ExampleSharedComponent()
    
    private init() {
        logger.info("ExampleSharedComponent initialized on \(self.platformName)")
    }
    
    // MARK: - Platform Detection
    
    /// Get human-readable platform name
    var platformName: String {
        #if os(iOS)
        return PlatformCapabilities.isExtension ? "iOS Extension" : "iOS App"
        #elseif os(watchOS)
        return "watchOS"
        #elseif os(macOS)
        return "macOS"
        #else
        return "Unknown Platform"
        #endif
    }
    
    // MARK: - UI Operations
    
    /// Show alert - iOS main app only
    func showAlert(title: String, message: String) {
        #if os(iOS) && canImport(UIKit) && !EXTENSION
        guard PlatformCapabilities.supportsUIAlerts else {
            logger.warning("UI alerts not supported on this platform")
            return
        }
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController?.present(alert, animated: true)
            }
        }
        #else
        // For non-UI platforms, log the alert content
        logger.info("Alert: \(title) - \(message)")
        #endif
    }
    
    // MARK: - Health Data Operations
    
    /// Request health permissions if HealthKit is available
    func requestHealthPermissions() async {
        #if canImport(HealthKit) && (os(iOS) || os(watchOS))
        guard PlatformCapabilities.supportsHealthData else {
            logger.info("HealthKit not available on this platform")
            return
        }
        
        await HealthKitHandler.shared.requestAccess()
        logger.info("Health permissions requested")
        #else
        logger.info("HealthKit not available on this platform")
        #endif
    }
    
    // MARK: - Notification Operations
    
    /// Send notification with platform-appropriate content
    func sendNotification(title: String? = nil, body: String? = nil) {
        guard PlatformCapabilities.supportsNotifications else {
            logger.warning("Notifications not supported on this platform")
            return
        }
        
        #if canImport(UserNotifications)
        let content = UNMutableNotificationContent()
        
        // Platform-specific defaults
        #if os(watchOS)
        content.title = title ?? "MomCare+"
        #else
        content.title = title ?? "MomCare"
        #endif
        
        content.body = body ?? "Notification from \(platformName)"
        content.sound = .defaultCritical
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                logger.error("Failed to send notification: \(error.localizedDescription)")
            } else {
                logger.info("Notification sent successfully")
            }
        }
        #endif
    }
    
    // MARK: - Data Operations
    
    /// Save data with platform-appropriate storage
    func saveData<T: Codable>(_ data: T, forKey key: String) {
        do {
            let encoded = try PropertyListEncoder().encode(data)
            
            #if EXTENSION
            // Extensions should use app group container
            if let groupDefaults = UserDefaults(suiteName: "group.MomCare") {
                groupDefaults.set(encoded, forKey: key)
                logger.info("Data saved to app group for key: \(key)")
            } else {
                UserDefaults.standard.set(encoded, forKey: key)
                logger.info("Data saved to standard defaults for key: \(key)")
            }
            #else
            // Main app can use standard UserDefaults
            UserDefaults.standard.set(encoded, forKey: key)
            logger.info("Data saved to standard defaults for key: \(key)")
            #endif
        } catch {
            logger.error("Failed to save data for key \(key): \(error.localizedDescription)")
        }
    }
    
    /// Load data with platform-appropriate storage
    func loadData<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        var data: Data?
        
        #if EXTENSION
        // Extensions should try app group container first
        if let groupDefaults = UserDefaults(suiteName: "group.MomCare") {
            data = groupDefaults.data(forKey: key)
        } else {
            data = UserDefaults.standard.data(forKey: key)
        }
        #else
        // Main app uses standard UserDefaults
        data = UserDefaults.standard.data(forKey: key)
        #endif
        
        guard let data else {
            logger.info("No data found for key: \(key)")
            return nil
        }
        
        do {
            let decoded = try PropertyListDecoder().decode(type, from: data)
            logger.info("Data loaded successfully for key: \(key)")
            return decoded
        } catch {
            logger.error("Failed to decode data for key \(key): \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Debug Information
    
    /// Get debug information about current platform capabilities
    func getCapabilityInfo() -> [String: Any] {
        var info: [String: Any] = [:]
        
        info["platformName"] = platformName
        info["supportsUIAlerts"] = PlatformCapabilities.supportsUIAlerts
        info["supportsHealthData"] = PlatformCapabilities.supportsHealthData
        info["supportsCalendar"] = PlatformCapabilities.supportsCalendar
        info["supportsWatchConnectivity"] = PlatformCapabilities.supportsWatchConnectivity
        info["supportsNotifications"] = PlatformCapabilities.supportsNotifications
        info["supportsWidgets"] = PlatformCapabilities.supportsWidgets
        info["isExtension"] = PlatformCapabilities.isExtension
        info["isDebug"] = PlatformCapabilities.isDebug
        info["isSimulator"] = PlatformCapabilities.isSimulator
        
        logger.info("Platform capabilities: \(info)")
        return info
    }
}

// MARK: - Usage Examples

/*
 // Example usage in any target:
 
 let component = ExampleSharedComponent.shared
 
 // This works on all platforms
 component.sendNotification(title: "Hello", body: "World")
 
 // This only works on iOS main app
 component.showAlert(title: "Alert", message: "This is an alert")
 
 // This works on iOS and watchOS where HealthKit is available
 await component.requestHealthPermissions()
 
 // Data operations work on all platforms with appropriate storage
 component.saveData("test data", forKey: "myKey")
 let loaded: String? = component.loadData(String.self, forKey: "myKey")
 
 // Get platform capability information
 let capabilities = component.getCapabilityInfo()
 print("Running on: \(capabilities)")
 */