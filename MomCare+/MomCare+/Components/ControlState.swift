import Combine
import SwiftUI

enum AppTab: Int, CaseIterable {
    case onboarding
    case progress
    case myPlan
    case triTrack
    case mood
    case settings

    // MARK: Internal

    var title: String {
        switch self {
        case .onboarding: "MomCare+"
        case .progress: "Progress"
        case .myPlan: "My Plan"
        case .triTrack: "TriTrack"
        case .mood: "Mood"
        case .settings: "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .onboarding: ""
        case .progress: "trophy.fill"
        case .myPlan: "list.bullet.clipboard.fill"
        case .triTrack: "calendar"
        case .mood: "face.dashed.fill"
        case .settings: "gearshape.fill"
        }
    }
}

enum ProfileRowType: Int {
    case personalInformation
    case healthInformation
    case notifications
    case security
    case legal
    case aboutApplication
    case watch
    case accountManagement
    case signOut
    case footerText
    case whatsNew
}

enum MyPlanSegment: String, CaseIterable, Identifiable {
    case diet = "Diet"
    case exercise = "Exercise"

    // MARK: Internal

    var id: String {
        rawValue
    }
}

enum TriTrackSegment: String, CaseIterable, Identifiable {
    case meAndBaby
    case events
    case symptoms

    // MARK: Internal

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .meAndBaby: "Me & Baby"
        case .events: "Events"
        case .symptoms: "Symptoms"
        }
    }
}

enum ControlStateKey: String, CaseIterable {
    case isOnboardingCompleted
    case isLoggedIn
    case selectedTab
    case myPlanSegment
    case triTrackSegment
    case showingPopup
    case showingPopupBar

    // MARK: Internal

    var userDefaultsKey: String {
        "MomCare_ControlState_" + rawValue
    }
}

@MainActor
final class ControlState: ObservableObject {
    // MARK: Lifecycle

    init() {
        isOnboardingCompleted = Database.shared.userDefaults.bool(forKey: ControlStateKey.isOnboardingCompleted.userDefaultsKey)
        isLoggedIn = Database.shared.userDefaults.bool(forKey: ControlStateKey.isLoggedIn.userDefaultsKey)

        if let savedTab = Database.shared.userDefaults.object(forKey: ControlStateKey.selectedTab.userDefaultsKey) as? Int,
           let tab = AppTab(rawValue: savedTab) {
            selectedTab = tab
        }

        if let savedSegment = Database.shared.userDefaults.string(forKey: ControlStateKey.myPlanSegment.userDefaultsKey),
           let segment = MyPlanSegment(rawValue: savedSegment) {
            myPlanSegment = segment
        }

        if let savedTriSegment = Database.shared.userDefaults.string(forKey: ControlStateKey.triTrackSegment.userDefaultsKey),
           let segment = TriTrackSegment(rawValue: savedTriSegment) {
            triTrackSegment = segment
        }

        if let savedShowingPopup = Database.shared.userDefaults.object(forKey: ControlStateKey.showingPopup.userDefaultsKey) as? Bool {
            showingPopup = savedShowingPopup
        }

        if let savedShowingPopupBar = Database.shared.userDefaults.object(forKey: ControlStateKey.showingPopupBar.userDefaultsKey) as? Bool {
            showingPopupBar = savedShowingPopupBar
        }
    }

    // MARK: Internal

    @Published var showingExpandedCalendar: Bool = false
    @Published var showingAddEventSheet: Bool = false
    @Published var showingAddSymptomSheet: Bool = false

    @Published var showingMoodnestPlaylistsView: Bool = false

    @Published var error: (any Error)?
    @Published var showingTriTrackHelp: Bool = false

    @Published var showingPopup: Bool = false {
        didSet { Database.shared.userDefaults.set(showingPopup, forKey: ControlStateKey.showingPopup.userDefaultsKey) }
    }

    @Published var showingPopupBar: Bool = false {
        didSet { Database.shared.userDefaults.set(showingPopupBar, forKey: ControlStateKey.showingPopupBar.userDefaultsKey) }
    }

    @Published var isOnboardingCompleted: Bool = false {
        didSet { Database.shared.userDefaults.set(isOnboardingCompleted, forKey: ControlStateKey.isOnboardingCompleted.userDefaultsKey) }
    }

    @Published var isLoggedIn: Bool = false {
        didSet { Database.shared.userDefaults.set(isLoggedIn, forKey: ControlStateKey.isLoggedIn.userDefaultsKey) }
    }

    @Published var selectedTab: AppTab = .progress {
        didSet { Database.shared.userDefaults.set(selectedTab.rawValue, forKey: ControlStateKey.selectedTab.userDefaultsKey) }
    }

    @Published var myPlanSegment: MyPlanSegment = .diet {
        didSet { Database.shared.userDefaults.set(myPlanSegment.rawValue, forKey: ControlStateKey.myPlanSegment.userDefaultsKey) }
    }

    @Published var triTrackSegment: TriTrackSegment = .meAndBaby {
        didSet { Database.shared.userDefaults.set(triTrackSegment.rawValue, forKey: ControlStateKey.triTrackSegment.userDefaultsKey) }
    }

    static func purge() {
        ControlStateKey.allCases.forEach { Database.shared.userDefaults.removeObject(forKey: $0.userDefaultsKey) }
    }
}
