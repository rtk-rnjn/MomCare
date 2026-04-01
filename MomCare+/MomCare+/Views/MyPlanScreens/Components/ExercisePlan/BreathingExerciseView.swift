import AVFoundation
import OSLog
import SwiftUI

struct BreathingExerciseView: View {
    // MARK: Internal

    var body: some View {
        NavigationStack {
            ZStack {
                if reduceTransparency {
                    pastel.ignoresSafeArea()
                } else {
                    LinearGradient(
                        colors: [pastel, Color(hex: "E8F4F8"), Color.white],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                }

                VStack(spacing: 0) {
                    Spacer()

                    breathingCircle
                        .padding(.bottom, 20)

                    phaseLabel
                        .padding(.bottom, 30)

                    sessionProgress
                        .padding(.horizontal, 40)
                        .padding(.bottom, 20)

                    Spacer()

                    glassControls
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        stopAllTimers()
                        Task {
                            try! await contentServiceHandler.saveBreathingSession(start: .init().addingTimeInterval(-totalElapsed), end: .init())
                        }
                        dismiss()
                    }
                    .accessibilityLabel("Close breathing exercise")
                }

                ToolbarItem(placement: .principal) {
                    Text("Breathing Exercise")
                        .font(.headline.weight(.medium))
                        .foregroundStyle(darkAccent.opacity(0.7))
                        .accessibilityAddTraits(.isHeader)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationSubtitle(
                Text(formatTime(totalElapsed))
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(darkAccent)
                    .monospacedDigit()
            )
        }
        .onAppear {
            setupAudioSession()
            startReadyCountdown()
            Task {
                let durationCompleted = try? await contentServiceHandler.fetchBreathingCompletionSeconds(for: .init())
                if let duration = durationCompleted {
                    totalElapsed = duration
                }
            }
        }
        .onDisappear {
            stopAllTimers()
        }
    }

    // MARK: Private

    @EnvironmentObject private var contentServiceHandler: ContentServiceHandler
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    @State private var phase: BreathingPhase = .ready
    @State private var phaseCountdown: Int = 3
    @State private var totalElapsed: Double = 0
    @State private var circleScale: CGFloat = 0.6
    @State private var isActive = false
    @State private var isPaused = false
    @State private var speechSynthesizer: AVSpeechSynthesizer = .init()

    @State private var dotOffsets: [CGSize] = (0 ..< 6).map { _ in
        CGSize(width: CGFloat.random(in: -20 ... 20), height: CGFloat.random(in: -20 ... 20))
    }

    @State private var timer: Timer?
    @State private var phaseTimer: Timer?

    private let logger: Logger = .init(subsystem: Bundle.main.bundleIdentifier ?? "MomCare", category: "BreathingExercise")

    private let pastel: Color = .init(hex: "D0E1F0")
    private let accent: Color = .init(hex: "8BBBD4")
    private let darkAccent: Color = .init(hex: "4A7A9B")

    private var totalDuration: Double {
        contentServiceHandler.breathingTargetInSeconds
    }

    private var progress: Double {
        guard totalDuration > 0 else {
            return 0
        }

        return min(totalElapsed / totalDuration, 1.0)
    }

    private var breathingCircle: some View {
        ZStack {
            ForEach(0 ..< 3, id: \.self) { i in
                Circle()
                    .fill(accent.opacity(0.06 - Double(i) * 0.015))
                    .frame(width: 260 + CGFloat(i) * 40, height: 260 + CGFloat(i) * 40)
                    .scaleEffect(circleScale * (1.0 + CGFloat(i) * 0.05))
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
                .animation(reduceMotion ? nil : .linear(duration: 0.5), value: progress)

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
                .scaleEffect(circleScale)
                .shadow(color: accent.opacity(0.3), radius: 20, x: 0, y: 5)

            Circle()
                .fill(Color.white.opacity(0.6))
                .frame(width: 120, height: 120)
                .scaleEffect(circleScale)

            breathingFace
                .scaleEffect(circleScale)

            ForEach(0 ..< 6, id: \.self) { i in
                Circle()
                    .fill(accent.opacity(0.3 + Double(i % 3) * 0.1))
                    .frame(width: CGFloat(6 + (i % 3) * 3), height: CGFloat(6 + (i % 3) * 3))
                    .offset(dotPosition(for: i))
            }
        }
        .accessibilityHidden(true)
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
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: phase)
    }

    @ViewBuilder
    private var mouthShape: some View {
        switch phase {
        case .breatheIn:
            Circle()
                .stroke(darkAccent, lineWidth: 2)
                .frame(width: 12, height: 12)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: phase)

        case .hold:
            RoundedRectangle(cornerRadius: 1)
                .fill(darkAccent)
                .frame(width: 14, height: 2)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: phase)

        case .breatheOut:
            Ellipse()
                .stroke(darkAccent, lineWidth: 2)
                .frame(width: 10, height: 7)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: phase)

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
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: phase)
    }

    private var phaseLabel: some View {
        VStack(spacing: 8) {
            Text(phase.rawValue)
                .font(.title.weight(.semibold))
                .foregroundStyle(darkAccent)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: phase)
                .accessibilityLabel("Current phase: \(phase.rawValue)")
                .accessibilityAddTraits(.updatesFrequently)

            if phase != .done {
                Text("\(phaseCountdown)")
                    .font(.largeTitle.weight(.light))
                    .fontDesign(.rounded)
                    .foregroundStyle(darkAccent.opacity(0.6))
                    .monospacedDigit()
                    .contentTransition(reduceMotion ? .identity : .numericText())
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: phaseCountdown)
                    .accessibilityLabel("\(phaseCountdown) seconds")
                    .accessibilityAddTraits(.updatesFrequently)
            } else {
                Text("Session Complete")
                    .font(.subheadline)
                    .foregroundStyle(darkAccent.opacity(0.6))
            }
        }
    }

    private var sessionProgress: some View {
        VStack(spacing: 8) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(reduceTransparency ? Color(.systemGray4) : accent.opacity(0.15))

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [accent, darkAccent],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress)
                        .animation(reduceMotion ? nil : .linear(duration: 0.5), value: progress)
                }
            }
            .frame(height: 6)
            .accessibilityHidden(true)

            HStack {
                Text(formatTime(totalElapsed))
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(darkAccent.opacity(0.5))

                Spacer()

                Text(formatTime(totalDuration))
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(darkAccent.opacity(0.5))
            }
            .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Session progress")
        .accessibilityValue("\(formatTime(totalElapsed)) of \(formatTime(totalDuration))")
        .accessibilityAddTraits(.updatesFrequently)
    }

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
            .accessibilityLabel("Reset session")

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
        speak("Are you Ready?")
        phaseCountdown = Int(BreathingPhase.ready.duration)

        phaseTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            DispatchQueue.main.async {
                if phaseCountdown > 1 {
                    withAnimation(reduceMotion ? nil : .default) { phaseCountdown -= 1 }
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
        speak("Breathe in")
        phaseCountdown = Int(BreathingPhase.breatheIn.duration)
        animateCircle(to: BreathingPhase.breatheIn.circleScale, duration: BreathingPhase.breatheIn.duration)
        animateDots()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            DispatchQueue.main.async {
                guard !isPaused else {
                    return
                }

                totalElapsed += 1.0

                if totalElapsed >= totalDuration {
                    completeSession()
                    return
                }

                if phaseCountdown > 1 {
                    withAnimation(reduceMotion ? nil : .default) { phaseCountdown -= 1 }
                } else {
                    let nextPhase = phase.next
                    phase = nextPhase

                    speak(nextPhase.voiceText)
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
        let newOffsets = dotOffsets.map { _ in
            CGSize(
                width: CGFloat.random(in: -25 ... 25),
                height: CGFloat.random(in: -25 ... 25)
            )
        }
        if reduceMotion {
            dotOffsets = newOffsets
        } else {
            withAnimation(.easeInOut(duration: phase.duration)) {
                dotOffsets = newOffsets
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
        guard phase != .done, phase != .ready else {
            return
        }

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
        speak("Well done. You did Amazing!")
        if reduceMotion {
            phase = .done
            circleScale = BreathingPhase.done.circleScale
        } else {
            withAnimation(.easeInOut) {
                phase = .done
                circleScale = BreathingPhase.done.circleScale
            }
        }
    }

    private func stopAllTimers() {
        timer?.invalidate()
        timer = nil
        phaseTimer?.invalidate()
        phaseTimer = nil
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        guard seconds.isFinite, seconds >= 0 else {
            return "0:00"
        }

        return Duration.seconds(seconds).formatted(.time(pattern: .minuteSecond))
    }

    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Samantha-compact")
        utterance.rate = 0.4
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0

        speechSynthesizer.stopSpeaking(at: .immediate)
        speechSynthesizer.speak(utterance)
    }

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            logger.error("Failed to set audio category: \(error.localizedDescription)")
        }
    }
}

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
        case .ready: 5.0
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

    var voiceText: String {
        switch self {
        case .breatheIn:
            "Slowly breathe in..."
        case .hold:
            "Hold?"
        case .breatheOut:
            "Now breathe out..."
        case .ready:
            "Get ready..."
        case .done:
            "Well done. Session complete."
        }
    }
}
