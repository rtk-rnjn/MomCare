

import FSCalendar
import SwiftUI

extension Color {
    enum CustomColors {
        static let mutedRaspberry: Color = .init(red: 139 / 255, green: 69 / 255, blue: 87 / 255)
    }
}

struct TriTrackView: View {

    // MARK: Internal

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                calendarSection

                contentCard
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
            }

            if controlState.showingExpandedCalendar {
                expandedCalendarOverlay
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: .bottom)
        .background(MomCareAccent.secondary.ignoresSafeArea())
        .navigationTitle("TriTrack")
        .sheet(isPresented: $controlState.showingAddEventSheet) {
            TriTrackAddCalendarItemSheetView()
                .presentationDetents([.medium, .large])
                .scrollDismissesKeyboard(.immediately)
        }
        .sheet(isPresented: $controlState.showingAddSymptomSheet) {
            TriTrackAddSymptomSheetView()
                .presentationDetents([.medium, .large])
                .scrollDismissesKeyboard(.immediately)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        controlState.showingExpandedCalendar.toggle()
                    }
                } label: {
                    Image(systemName: "calendar")
                        .font(.body)
                        .foregroundColor(Color.CustomColors.mutedRaspberry)
                        .symbolEffect(.bounce, value: controlState.showingExpandedCalendar)
                }

                switch controlState.triTrackSegment {
                case .meAndBaby:
                    EmptyView()
                case .events:
                    Button {
                        controlState.showingAddEventSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.body)
                            .foregroundColor(Color.CustomColors.mutedRaspberry)
                            .transition(.scale.combined(with: .opacity))
                    }

                case .symptoms:
                    Button {
                        controlState.showingAddSymptomSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.body)
                            .foregroundColor(Color.CustomColors.mutedRaspberry)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
        }
    }

    // MARK: Private

    @EnvironmentObject private var controlState: ControlState
    @EnvironmentObject private var authenticationService: AuthenticationService

    @State private var selectedDate: Date = .init()

    private var currentProgress: DashboardPregnancyProgress {
        authenticationService.userModel?.pregnancyProgress ?? DashboardPregnancyProgress(week: 0, day: 0, trimester: "-", isValid: false)
    }

    private var trimesterData: TrimesterData? {
        TriTrackData.getTrimesterData(for: currentProgress.week)
    }

    private var calendarSection: some View {
        FSCalendarController(
            selectedDate: $selectedDate,
            scope: .constant(.week)
        )
        .frame(height: 80)
        .padding(.horizontal, 8)
        .padding(.bottom, 6)
        .background(Color(.systemBackground))
    }

    private var expandedCalendarOverlay: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                FSCalendarController(
                    selectedDate: $selectedDate,
                    scope: .constant(.month)
                )
                .frame(height: 350)
                .padding(.top, 8)
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 4)
            .padding(.horizontal, 16)
            .padding(.top, 8)

            Spacer()
        }
        .background(
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        controlState.showingExpandedCalendar = false
                    }
                }
        )
        .transition(.opacity)
    }

    private var contentCard: some View {
        VStack(spacing: 0) {
            Picker("", selection: $controlState.triTrackSegment) {
                ForEach(TriTrackSegment.allCases) { tab in
                    Text(tab.title).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .onAppear {
                UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.white)
                UISegmentedControl.appearance().backgroundColor = UIColor(Color.CustomColors.mutedRaspberry)
                UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
                UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color.CustomColors.mutedRaspberry)], for: .selected)
            }

            ScrollView(.vertical, showsIndicators: false) {
                tabContent
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 50)
            }
        }
        .frame(maxHeight: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedCorner(radius: 24, corners: [.topLeft, .topRight]))
    }

    @ViewBuilder
    private var tabContent: some View {
        switch controlState.triTrackSegment {
        case .meAndBaby:
            if let data = trimesterData {
                PregnancyProgressView(trimesterData: data, pregnancyData: currentProgress)
            } else {
                ProgressView()
            }

        case .events:
            TriTrackCalendarItemContentView(selectedDate: $selectedDate)

        case .symptoms:
            TriTrackSymptomsContentView(selectedDate: $selectedDate)
        }
    }
}

