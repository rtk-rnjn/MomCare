import SwiftUI

struct InvertedArcEye: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: rect.width / 2,
            startAngle: .degrees(200),
            endAngle: .degrees(-20),
            clockwise: false
        )

        return path
    }
}

struct MoodFaceView: View {
    // MARK: Internal

    let mood: MoodType
    let trigger: UUID

    let faceColor: Color
    let isSemiCircleEyes: Bool
    let eyeScale: CGSize
    let leftEyeRotation: Angle
    let rightEyeRotation: Angle
    let smileRotation: Angle

    var body: some View {
        VStack(spacing: -1) {
            ZStack {
                HStack(spacing: 30) {
                    eye(isLeft: true)
                    eye(isLeft: false)
                }

                // sad Tear bohohoooo lol
                if mood == .sad, showTear {
                    Circle()
                        .fill(Color(red: 0.88, green: 0.94, blue: 1.0)) // soft watery color
                        .frame(width: 8, height: 12)
                        .offset(
                            x: 56, //  aligns with right eye
                            y: tearOffsetY + 20 //  animated position
                        )
                        .opacity(tearOpacity)
                }
            }

            ZStack {
                // Default smile
                SmileView(
                    rotation: smileRotation,
                    color: faceColor
                )
                .opacity(isHappyAnimating ? 0 : 1)

                // Open mouth
                OpenMouth()
                    .fill(faceColor)
                    .frame(width: 80, height: 36)
                    .offset(y: -4)
                    .opacity(isHappyAnimating ? 1 : 0)
            }
            .animation(.easeInOut(duration: 0.25), value: isHappyAnimating)
        }

        // Angry compression
        .scaleEffect(mood == .angry && isAngryAnimating ? 0.95 : 1.0)
        // Sad pop
        .scaleEffect(
            mood == .sad && sadPop ? 1.06 :
            mood == .happy && happyPop ? 1.05 :
            mood == .stressed && stressedPop ? 1.04 :
            1.0
        )
        .offset(
            y: mood == .sad && sadPop ? -6 :
               mood == .happy && happyPop ? -4 :
               mood == .stressed && stressedPop ? -3 :
               0
        )
        .animation(.spring(response: 0.25, dampingFraction: 0.5), value: happyPop)
        .animation(.spring(response: 0.25, dampingFraction: 0.5), value: sadPop)
        .animation(.spring(response: 0.25, dampingFraction: 0.5), value: stressedPop)
        .animation(.easeInOut(duration: 0.2), value: isAngryAnimating)
        .onChange(of: trigger) { _, _ in
            triggerAnimation(for: mood)
        }
    }

    // MARK: Private

    @State private var isAngryAnimating = false
    @State private var isAngryEyesActive = false

    @State private var isSadAnimating = false
    @State private var showTear = false
    @State private var sadPop = false

    @State private var tearOffsetY: CGFloat = 0
    @State private var tearOpacity: Double = 1.0

    @State private var isHappyAnimating = false
    @State private var happyPop = false

    @State private var isStressedAnimating = false
    @State private var stressedPop = false
}

private extension MoodFaceView {
    @ViewBuilder
    func eye(isLeft: Bool) -> some View {
        var isAnyAnimating: Bool {
            (mood == .sad && isSadAnimating) ||
            (mood == .happy && isHappyAnimating) ||
            (mood == .stressed && isStressedAnimating)
        }

        ZStack {
            // Base eye (handles angry + normal)
            EyeView(
                isSemiCircleEyes: currentBaseEyeShape(),
                faceColor: faceColor,
                eyeScale: currentEyeScale(),
                rotation: currentEyeRotation(isLeft: isLeft)
            )
            .opacity(isAnyAnimating ? 0 : 1)

            // Sad arc overlay (∩)
            if mood == .sad || mood == .happy {
                InvertedArcEye()
                    .stroke(faceColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 28, height: 16)
                    .opacity(
                        ((mood == .sad && isSadAnimating) ||
                         (mood == .happy && isHappyAnimating)) ? 1 : 0
                    )
                    .offset(y: 8)
            }
            if mood == .stressed {
                StressedEye(isLeft: isLeft)
                    .stroke(
                        faceColor,
                        style: StrokeStyle(lineWidth: 7, lineCap: .round)
                    )
                    .frame(width: 24, height: 24)
                    .opacity(isStressedAnimating ? 1 : 0)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isSadAnimating)
        .animation(.easeInOut(duration: 0.2), value: isStressedAnimating)
    }
}

private extension MoodFaceView {
    func triggerAnimation(for mood: MoodType) {
        if mood == .angry {
            triggerAngry()
        } else if mood == .sad {
            triggerSad()
        } else if mood == .happy {
            triggerHappy()
        } else if mood == .stressed {
            triggerStressed()
        }
    }

    func triggerAngry() {
        isAngryAnimating = false
        isAngryEyesActive = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.easeInOut(duration: 0.18)) {
                isAngryAnimating = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    isAngryEyesActive = true
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                withAnimation(.easeOut(duration: 0.25)) {
                    isAngryAnimating = false
                    isAngryEyesActive = false
                }
            }
        }
    }

    func triggerSad() {
        isSadAnimating = false
        showTear = false
        sadPop = false

        // wait for face transition
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            // eyes morph
            withAnimation(.easeInOut(duration: 0.25)) {
                isSadAnimating = true
            }

            // pop
            withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
                sadPop = true
            }

            // tear appears (delayed so visible)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                tearOffsetY = 0
                tearOpacity = 1.0
                showTear = true

                withAnimation(.easeIn(duration: 0.35)) {
                    tearOffsetY = 45 // fall
                    tearOpacity = 0 // fade out
                }
            }

            // reset
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isSadAnimating = false // 👈 THIS is critical
                    sadPop = false
                }

                // reset non-visual state separately
                showTear = false
                tearOffsetY = 0
                tearOpacity = 1.0
            }
        }
    }

    func triggerHappy() {
        isHappyAnimating = false
        happyPop = false

        // wait for base happy face to appear
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            // transform
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isHappyAnimating = true
                happyPop = true
            }

            // return
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isHappyAnimating = false
                    happyPop = false
                }
            }
        }
    }

    func triggerStressed() {
        isStressedAnimating = false
        stressedPop = false

        // wait for base face transition
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            // activate stressed eyes + pop
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                isStressedAnimating = true
                stressedPop = true
            }

            // return
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isStressedAnimating = false
                    stressedPop = false
                }
            }
        }
    }
}

private extension MoodFaceView {
    func currentEyeScale() -> CGSize {
        if mood == .angry, isAngryEyesActive {
            return CGSize(width: 0.85, height: 0.65)
        }
        return eyeScale
    }

    func currentEyeRotation(isLeft: Bool) -> Angle {
        if mood == .angry {
            return isLeft
                ? .degrees(isAngryEyesActive ? 50 : 30)
                : .degrees(isAngryEyesActive ? -50 : -30)
        }

        return isLeft ? leftEyeRotation : rightEyeRotation
    }

    func currentBaseEyeShape() -> Bool {
        if mood == .angry {
            return true
        }
        return false
    }
}

struct OpenMouth: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: rect.width / 2,
            startAngle: .degrees(0),
            endAngle: .degrees(180),
            clockwise: false
        )

        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()

        return path
    }
}

struct StressedEye: Shape {
    var isLeft: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()

        if isLeft {
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))

        } else {
            path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        }
        return path
    }
}
