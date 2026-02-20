import SwiftUI

enum BreathingPhase: String {
    case breatheIn = "Breathe In"
    case hold = "Hold"
    case breatheOut = "Breathe Out"
    case ready = "Get Ready"
    case done = "Well Done 🎉"

    // MARK: Internal

    var duration: Double {
        switch self {
        case .breatheIn: 4.0
        case .hold: 4.0
        case .breatheOut: 6.0
        case .ready: 3.0
        case .done: 0
        }
    }

    var next: BreathingPhase {
        switch self {
        case .ready: .breatheIn
        case .breatheIn: .hold
        case .hold: .breatheOut
        case .breatheOut: .breatheIn
        case .done: .done
        }
    }

    var circleScale: CGFloat {
        switch self {
        case .breatheIn: 1.0
        case .hold: 1.0
        case .breatheOut: 0.6
        case .ready: 0.6
        case .done: 0.85
        }
    }
}

struct BreathingExerciseView: View {

    // MARK: Internal

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [pastel, Color(hex: "E8F4F8"), Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                Spacer()

                breathingCircle
                    .padding(.bottom, 20)

                phaseLabel
                    .padding(.bottom, 30)

                sessionProgress
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)

                Spacer()

                bottomControls
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            startReadyCountdown()
            totalElapsed = healthKitHandler.fetchBreathingCompletionDuration(for: Date())
        }
        .onDisappear {
            stopAllTimers()
        }
    }

    // MARK: Private

    @EnvironmentObject private var healthKitHandler: HealthKitHandler
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var phase: BreathingPhase = .ready
    @State private var phaseCountdown: Int = 3
    @State private var totalElapsed: Double = 0
    @State private var circleScale: CGFloat = 0.6
    @State private var isActive = false
    @State private var isPaused = false
    @State private var showCompletion = false

    @State private var dotOffsets: [CGSize] = (0 ..< 6).map { _ in
        CGSize(width: CGFloat.random(in: -20 ... 20), height: CGFloat.random(in: -20 ... 20))
    }

    @State private var timer: Timer?
    @State private var phaseTimer: Timer?

    private let pastel: Color = .init(hex: "D0E1F0")
    private let accent: Color = .init(hex: "8BBBD4")
    private let darkAccent: Color = .init(hex: "4A7A9B")
    private let deepBlue: Color = .init(hex: "3A6A8B")

    private var totalDuration: Double {
        healthKitHandler.breathingTargetInSeconds
    }

    private var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return min(totalElapsed / totalDuration, 1.0)
    }

    private var topBar: some View {
        HStack {
            closeButton

            Spacer()

            VStack(spacing: 2) {
                Text("Breathing")
                    .font(.caption.weight(.medium))
                    .foregroundColor(darkAccent.opacity(0.7))

                Text(formatTime(totalElapsed))
                    .font(.title3.weight(.semibold))
                    .foregroundColor(darkAccent)
                    .monospacedDigit()
            }

            Spacer()

            Color.clear
                .frame(width: 38, height: 38)
        }
    }

    @ViewBuilder
    private var closeButton: some View {
        if #available(iOS 26.0, *) {
            Button {
                stopAllTimers()
                healthKitHandler.updateBreathingCompletionDuration(duration: totalElapsed)
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.subheadline.weight(.semibold))
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .tint(darkAccent)
            .accessibilityLabel("Close breathing exercise")
        } else {
            Button {
                stopAllTimers()
                healthKitHandler.updateBreathingCompletionDuration(duration: totalElapsed)
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(darkAccent)
                    .padding(10)
                    .background(Circle().fill(Color.white.opacity(0.7)))
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            }
            .accessibilityLabel("Close breathing exercise")
        }
    }

    private var breathingCircle: some View {
        ZStack {
            ForEach(0 ..< 3, id: \.self) { i in
                Circle()
                    .fill(accent.opacity(0.06 - Double(i) * 0.015))
                    .frame(width: 260 + CGFloat(i) * 40, height: 260 + CGFloat(i) * 40)
                    .scaleEffect(reduceMotion ? 1.0 : circleScale * (1.0 + CGFloat(i) * 0.05))
            }

            Circle()
                .stroke(accent.opacity(0.15), lineWidth: 4)
                .frame(width: 220, height: 220)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    darkAccent,
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: 220, height: 220)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.5), value: progress)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [accent.opacity(0.4), pastel.opacity(0.8)],
                        center: .center,
                        startRadius: 20,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .scaleEffect(reduceMotion ? 1.0 : circleScale)
                .shadow(color: accent.opacity(0.3), radius: 20, x: 0, y: 5)

            Circle()
                .fill(Color.white.opacity(0.6))
                .frame(width: 120, height: 120)
                .scaleEffect(reduceMotion ? 1.0 : circleScale)

            breathingFace
                .scaleEffect(reduceMotion ? 1.0 : circleScale)

            if !reduceMotion {
                ForEach(0 ..< 6, id: \.self) { i in
                    Circle()
                        .fill(accent.opacity(0.3 + Double(i % 3) * 0.1))
                        .frame(width: CGFloat(6 + (i % 3) * 3), height: CGFloat(6 + (i % 3) * 3))
                        .offset(dotPosition(for: i))
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Breathing animation, \(phase.rawValue)")
        .accessibilityValue("\(Int(progress * 100))% of session complete")
    }

    private var breathingFace: some View {
        VStack(spacing: 6) {
            HStack(spacing: 24) {
                ellipticalEye

                ellipticalEye
            }

            HStack(spacing: 30) {
                Circle()
                    .fill(Color(hex: "F0D5C8").opacity(0.6))
                    .frame(width: 10, height: 10)

                mouthShape

                Circle()
                    .fill(Color(hex: "F0D5C8").opacity(0.6))
                    .frame(width: 10, height: 10)
            }
        }
    }

    private var ellipticalEye: some View {
        Ellipse()
            .fill(darkAccent)
            .frame(width: phase == .hold ? 8 : 7, height: phase == .hold ? 5 : 8)
            .animation(.easeInOut(duration: 0.3), value: phase)
    }

    @ViewBuilder
    private var mouthShape: some View {
        switch phase {
        case .breatheIn:
            Circle()
                .stroke(darkAccent, lineWidth: 2)
                .frame(width: 12, height: 12)
                .animation(.easeInOut(duration: 0.3), value: phase)

        case .hold:
            RoundedRectangle(cornerRadius: 1)
                .fill(darkAccent)
                .frame(width: 14, height: 2)
                .animation(.easeInOut(duration: 0.3), value: phase)

        case .breatheOut:
            Ellipse()
                .stroke(darkAccent, lineWidth: 2)
                .frame(width: 10, height: 7)
                .animation(.easeInOut(duration: 0.3), value: phase)

        case .ready:
            halfCircleSmile
        case .done:
            halfCircleSmile
        }
    }

    private var halfCircleSmile: some View {
        Circle()
            .trim(from: 0.1, to: 0.4)
            .stroke(darkAccent, style: StrokeStyle(lineWidth: 2, lineCap: .round))
            .frame(width: 16, height: 16)
            .animation(.easeInOut(duration: 0.3), value: phase)
    }

    private var phaseLabel: some View {
        VStack(spacing: 8) {
            Text(phase.rawValue)
                .font(.title.weight(.semibold))
                .foregroundColor(darkAccent)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: phase)

            if phase != .done {
                if #available(iOS 16.0, *) {
                    Text("\(phaseCountdown)")
                        .font(.system(size: 44, weight: .light, design: .rounded))
                        .foregroundColor(darkAccent.opacity(0.6))
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.2), value: phaseCountdown)
                } else {
                    Text("\(phaseCountdown)")
                        .font(.system(size: 44, weight: .light, design: .rounded))
                        .foregroundColor(darkAccent.opacity(0.6))
                        .monospacedDigit()
                        .animation(.easeInOut(duration: 0.2), value: phaseCountdown)
                }
            } else {
                Text("Session Complete")
                    .font(.subheadline)
                    .foregroundColor(darkAccent.opacity(0.6))
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(phase.rawValue)\(phase != .done ? ", \(phaseCountdown) seconds remaining" : "")")
    }

    private var sessionProgress: some View {
        VStack(spacing: 8) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(accent.opacity(0.15))

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [accent, darkAccent],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress)
                        .animation(.linear(duration: 0.5), value: progress)
                }
            }
            .frame(height: 6)

            HStack {
                Text(formatTime(totalElapsed))
                    .font(.caption2.weight(.medium))
                    .foregroundColor(darkAccent.opacity(0.5))

                Spacer()

                Text(formatTime(totalDuration))
                    .font(.caption2.weight(.medium))
                    .foregroundColor(darkAccent.opacity(0.5))
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Session progress")
        .accessibilityValue("\(formatTime(totalElapsed)) of \(formatTime(totalDuration))")
    }

    @ViewBuilder
    private var bottomControls: some View {
        if #available(iOS 26.0, *) {
            glassControls
        } else {
            fallbackControls
        }
    }

    @available(iOS 26.0, *)
    private var glassControls: some View {
        HStack(spacing: 30) {
            Button {
                resetSession()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title3.weight(.medium))
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .tint(darkAccent)
            .accessibilityLabel("Restart session")

            Button {
                if phase == .done {
                    resetSession()
                } else if isPaused {
                    resumeSession()
                } else {
                    pauseSession()
                }
            } label: {
                Image(systemName: phase == .done ? "arrow.counterclockwise" : (isPaused ? "play.fill" : "pause.fill"))
                    .font(.title2.weight(.semibold))
            }
            .buttonStyle(.glassProminent)
            .buttonBorderShape(.circle)
            .tint(darkAccent)
            .controlSize(.large)
            .accessibilityLabel(phase == .done ? "Restart session" : (isPaused ? "Resume" : "Pause"))

            Button {
                skipPhase()
            } label: {
                Image(systemName: "forward.fill")
                    .font(.title3.weight(.medium))
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .tint(darkAccent)
            .accessibilityLabel("Skip to next phase")
        }
    }

    private var fallbackControls: some View {
        HStack(spacing: 30) {
            Button {
                resetSession()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title3.weight(.medium))
                    .foregroundColor(darkAccent)
                    .frame(width: 50, height: 50)
                    .background(Circle().fill(Color.white.opacity(0.7)))
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            }
            .accessibilityLabel("Restart session")

            Button {
                if phase == .done {
                    resetSession()
                } else if isPaused {
                    resumeSession()
                } else {
                    pauseSession()
                }
            } label: {
                Image(systemName: phase == .done ? "arrow.counterclockwise" : (isPaused ? "play.fill" : "pause.fill"))
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(width: 70, height: 70)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [accent, darkAccent],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .shadow(color: darkAccent.opacity(0.25), radius: 10, x: 0, y: 4)
            }
            .accessibilityLabel(phase == .done ? "Restart session" : (isPaused ? "Resume" : "Pause"))

            Button {
                skipPhase()
            } label: {
                Image(systemName: "forward.fill")
                    .font(.title3.weight(.medium))
                    .foregroundColor(darkAccent)
                    .frame(width: 50, height: 50)
                    .background(Circle().fill(Color.white.opacity(0.7)))
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            }
            .accessibilityLabel("Skip to next phase")
        }
    }

    private func dotPosition(for index: Int) -> CGSize {
        let baseAngle = Double(index) * 60.0
        let radius: CGFloat = 120 + CGFloat(index % 2) * 20
        let scale = circleScale
        let x = cos(baseAngle * .pi / 180) * radius * scale + dotOffsets[index].width
        let y = sin(baseAngle * .pi / 180) * radius * scale + dotOffsets[index].height
        return CGSize(width: x, height: y)
    }

    private func startReadyCountdown() {
        phase = .ready
        phaseCountdown = Int(BreathingPhase.ready.duration)

        phaseTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            DispatchQueue.main.async {
                if phaseCountdown > 1 {
                    withAnimation { phaseCountdown -= 1 }
                } else {
                    phaseTimer?.invalidate()
                    startBreathingCycle()
                }
            }
        }
    }

    private func startBreathingCycle() {
        isActive = true
        phase = .breatheIn
        phaseCountdown = Int(BreathingPhase.breatheIn.duration)
        animateCircle(to: BreathingPhase.breatheIn.circleScale, duration: BreathingPhase.breatheIn.duration)
        animateDots()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            DispatchQueue.main.async {
                guard !isPaused else { return }

                totalElapsed += 1.0

                if totalElapsed >= totalDuration {
                    completeSession()
                    return
                }

                if phaseCountdown > 1 {
                    withAnimation { phaseCountdown -= 1 }
                } else {
                    let nextPhase = phase.next
                    phase = nextPhase
                    phaseCountdown = Int(nextPhase.duration)
                    animateCircle(to: nextPhase.circleScale, duration: nextPhase.duration)
                    animateDots()
                }
            }
        }
    }

    private func animateCircle(to scale: CGFloat, duration: Double) {
        if reduceMotion {
            circleScale = scale
        } else {
            withAnimation(.easeInOut(duration: duration)) {
                circleScale = scale
            }
        }
    }

    private func animateDots() {
        guard !reduceMotion else { return }
        withAnimation(.easeInOut(duration: phase.duration)) {
            dotOffsets = dotOffsets.map { _ in
                CGSize(
                    width: CGFloat.random(in: -25 ... 25),
                    height: CGFloat.random(in: -25 ... 25)
                )
            }
        }
    }

    private func pauseSession() {
        isPaused = true
    }

    private func resumeSession() {
        isPaused = false
    }

    private func skipPhase() {
        guard phase != .done, phase != .ready else { return }
        let remaining = Double(phaseCountdown)
        totalElapsed += remaining

        if totalElapsed >= totalDuration {
            completeSession()
            return
        }

        let nextPhase = phase.next
        phase = nextPhase
        phaseCountdown = Int(nextPhase.duration)
        animateCircle(to: nextPhase.circleScale, duration: 0.5)
        animateDots()
    }

    private func resetSession() {
        stopAllTimers()
        totalElapsed = 0
        isPaused = false
        circleScale = 0.6
        startReadyCountdown()
    }

    private func completeSession() {
        stopAllTimers()
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            phase = .done
            circleScale = BreathingPhase.done.circleScale
        }
    }

    private func stopAllTimers() {
        timer?.invalidate()
        timer = nil
        phaseTimer?.invalidate()
        phaseTimer = nil
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        guard seconds.isFinite, seconds >= 0 else { return "0:00" }

        return Duration.seconds(seconds)
            .formatted(.time(pattern: .hourMinuteSecond))
    }
}
