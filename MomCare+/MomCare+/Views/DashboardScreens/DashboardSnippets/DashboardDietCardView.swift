

import SwiftUI

struct DashboardDietCardView: View {

    // MARK: Internal

    let consumed: Double
    let goal: Double

    var body: some View {
        HStack {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(MomCareAccent.primary)
                        .frame(width: 35, height: 35)

                    Image(systemName: "fork.knife")
                        .foregroundColor(.white)
                }

                Text("\(Int(consumed)) / \(Int(goal)) kcal")
                    .font(.title3)
                    .fontWeight(.regular)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: goal)
            }

            Spacer()

            VStack(spacing: 6) {
                Text("\(Int(animatedProgress * 100))%")
                    .font(.headline)
                    .fontWeight(.semibold)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)

                        Capsule()
                            .fill(MomCareAccent.primary)
                            .frame(
                                width: geo.size.width * max(animatedProgress, 0),
                                height: 8
                            )
                            .animation(.easeInOut(duration: 0.9), value: abs(animatedProgress))
                    }
                }
                .frame(width: 120, height: 8)
            }
        }
        .padding(16)
        .background(Color("secondaryAppColor"))
        .dashboardCardStyle()
        .onAppear {
            guard !hasAnimated else { return }
            hasAnimated = true

            animatedProgress = 0

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.9)) {
                    animatedProgress = progress
                }
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.easeInOut(duration: 0.9)) {
                animatedProgress = newValue
            }
        }
    }

    // MARK: Private

    @State private var animatedProgress: Double = 0
    @State private var hasAnimated = false

    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(consumed / goal, 1)
    }

    private func animate() {
        withAnimation(.easeInOut(duration: 0.8)) {
            animatedProgress = progress
        }
    }
}
