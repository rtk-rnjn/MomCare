import Combine
import SwiftUI

final class MoodNestViewModel: ObservableObject {
    @Published var sliderValue: Double = 0
    @Published var mood: MoodType = .happy

    @Published var backgroundColor: Color = MoodColors.happyBackgroundSwiftUI
    @Published var faceColor: Color = MoodColors.happyFaceSwiftUI

    @Published var eyeScale: CGSize = .init(width: 1, height: 1)
    @Published var eyeRotationLeft: Angle = .zero
    @Published var eyeRotationRight: Angle = .zero
    @Published var smileRotation: Angle = .zero
    @Published var useSemiCircleEyes: Bool = false

    func updateMood() {
        switch sliderValue.rounded() {
        case 0: makeHappy()
        case 1: makeStressed()
        case 2: makeSad()
        case 3: makeAngry()
        default: break
        }
    }
}

private extension MoodNestViewModel {
    func reset() {
        eyeScale = .init(width: 1, height: 1)
        eyeRotationLeft = .zero
        eyeRotationRight = .zero
        smileRotation = .zero
        useSemiCircleEyes = false
    }

    func makeHappy() {
        reset()
        mood = .happy
        backgroundColor = MoodColors.happyBackgroundSwiftUI
        faceColor = MoodColors.happyFaceSwiftUI
    }

    func makeSad() {
        reset()
        mood = .sad
        backgroundColor = MoodColors.sadBackgroundSwiftUI
        faceColor = MoodColors.sadFaceSwiftUI

        eyeScale = .init(width: 0.8, height: 0.8)
        smileRotation = .degrees(180)
    }

    func makeStressed() {
        reset()
        mood = .stressed
        backgroundColor = MoodColors.stressedBackgroundSwiftUI
        faceColor = MoodColors.stressedFaceSwiftUI

        eyeScale = .init(width: 0.8, height: 0.2)
        smileRotation = .degrees(180)
    }

    func makeAngry() {
        reset()
        mood = .angry
        backgroundColor = MoodColors.angryBackgroundSwiftUI
        faceColor = MoodColors.angryFaceSwiftUI

        eyeScale = .init(width: 0.8, height: 0.8)
        smileRotation = .degrees(180)
        eyeRotationLeft = .degrees(30)
        eyeRotationRight = .degrees(-30)
        useSemiCircleEyes = true
    }
}
