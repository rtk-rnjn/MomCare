import SwiftData
import SwiftUI

@main
struct MomCareApp: App {

    // MARK: Internal

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            MomCareRootView()
                .environmentObject(healthStore)
                .environmentObject(authenticationService)
                .environmentObject(musicPlayerHandler)
                .environmentObject(eventKitHandler)
                .environmentObject(controlState)
                .environmentObject(debugMenuStore)
                .modelContainer(for: SymptomModel.self)
        }
    }

    // MARK: Private

    @StateObject private var healthStore: HealthKitHandler = .init()
    @StateObject private var authenticationService: AuthenticationService = .init()
    @StateObject private var musicPlayerHandler: MusicPlayerHandler = .init()
    @StateObject private var eventKitHandler: EventKitHandler = .init()
    @StateObject private var controlState: ControlState = .init()
    @StateObject private var debugMenuStore: DebugMenuStore = .init()

}
