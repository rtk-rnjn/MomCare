

import SwiftUI

struct MoodFaceView: View {
    @ObservedObject var vm: MoodNestViewModel

    var body: some View {
        VStack(spacing: -3) {
            HStack(spacing: 30) {
                EyeView(vm: vm, isLeft: true)
                EyeView(vm: vm, isLeft: false)
            }

            SmileView(
                rotation: vm.smileRotation,
                color: vm.faceColor
            )
        }
    }
}
