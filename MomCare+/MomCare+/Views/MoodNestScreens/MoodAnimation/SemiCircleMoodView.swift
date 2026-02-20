

import SwiftUI

struct SemiCircleMoodView: View {
    let moodValue: Double

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0.5, to: 1)
                .stroke(.black.opacity(0.15), lineWidth: 20)
                .rotationEffect(.degrees(180))

            Circle()
                .trim(from: 0.5, to: 0.5 + (moodValue / 10))
                .stroke(
                    Color.black,
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .rotationEffect(.degrees(180))
                .animation(.easeInOut(duration: 0.4), value: moodValue)
        }
        .padding(40)
    }
}
