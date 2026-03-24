import SwiftData
import SwiftUI
import TipKit

@main
struct MomCareApp: App {
    // MARK: Lifecycle

    init() {
        do {
            try Tips.configure(
                [
                    .displayFrequency(.immediate),
                    .datastoreLocation(.applicationDefault),
                ]
            )
            #if DEBUG
            try Tips.resetDatastore()
            #endif // DEBUG
        } catch {}
    }

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
                .modelContainer(for: SymptomModel.self)
        }
    }

    // MARK: Private

    @StateObject private var healthStore: ContentServiceHandler = .init()
    @StateObject private var authenticationService: AuthenticationService = .init()
    @StateObject private var musicPlayerHandler: MusicPlayerHandler = .init()
    @StateObject private var eventKitHandler: EventKitHandler = .init()
    @StateObject private var controlState: ControlState = .init()
}
