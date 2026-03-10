import SwiftUI

struct MoodFaceView: View {
    @ObservedObject var moodNestViewModel: MoodNestViewModel

    var body: some View {
        VStack(spacing: -3) {
            HStack(spacing: 30) {
                EyeView(moodNestViewModel: moodNestViewModel, isLeft: true)
                EyeView(moodNestViewModel: moodNestViewModel, isLeft: false)
            }

            SmileView(
                rotation: moodNestViewModel.smileRotation,
                color: moodNestViewModel.faceColor
            )
        }
    }
}
