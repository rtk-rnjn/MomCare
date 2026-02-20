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

enum ProfileRowType {
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
class ControlState: ObservableObject {
    @Published var selectedTab: AppTab = .progressHub
    @Published var showingGlobalAlert: Bool = false

    @Published var showingProfileSheet: Bool = false
    @Published var activeProfileRow: ProfileRowType? = nil

    @Published var myPlanSegment: MyPlanSegment = .diet
    @Published var showingSearchFoodItemSheet: Bool = false
    @Published var showingAddFoodItemAlert: Bool = false
    @Published var showingBreathingSheet: Bool = false
    @Published var showingExerciseSheet: Bool = false

    @Published var triTrackSegment: TriTrackSegment = .meAndBaby
    @Published var showingExpandedCalendar: Bool = false
    @Published var showingAddEventSheet: Bool = false
    @Published var showingAddSymptomSheet: Bool = false

    @Published var showingPopup: Bool = false
    @Published var showingPopupBar: Bool = false
}