struct PregnancyProgressView: View {

    // MARK: Internal

    @State var trimesterData: TrimesterData
    @State var pregnancyData: DashboardPregnancyProgress

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 2) {
                Text(pregnancyData.trimester)
                    .font(.title3)
                    .fontWeight(.semibold)

                Text("Week \(pregnancyData.week) - Day \(pregnancyData.day)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.CustomColors.mutedRaspberry)
            }

            VStack(spacing: 16) {
                sizeComparisonView
                growthStatsView
                infoCardsView
            }
        }
    }

    // MARK: Private

    @State private var isScrollEnabled = true
    @State private var showingBabyInfo = false
    @State private var showingMomInfo = false
    @State private var selectedCardPosition: CGRect = .zero

    private var sizeComparisonView: some View {
        VStack(spacing: 0) {
            ComparisonView(trimesterData: trimesterData, imageName: trimesterData.babyImageUri)
                .frame(height: 120)

            if let quote = trimesterData.quote {
                Text(quote)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))

                StitchingBorder(cornerRadius: 16, color: .CustomColors.mutedRaspberry)
            }
        )
    }

    private var growthStatsView: some View {
        HStack(spacing: 12) {
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "ruler")
                        .font(.system(size: 22))

                    Text("Height")
                        .font(.headline)
                }

                if let height = trimesterData.babyHeight {
                    Text(height, format: .measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(2))))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.CustomColors.mutedRaspberry)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 110)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))

                    StitchingBorder(cornerRadius: 16, color: .CustomColors.mutedRaspberry)
                }
            )

            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "scalemass")
                        .font(.system(size: 22))

                    Text("Weight")
                        .font(.headline)
                }

                if let weight = trimesterData.babyWeight {
                    Text(weight, format: .measurement(width: .abbreviated, usage: .personWeight, numberFormatStyle: .number.precision(.fractionLength(2))))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.CustomColors.mutedRaspberry)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 110)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))

                    StitchingBorder(cornerRadius: 16, color: .CustomColors.mutedRaspberry)
                }
            )
        }
    }

    private var infoCardsView: some View {
        HStack(spacing: 12) {
            CompactInfoCard(
                title: "Baby This Week",
                iconName: "👶",
                previewText: getTruncatedText(from: trimesterData.babyTipText, maxLength: 100),
                isEmoji: true,
                backgroundColor: Color(hex: "FBE8E5"),
                accentColor: .CustomColors.mutedRaspberry
            )
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            selectedCardPosition = geo.frame(in: .global)
                        }
                }
            )
            .onTapGesture {
                let popupContent = PopupInfoCard(
                    title: "Baby This Week",
                    content: trimesterData.babyTipText,
                    isShowing: $showingBabyInfo,
                    cardPosition: selectedCardPosition,
                    accentColor: .CustomColors.mutedRaspberry
                )

                OverlayWindowManager.shared.showOverlay()
                OverlayWindowManager.shared.setContent(popupContent)
                showingBabyInfo = true
            }

            CompactInfoCard(
                title: "Mom This Week",
                iconName: "🤰",
                previewText: getTruncatedText(from: trimesterData.momTipText, maxLength: 100),
                isEmoji: true,
                backgroundColor: Color(hex: "FBE8E5"),
                accentColor: .CustomColors.mutedRaspberry
            )
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            selectedCardPosition = geo.frame(in: .global)
                        }
                        .onChange(of: showingMomInfo) { _, isShowing in
                            if isShowing {
                                selectedCardPosition = geo.frame(in: .global)
                            }
                        }
                }
            )
            .onTapGesture {
                showingMomInfo = true

                let popupContent = PopupInfoCard(
                    title: "Mom This Week",
                    content: trimesterData.momTipText,
                    isShowing: $showingMomInfo,
                    cardPosition: selectedCardPosition,
                    accentColor: .CustomColors.mutedRaspberry
                )

                OverlayWindowManager.shared.showOverlay()
                DispatchQueue.main.async {
                    OverlayWindowManager.shared.setContent(popupContent)
                }
            }
        }
    }
}

struct ComparisonView: View {

    // MARK: Internal

