import SwiftUI

struct MoodFaceView: View {
    let isSemiCircleEyes: Bool
    let faceColor: Color
    let eyeScale: CGSize

    let leftEyeRotation: Angle
    let rightEyeRotation: Angle

    let smileRotation: Angle

    var body: some View {
        VStack(spacing: -3) {
            HStack(spacing: 30) {
                EyeView(
                    isSemiCircleEyes: isSemiCircleEyes,
                    faceColor: faceColor,
                    eyeScale: eyeScale,
                    rotation: leftEyeRotation
                )
                EyeView(
                    isSemiCircleEyes: isSemiCircleEyes,
                    faceColor: faceColor,
                    eyeScale: eyeScale,
                    rotation: rightEyeRotation
                )
            }

            SmileView(
                rotation: smileRotation,
                color: faceColor
            )
        }
        .accessibilityHidden(true)
    }
}
