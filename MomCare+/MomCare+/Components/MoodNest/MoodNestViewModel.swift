import Combine
import SwiftUI

final class MoodNestViewModel: ObservableObject {
    // MARK: Internal

    @Published var backgroundColor: Color = MoodColors.happyBackgroundSwiftUI
    @Published var faceColor: Color = MoodColors.happyFaceSwiftUI

    @Published var eyeScale: CGSize = .init(width: 1, height: 1)
    @Published var eyeRotationLeft: Angle = .zero
    @Published var eyeRotationRight: Angle = .zero
    @Published var smileRotation: Angle = .zero
    @Published var useSemiCircleEyes: Bool = false

    func applyMood(_ mood: MoodType) {
        reset()

        switch mood {
        case .happy:
            backgroundColor = MoodColors.happyBackgroundSwiftUI
            faceColor = MoodColors.happyFaceSwiftUI

        case .sad:
            backgroundColor = MoodColors.sadBackgroundSwiftUI
            faceColor = MoodColors.sadFaceSwiftUI
            eyeScale = .init(width: 0.8, height: 0.8)
            smileRotation = .degrees(180)

        case .stressed:
            backgroundColor = MoodColors.stressedBackgroundSwiftUI
            faceColor = MoodColors.stressedFaceSwiftUI
            eyeScale = .init(width: 0.8, height: 0.2)
            smileRotation = .degrees(180)

        case .angry:
            backgroundColor = MoodColors.angryBackgroundSwiftUI
            faceColor = MoodColors.angryFaceSwiftUI
            eyeScale = .init(width: 0.8, height: 0.8)
            smileRotation = .degrees(180)
            eyeRotationLeft = .degrees(30)
            eyeRotationRight = .degrees(-30)
            useSemiCircleEyes = true
        }
    }

    // MARK: Private

    private func reset() {
        eyeScale = .init(width: 1, height: 1)
        eyeRotationLeft = .zero
        eyeRotationRight = .zero
        smileRotation = .zero
        useSemiCircleEyes = false
    }
}
