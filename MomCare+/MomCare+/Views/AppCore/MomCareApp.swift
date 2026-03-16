import SwiftData
import SwiftUI
import TipKit

@main
struct MomCareApp: App {

    // MARK: Lifecycle

    init() {
        do {
            try Tips.configure()
        } catch {
            DebugLogger.shared.log("Failed to configure tips: \(error.localizedDescription)", level: .error, category: .ui)
        }
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
                .environmentObject(appDelegate.debugMenuStore)
                .modelContainer(for: SymptomModel.self)
        }
    }

    // MARK: Private

    @StateObject private var healthStore: ContentServiceHandler = .init()
    @StateObject private var authenticationService: AuthenticationService = .init()
    @StateObject private var musicPlayerHandler: MusicPlayerHandler = .init()
    @StateObject private var eventKitHandler: EventKitHandler = .init()
    @StateObject private var controlState: ControlState = .init()
//    @StateObject private var debugMenuStore: DebugMenuStore = .init()

}
