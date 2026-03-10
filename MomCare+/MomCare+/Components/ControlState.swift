//
//  ControlState.swift
//  MomCare
//
//  Created by Aryan singh on 17/02/26.
//

import Combine
import SwiftUI

enum AppTab: Int, CaseIterable {
    case onboarding
    case progressHub
    case myPlan
    case triTrack
    case moodNest

    // MARK: Internal

    var title: String {
        switch self {
        case .onboarding: "MomCare+"
        case .progressHub: "Progress"
        case .myPlan: "My Plan"
        case .triTrack: "TriTrack"
        case .moodNest: "Mood"
        }
    }

    var systemImage: String {
        switch self {
        case .onboarding: ""
        case .progressHub: "trophy.fill"
        case .myPlan: "list.bullet.clipboard.fill"
        case .triTrack: "calendar"
        case .moodNest: "face.dashed.fill"
        }
    }
}

enum ProfileRowType: Int {
    case personalInfo
    case healthInfo
    case notifications
    case security
    case legal
    case aboutApp
    case watch
    case accountManagement
    case signOut
    case footerText
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

@MainActor
final class ControlState: ObservableObject {

    // MARK: Lifecycle

    // MARK: - Init

    init() {

        isOnboardingCompleted = UserDefaults.standard.bool(forKey: "isOnboardingCompleted")
        isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")

        if let savedTab = UserDefaults.standard.object(forKey: "selectedTab") as? Int,
           let tab = AppTab(rawValue: savedTab) {
            selectedTab = tab
        }

        if let savedSegment = UserDefaults.standard.string(forKey: "myPlanSegment"),
           let segment = MyPlanSegment(rawValue: savedSegment) {
            myPlanSegment = segment
        }

        if let savedTriSegment = UserDefaults.standard.string(forKey: "triTrackSegment"),
           let segment = TriTrackSegment(rawValue: savedTriSegment) {
            triTrackSegment = segment
        }

        if let savedShowingPopup = UserDefaults.standard.object(forKey: "showingPopup") as? Bool {
            showingPopup = savedShowingPopup
        }

        if let savedShowingPopupBar = UserDefaults.standard.object(forKey: "showingPopupBar") as? Bool {
            showingPopupBar = savedShowingPopupBar
        }
    }

    // MARK: Internal

    @Published var showingOnboarding: Bool = false
    @Published var showingSignIn: Bool = false
    @Published var showingSignUp: Bool = false

    @Published var showingProfileSheet: Bool = false

    @Published var showingSearchFoodItemSheet: Bool = false
    @Published var showingAddFoodItemAlert: Bool = false
    @Published var showingBreathingSheet: Bool = false
    @Published var showingExerciseSheet: Bool = false

    @Published var showingExpandedCalendar: Bool = false
    @Published var showingAddEventSheet: Bool = false
    @Published var showingAddSymptomSheet: Bool = false

    @Published var showingMoodnestPlaylistsView: Bool = false

    @Published var showingPopup: Bool = false {
        didSet { UserDefaults.standard.set(showingPopup, forKey: "showingPopup") }
    }

    @Published var showingPopupBar: Bool = false {
        didSet { UserDefaults.standard.set(showingPopupBar, forKey: "showingPopupBar") }
    }

    @Published var isOnboardingCompleted: Bool = false {
        didSet { UserDefaults.standard.set(isOnboardingCompleted, forKey: "isOnboardingCompleted") }
    }

    @Published var isLoggedIn: Bool = false {
        didSet { UserDefaults.standard.set(isLoggedIn, forKey: "isLoggedIn") }
    }

    @Published var selectedTab: AppTab = .progressHub {
        didSet { UserDefaults.standard.set(selectedTab.rawValue, forKey: "selectedTab") }
    }

    @Published var myPlanSegment: MyPlanSegment = .diet {
        didSet { UserDefaults.standard.set(myPlanSegment.rawValue, forKey: "myPlanSegment") }
    }

    @Published var triTrackSegment: TriTrackSegment = .meAndBaby {
        didSet { UserDefaults.standard.set(triTrackSegment.rawValue, forKey: "triTrackSegment") }
    }

}