    let trimesterData: TrimesterData
    let imageName: String?

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .center) {
                Text(fruitEmoji)
                    .font(.system(size: 64))
            }
            .frame(maxWidth: .infinity)

            Image(systemName: "arrow.right")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.secondary)
                .frame(width: 40)

            VStack(alignment: .center) {
                ZStack {
                    let circleSize = min(110, UIScreen.main.bounds.width * 0.28)

                    Circle()
                        .fill(Color(hex: "E88683"))
                        .frame(width: min(110, circleSize))

                    Image(trimesterData.imageUri ?? "Month1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: circleSize * 0.7, height: circleSize * 0.7)
                        .clipped()
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: 110)
        .padding(.vertical, 10)
    }

    // MARK: Private

    private var fruitEmoji: String {
        let fruit = trimesterData.fruitComparison.lowercased()

        let emojiMap: [String: String] = [
            "poppy seed": "🫘", "sesame seed": "🫘", "lentil seed": "🫘",
            "blueberry": "🫐", "raspberry": "🫐", "grape": "🍇",
            "date": "🫘", "lime": "🍋", "plum": "🍑", "kiwi": "🥝",
            "peach": "🍑", "pear": "🍐", "avocado": "🥑", "orange": "🍊",
            "sweet potato": "🍠", "mango": "🥭", "banana": "🍌",
            "pomegranate": "🫐", "papaya": "🍈", "grapefruit": "🍊",
            "cantaloupe": "🍈", "cauliflower": "🥬", "lettuce": "🥬",
            "turnip": "🥔", "eggplant": "🍆", "acorn squash": "🎃",
            "cabbage": "🥬", "coconut": "🥥", "jicama": "🥔",
            "pomelo": "🍊", "butternut squash": "🎃", "pineapple": "🍍",
            "honeydew": "🍈", "small jackfruit": "🍈", "swiss chard": "🥬",
            "small pumpkin": "🎃", "watermelon": "🍉",
        ]

        return emojiMap[fruit] ?? "🫘"
    }

}

struct CompactInfoCard: View {
    let title: String
    let iconName: String
    let previewText: String
    var isEmoji: Bool = false
    let backgroundColor: Color
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 2) {
                if isEmoji {
                    Text(iconName)
                        .font(.system(size: 16))
                        .accessibilityHidden(true)
                } else {
                    Image(systemName: iconName)
                        .font(.system(size: 14))
                        .foregroundColor(accentColor)
                        .accessibilityHidden(true)
                }

                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .default))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .accessibilityAddTraits(.isHeader)
            }

            Text(previewText)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .lineLimit(5)
                .lineSpacing(1)
                .multilineTextAlignment(.leading)
                .padding(.top, 2)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(previewText)")
        .accessibilityHint("Double tap to read more information")
    }
}

struct PopupInfoCard: View {

    // MARK: Internal

    let title: String
    let content: String
    @Binding var isShowing: Bool

