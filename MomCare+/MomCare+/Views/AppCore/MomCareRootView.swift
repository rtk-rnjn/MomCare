import SwiftUI

private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
private let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "MomCare+"
private let expectedVersion = "1.1.0"

struct MomCareRootView: View {
    // MARK: Internal

    var body: some View {
        rootView
            .alert("New Update", isPresented: Binding(get: { doesRequiresUpdate }, set: { _ in })) {
                Button("Update Now") {
                    if let url = URL(string: "https://apps.apple.com/in/app/momcare/id6747114092") {
                        openURL(url)
                    }
                }
                Button("Later", role: .cancel) {}
            } message: {
                Text("A new version of \(appName) is available. Please update to version \(expectedVersion) or later for the best experience.")
            }
    }

    // MARK: Private

    @Environment(\.openURL) private var openURL

    @AppStorage(FeatureFlagState.forceDarkMode.rawValue, store: Database.shared.userDefaults)
    private var forceDarkMode: Bool = false

    @AppStorage(FeatureFlagState.forceLightMode.rawValue, store: Database.shared.userDefaults)
    private var forceLightMode: Bool = true

    @EnvironmentObject private var authenticationService: MCAuthenticationService

    private var isLoggedIn: Bool {
        guard let userModel = authenticationService.userModel else {
            return false
        }

        return userModel.isProfileComplete
    }

    private var colorScheme: ColorScheme? {
        if forceDarkMode {
            return .dark
        }

        if forceLightMode {
            return .light
        }

        return nil
    }

    private var doesRequiresUpdate: Bool {
        compareVersions(appVersion, expectedVersion) == .orderedAscending
    }

    @ViewBuilder
    private var rootView: some View {
        if isLoggedIn {
            MomCareMainTabView()
                .preferredColorScheme(colorScheme)

        } else {
            OnboardingView()
                .preferredColorScheme(colorScheme)
        }
    }

    private func compareVersions(_ version1: String, _ version2: String) -> ComparisonResult {
        let components1 = version1.split(separator: ".").compactMap { Int($0) }
        let components2 = version2.split(separator: ".").compactMap { Int($0) }

        for (comp1, comp2) in zip(components1, components2) {
            if comp1 < comp2 {
                return .orderedAscending
            } else if comp1 > comp2 {
                return .orderedDescending
            }
        }

        if components1.count < components2.count {
            return .orderedAscending
        } else if components1.count > components2.count {
            return .orderedDescending
        }

        return .orderedSame
    }
}