    let cardPosition: CGRect
    let accentColor: Color

    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    closeCard()
                }
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                ZStack {
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 0))
                        path.addLine(to: CGPoint(x: UIScreen.main.bounds.width * 0.9, y: 0))
                        path.addLine(to: CGPoint(x: UIScreen.main.bounds.width * 0.45, y: envelopeOpen ? -20 : 40))
                        path.addLine(to: CGPoint(x: 0, y: 0))
                    }
                    .fill(Color(hex: "FBE8E5"))
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: -2)

                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.CustomColors.mutedRaspberry)
                        .offset(y: envelopeOpen ? 5 : 15)
                }
                .frame(height: 60)
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: envelopeOpen)

                VStack(spacing: 0) {
                    HStack(spacing: 4) {
                        ForEach(0 ..< 15, id: \.self) { _ in
                            Image(systemName: "heart.fill")
                                .font(.system(size: 8))
                                .foregroundColor(accentColor.opacity(0.2))
                        }
                    }
                    .padding(.top, 12)

                    ScrollView {
                        Text(content)
                            .font(.body)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .opacity(isContentVisible ? 1 : 0)
                    }
                    .frame(maxHeight: UIScreen.main.bounds.height * 0.35)

                    HStack(spacing: 4) {
                        ForEach(0 ..< 15, id: \.self) { _ in
                            Image(systemName: "heart.fill")
                                .font(.system(size: 8))
                                .foregroundColor(accentColor.opacity(0.2))
                        }
                    }
                    .padding(.bottom, 12)
                    .padding(.top, 12)

                    Button(action: closeCard) {
                        Text("Close")
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.CustomColors.mutedRaspberry)
                            )
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)
                    }
                }
                .background(Color.white)
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: "FBE8E5"))
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
            )
            .cornerRadius(20)
            .scaleEffect(scale)
            .offset(cardOffset)
            .opacity(opacity)
            .frame(width: UIScreen.main.bounds.width * 0.9)
            .frame(maxHeight: UIScreen.main.bounds.height * 0.65)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                opacity = 1.0
                scale = 1.0
                cardOffset = .zero
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                    envelopeOpen = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeIn(duration: 0.4)) {
                        isContentVisible = true
                    }
                }
            }
        }
    }

    // MARK: Private

    @State private var cardOffset: CGSize = .init(width: 0, height: -50)
    @State private var opacity = 0.0
    @State private var scale = 0.8
    @State private var isContentVisible = false
    @State private var envelopeOpen = false

    private func closeCard() {
        withAnimation(.easeOut(duration: 0.2)) {
            isContentVisible = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                envelopeOpen = false
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    opacity = 0.0
                    scale = 0.8
                    cardOffset = CGSize(width: 0, height: -50)
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    OverlayWindowManager.shared.hideOverlay()
                    isShowing = false
                }
            }
        }
    }
}

@MainActor
class OverlayWindowManager {

    // MARK: Internal

    static let shared: OverlayWindowManager = .init()

    func showOverlay() {
        guard overlayWindow == nil else { return }

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let overlay = UIWindow(windowScene: windowScene)
            overlay.backgroundColor = UIColor.clear
            overlay.windowLevel = UIWindow.Level.normal + 1

            let overlayVC = UIViewController()
            overlayVC.view.backgroundColor = .clear
            overlay.rootViewController = overlayVC

            overlay.isHidden = false
            overlay.makeKeyAndVisible()

            overlayWindow = overlay

            UIView.animate(withDuration: 0.25) {
                overlay.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            }

            let content = UIWindow(windowScene: windowScene)
            content.backgroundColor = UIColor.clear
            content.windowLevel = UIWindow.Level.normal + 2

            let hostingVC = UIHostingController(rootView: EmptyView())
            hostingVC.view.backgroundColor = .clear
            content.rootViewController = hostingVC

            content.isHidden = false
            content.makeKeyAndVisible()

            contentWindow = content
        }
    }

    func setContent(_ content: some View) {
        if let contentWindow {
            let hostingVC = UIHostingController(rootView: AnyView(content))
            hostingVC.view.backgroundColor = .clear
            contentWindow.rootViewController = hostingVC
        }
    }

    func hideOverlay() {
        UIView.animate(withDuration: 0.2) {
            self.overlayWindow?.backgroundColor = UIColor.clear
        } completion: { _ in
            self.contentWindow?.isHidden = true
            self.contentWindow = nil
            self.overlayWindow?.isHidden = true
            self.overlayWindow = nil
        }
    }

    // MARK: Private

    private var overlayWindow: UIWindow?
    private var contentWindow: UIWindow?

}

struct StitchingBorder: View {

    // MARK: Internal

    let cornerRadius: CGFloat
    let color: Color
    let stitchLength: CGFloat = 5
    let stitchSpacing: CGFloat = 5
    let stitchInset: CGFloat = 6

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height

                let effectiveRadius = max(cornerRadius - stitchInset, 0)

                let horizontalStitchCount = Int((width - 2 * (cornerRadius + stitchInset)) / (stitchLength + stitchSpacing))
                let verticalStitchCount = Int((height - 2 * (cornerRadius + stitchInset)) / (stitchLength + stitchSpacing))
                let cornerStitchCount = 5

                let horizontalSpacing = (width - 2 * (cornerRadius + stitchInset) - CGFloat(horizontalStitchCount) * stitchLength) / max(CGFloat(horizontalStitchCount - 1), 1)

                for i in 0 ..< horizontalStitchCount {
                    let startX = cornerRadius + stitchInset + CGFloat(i) * (stitchLength + horizontalSpacing)
                    path.move(to: CGPoint(x: startX, y: stitchInset))
                    path.addLine(to: CGPoint(x: startX + stitchLength, y: stitchInset))
                }

                let verticalSpacing = (height - 2 * (cornerRadius + stitchInset) - CGFloat(verticalStitchCount) * stitchLength) / max(CGFloat(verticalStitchCount - 1), 1)

                for i in 0 ..< verticalStitchCount {
                    let startY = cornerRadius + stitchInset + CGFloat(i) * (stitchLength + verticalSpacing)
                    path.move(to: CGPoint(x: width - stitchInset, y: startY))
                    path.addLine(to: CGPoint(x: width - stitchInset, y: startY + stitchLength))
                }

                for i in 0 ..< horizontalStitchCount {
                    let startX = width - cornerRadius - stitchInset - CGFloat(i) * (stitchLength + horizontalSpacing)
                    path.move(to: CGPoint(x: startX, y: height - stitchInset))
                    path.addLine(to: CGPoint(x: startX - stitchLength, y: height - stitchInset))
                }

                for i in 0 ..< verticalStitchCount {
                    let startY = height - cornerRadius - stitchInset - CGFloat(i) * (stitchLength + verticalSpacing)
                    path.move(to: CGPoint(x: stitchInset, y: startY))
                    path.addLine(to: CGPoint(x: stitchInset, y: startY - stitchLength))
                }

                addPreciseCornerStitches(
                    to: &path,
                    center: CGPoint(x: width - cornerRadius, y: cornerRadius),
                    radius: effectiveRadius,
                    startAngle: -.pi / 2,
                    endAngle: 0,
                    stitchCount: cornerStitchCount
                )

                addPreciseCornerStitches(
                    to: &path,
                    center: CGPoint(x: width - cornerRadius, y: height - cornerRadius),
                    radius: effectiveRadius,
                    startAngle: 0,
                    endAngle: .pi / 2,
                    stitchCount: cornerStitchCount
                )

                addPreciseCornerStitches(
                    to: &path,
                    center: CGPoint(x: cornerRadius, y: height - cornerRadius),
                    radius: effectiveRadius,
                    startAngle: .pi / 2,
                    endAngle: .pi,
                    stitchCount: cornerStitchCount
                )

                addPreciseCornerStitches(
                    to: &path,
                    center: CGPoint(x: cornerRadius, y: cornerRadius),
                    radius: effectiveRadius,
                    startAngle: .pi,
                    endAngle: 3 * .pi / 2,
                    stitchCount: cornerStitchCount
                )
            }
            .stroke(style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
            .foregroundColor(color.opacity(0.8))
        }
    }

    // MARK: Private

    private func addPreciseCornerStitches(
        to path: inout Path,
        center: CGPoint,
        radius: CGFloat,
        startAngle: CGFloat,
        endAngle: CGFloat,
        stitchCount: Int
    ) {
        let totalAngle = abs(endAngle - startAngle)
        let angleStep = totalAngle / CGFloat(stitchCount)

        for i in 0 ..< stitchCount {
            let startAnglePoint = startAngle + CGFloat(i) * angleStep
            let endAnglePoint = startAnglePoint + angleStep * 0.6

            let startPoint = CGPoint(
                x: center.x + radius * cos(startAnglePoint),
                y: center.y + radius * sin(startAnglePoint)
            )

            let endPoint = CGPoint(
                x: center.x + radius * cos(endAnglePoint),
                y: center.y + radius * sin(endAnglePoint)
            )

            path.move(to: startPoint)
            path.addLine(to: endPoint)
        }
    }
}

private func getTruncatedText(from text: String, maxLength: Int) -> String {
    if text.count <= maxLength {
        return text
    }

    let index = text.index(text.startIndex, offsetBy: min(maxLength - 3, text.count))
    let truncatedText = text[..<index]

    if let lastSpace = truncatedText.lastIndex(of: " ") {
        return text[..<lastSpace] + "..."
    }

    return String(truncatedText) + "..."
}

#Preview {
    NavigationStack {
        TriTrackView()
    }
}
