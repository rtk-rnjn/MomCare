import SwiftUI
import TipKit

extension Color {
    enum CustomColors {
        static let mutedRaspberry: Color = .init(red: 139 / 255, green: 69 / 255, blue: 87 / 255)
    }
}

struct TriTrackView: View {
    // MARK: Internal

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                calendarSection

                contentCard
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: .bottom)
        .background(MomCareAccent.secondary.ignoresSafeArea())
        .navigationTitle(AppTab.triTrack.title)
        .navigationBarTitleDisplayMode(forceUseLargeTitle ? .large : .inline)
        .navigationDestination(isPresented: $showingAllEvents) {
            TriTrackAllCalendarItemView(selectedDate: $selectedDate)
        }
        .navigationDestination(isPresented: $showingAllReminders) {
            TriTrackAllRemindersView()
        }
        .navigationDestination(isPresented: $showingAllSymptoms) {
            TriTrackAllSymptomsView()
        }
        .sheet(isPresented: $controlState.showingTriTrackHelp) {
            TriTrackRowLegendView()
        }
        .sheet(isPresented: $showingMedicationView) {
            MedicationView()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    withAnimation(reduceMotion ? nil : .easeInOut) {
                        controlState.showingExpandedCalendar.toggle()
                    }
                } label: {
                    Image(systemName: "calendar")
                        .font(.body)
                        .foregroundStyle(Color.CustomColors.mutedRaspberry)
                        .symbolEffect(.bounce, value: controlState.showingExpandedCalendar)
                }
                .accessibilityLabel(controlState.showingExpandedCalendar ? String(localized: "a11y_collapse_calendar_label") : String(localized: "a11y_expand_calendar_label"))
                .accessibilityIdentifier("expandCalendarButton")
            }

            ToolbarItem(placement: .topBarLeading) {
                Button {
                    selectedDate = Date()
                } label: {
                    Label {
                        Text("Today")
                    } icon: {
                        if #available(iOS 26.0, *) {
                            Image(systemName: "\(Calendar.current.component(.day, from: Date())).calendar")
                        }
                    }
                }
                .accessibilityLabel(String(localized: "a11y_jump_to_today_label"))
                .accessibilityIdentifier("jumpToTodayButton")
            }

            ToolbarItemGroup(placement: .navigationBarTrailing) {
                switch controlState.triTrackSegment {
                case .meAndBaby:
                    EmptyView()

                case .events:
                    Menu {
                        Button {
                            showingAllEvents = true
                        } label: {
                            Label("Show all events", systemImage: "calendar")
                        }

                        Button {
                            showingAllReminders = true
                        } label: {
                            Label("Show all reminders", systemImage: "bell")
                        }

                        Divider()

                        Button {
                            controlState.showingTriTrackHelp = true
                        } label: {
                            Label("Guide", systemImage: "questionmark.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .accessibilityHidden(true)
                    }
                    .menuStyle(.button)
                    .accessibilityLabel(String(localized: "a11y_more_options_label"))

                    Button {
                        controlState.showingAddEventSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.body)
                            .foregroundStyle(Color.CustomColors.mutedRaspberry)
                            .transition(.scale.combined(with: .opacity))
                    }
                    .accessibilityLabel(String(localized: "a11y_add_event_label"))
                    .accessibilityIdentifier("addEventButton")

                case .symptoms:
                    Menu {
                        Button {
                            showingAllSymptoms = true
                        } label: {
                            Label("Show all symptoms", systemImage: "calendar")
                        }

                        if #available(iOS 26.0, *) {
                            Button {
                                showingMedicationView = true
                            } label: {
                                Label("Medications", systemImage: "pills")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .accessibilityHidden(true)
                    }
                    .menuStyle(.button)
                    .accessibilityLabel(String(localized: "a11y_more_options_label"))

                    Button {
                        controlState.showingAddSymptomSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.body)
                            .foregroundStyle(Color.CustomColors.mutedRaspberry)
                            .transition(.scale.combined(with: .opacity))
                    }
                    .disabled(selectedDate > Date())
                    .accessibilityLabel(String(localized: "a11y_add_symptom_label"))
                    .accessibilityIdentifier("addSymptomButton")
                }
            }
        }
    }

    // MARK: Private

    @AppStorage(FeatureFlagState.forceUseLargeTitle.rawValue, store: Database.shared.userDefaults) private var forceUseLargeTitle: Bool = false
    @EnvironmentObject private var controlState: ControlState
    @EnvironmentObject private var authenticationService: MCAuthenticationService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var showingMedicationView: Bool = false
    @State private var selectedDate: Date = Calendar.current.startOfDay(for: .init())
    @State private var showingAllEvents: Bool = false
    @State private var showingAllReminders: Bool = false
    @State private var showingAllSymptoms: Bool = false

    private var currentProgress: PregnancyProgress {
        authenticationService.userModel?.pregnancyProgress(withReferenceDate: selectedDate) ?? PregnancyProgress(week: 0, day: 0, trimester: "-", isValid: false)
    }

    private var trimesterData: TrimesterData? {
        TriTrackData.getTrimesterData(for: currentProgress.week)
    }

    private var calendarSection: some View {
        CompactCalendarView(selectedDate: $selectedDate, isExpanded: $controlState.showingExpandedCalendar)
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
            .padding(.bottom, 4)
            .accessibilityLabel(String(localized: "a11y_tritrack_section_label"))

            tabContent
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedCorner(radius: CornerRadius.outer, corners: [.topLeft, .topRight]))
    }

    @ViewBuilder
    private var tabContent: some View {
        switch controlState.triTrackSegment {
        case .meAndBaby:
            ScrollView(.vertical) {
                if let data = trimesterData {
                    PregnancyProgressView(trimesterData: data, pregnancyData: currentProgress)
                } else {
                    ProgressView()
                }
            }
            .scrollIndicators(.hidden)
            .padding(.horizontal, 16)
            .padding(.top, 16)

        case .events:
            TriTrackCalendarItemContentView(selectedDate: $selectedDate)

        case .symptoms:
            TriTrackSymptomsContentView(selectedDate: $selectedDate)
        }
    }
}

struct PregnancyProgressView: View {
    // MARK: Internal

    let trimesterData: TrimesterData
    let pregnancyData: PregnancyProgress

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 2) {
                HStack {
                    Text("Trimester")
                    Text(pregnancyData.trimester)
                        .contentTransition(reduceMotion ? .identity : .interpolate)
                        .animation(reduceMotion ? nil : .easeInOut, value: pregnancyData.trimester)
                }
                .font(.title3)
                .fontWeight(.semibold)
                .accessibilityAddTraits(.isHeader)

                HStack(spacing: 6) {
                    HStack {
                        Text("Week")
                        Text(pregnancyData.week, format: .number)
                            .contentTransition(reduceMotion ? .identity : .numericText())
                            .animation(reduceMotion ? nil : .easeInOut, value: pregnancyData.week)
                    }

                    Text(" - ")

                    HStack {
                        Text("Day")
                        Text(pregnancyData.day, format: .number)
                            .contentTransition(reduceMotion ? .identity : .numericText())
                            .animation(reduceMotion ? nil : .easeInOut, value: pregnancyData.day)
                    }
                }
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(Color.CustomColors.mutedRaspberry)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(pregnancyData.trimester), Week \(pregnancyData.week), Day \(pregnancyData.day)")
            .accessibilityAddTraits(.isHeader)

            VStack(spacing: 16) {
                babySizeComparisonView
                babyGrowthStatisticsView
                babyAndMomInformationSectionView
                Spacer()
                Color.clear
                    .padding(30)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var showingBabyInfo = false
    @State private var showingMomInfo = false
    @State private var selectedCardPosition: CGRect = .zero

    @available(iOS 18.0, *)
    private var tips: TipGroup {
        TipGroup {
            MomCareTips.TriTrack.TriTrackBabyTip()
            MomCareTips.TriTrack.TriTrackMomTip()
        }
    }

    private var currentTip: (any Tip)? {
        if #available(iOS 18.0, *) {
            tips.currentTip
        } else {
            nil
        }
    }

    private var babySizeComparisonView: some View {
        VStack(spacing: 0) {
            ComparisonView(trimesterData: trimesterData, imageName: trimesterData.babyImageUri)
                .frame(height: 120)

            if let quote = trimesterData.quote {
                Text(quote)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .contentTransition(reduceMotion ? .identity : .interpolate)
                    .animation(reduceMotion ? nil : .easeInOut, value: quote)
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

    private var babyGrowthStatisticsView: some View {
        HStack(spacing: 12) {
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "ruler")
                        .font(.title3)
                        .accessibilityHidden(true)

                    Text("Height")
                        .font(.headline)
                }
                .padding(.top, 8)
                .padding(.bottom, 2)

                if let height = trimesterData.babyHeight {
                    Text(height, format: .measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(2))))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.CustomColors.mutedRaspberry)
                        .contentTransition(reduceMotion ? .identity : .numericText())
                        .animation(reduceMotion ? nil : .easeInOut, value: height)
                        .padding(.top, 2)
                        .padding(.bottom, 8)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))

                    StitchingBorder(cornerRadius: 16, color: .CustomColors.mutedRaspberry)
                }
            )
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(String(localized: "a11y_baby_height_label"))
            .accessibilityValue(
                trimesterData.babyHeight.map { h in
                    h.formatted(.measurement(width: .wide, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(2))))
                } ?? "Not available"
            )

            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "scalemass")
                        .font(.title3)
                        .accessibilityHidden(true)

                    Text("Weight")
                        .font(.headline)
                }
                .padding(.top, 8)
                .padding(.bottom, 2)

                if let weight = trimesterData.babyWeight {
                    Text(weight, format: .measurement(width: .abbreviated, usage: .personWeight, numberFormatStyle: .number.precision(.fractionLength(2))))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.CustomColors.mutedRaspberry)
                        .contentTransition(reduceMotion ? .identity : .numericText())
                        .animation(reduceMotion ? nil : .easeInOut, value: weight)
                        .padding(.top, 2)
                        .padding(.bottom, 8)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))

                    StitchingBorder(cornerRadius: 16, color: .CustomColors.mutedRaspberry)
                }
            )
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(String(localized: "a11y_baby_weight_label"))
            .accessibilityValue(
                trimesterData.babyWeight.map { weight in
                    weight.formatted(.measurement(width: .wide, usage: .personWeight, numberFormatStyle: .number.precision(.fractionLength(2))))
                } ?? "Not available"
            )
        }
    }

    private var babyAndMomInformationSectionView: some View {
        HStack(spacing: 12) {
            CompactInfoCard(
                title: "Baby This Week",
                iconName: "babyAsset",
                previewText: trimesterData.babyTipText,
                backgroundColor: Color(hex: "FBE8E5"),
                accentColor: .CustomColors.mutedRaspberry
            )
            .compatPopoverTip(currentTip as? MomCareTips.TriTrack.TriTrackBabyTip, arrowEdge: .bottom)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            selectedCardPosition = geo.frame(in: .global)
                        }
                }
            )
            .onTapGesture {
                showBabyInfoPopup()
            }
            .accessibilityAddTraits(.isButton)
            .accessibilityAction(.default) {
                showBabyInfoPopup()
            }

            CompactInfoCard(
                title: "Mom This Week",
                iconName: "momAsset",
                previewText: trimesterData.momTipText,
                backgroundColor: Color(hex: "FBE8E5"),
                accentColor: .CustomColors.mutedRaspberry
            )
            .compatPopoverTip(currentTip as? MomCareTips.TriTrack.TriTrackMomTip, arrowEdge: .bottom)
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
                showMomInfoPopup()
            }
            .accessibilityAddTraits(.isButton)
            .accessibilityAction(.default) {
                showMomInfoPopup()
            }
        }
    }

    private func showBabyInfoPopup() {
        let popupContent = PopupInfoCard(
            title: "Baby This Week",
            content: trimesterData.babyTipText,
            isShowing: $showingBabyInfo,
            accentColor: .CustomColors.mutedRaspberry
        )

        OverlayWindowManager.shared.showOverlay()
        OverlayWindowManager.shared.setContent(popupContent)
        showingBabyInfo = true
    }

    private func showMomInfoPopup() {
        showingMomInfo = true

        let popupContent = PopupInfoCard(
            title: "Mom This Week",
            content: trimesterData.momTipText,
            isShowing: $showingMomInfo,
            accentColor: .CustomColors.mutedRaspberry
        )

        OverlayWindowManager.shared.showOverlay()
        DispatchQueue.main.async {
            OverlayWindowManager.shared.setContent(popupContent)
        }
    }
}

struct ComparisonView: View {
    // MARK: Internal

    let trimesterData: TrimesterData
    let imageName: String?

    @ScaledMetric(relativeTo: .title3) var size: CGFloat = 64

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .center) {
                let circleSize = min(110, UIScreen.current.bounds.width * 0.28)
                if let imageName = trimesterData.imageUri {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .offset(x: 10)
                        .frame(width: circleSize * 0.9, height: circleSize * 0.9)
                        .contentTransition(reduceMotion ? .identity : .opacity)
                        .animation(reduceMotion ? nil : .easeInOut, value: imageName)
                }
            }
            .frame(maxWidth: .infinity)
            .accessibilityHidden(true)

            Image(systemName: "arrow.right")
                .font(.title2.weight(.bold))
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            VStack(alignment: .center) {
                ZStack {
                    let circleSize = min(110, UIScreen.current.bounds.width * 0.28)

                    Circle()
                        .fill(Color(hex: "E88683"))
                        .frame(width: min(110, circleSize))

                    Image(imageName ?? "Month1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: circleSize * 0.7, height: circleSize * 0.7)
                        .clipped()
                        .contentTransition(reduceMotion ? .identity : .symbolEffect)
                        .animation(reduceMotion ? nil : .easeInOut, value: imageName)
                }
            }
            .frame(maxWidth: .infinity)
            .accessibilityHidden(true)
        }
//        .frame(height: 110)
        .padding(.vertical, 10)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Baby size comparison: \(trimesterData.fruitComparison)")
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
}

struct CompactInfoCard: View {
    // MARK: Internal

    let title: String
    let iconName: String
    let previewText: String
    let backgroundColor: Color
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                    .contentTransition(reduceMotion ? .identity : .interpolate)
                    .animation(reduceMotion ? nil : .easeInOut, value: title)
            }

            ZStack(alignment: .bottomTrailing) {
                Text(previewText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(4)
                HStack(spacing: 0) {
                    Spacer()

                    LinearGradient(
                        stops: [
                            .init(color: backgroundColor.opacity(0), location: 0.0),
                            .init(color: backgroundColor.opacity(0.7), location: 0.6),
                            .init(color: backgroundColor, location: 1.0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 50, height: 20)

                    Text("see more")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .padding(.horizontal, 2)
                        .background(backgroundColor)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 120, alignment: .top)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(backgroundColor)

                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .opacity(0.1)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(previewText)")
        .accessibilityHint(String(localized: "a11y_read_more_hint"))
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
}

struct PopupInfoCard: View {
    // MARK: Internal

    let title: String
    let content: String
    @Binding var isShowing: Bool

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
                        path.addLine(to: CGPoint(x: UIScreen.current.bounds.width * 0.9, y: 0))
                        path.addLine(to: CGPoint(x: UIScreen.current.bounds.width * 0.45, y: envelopeOpen ? -20 : 40))
                        path.addLine(to: CGPoint(x: 0, y: 0))
                    }
                    .fill(Color(hex: "FBE8E5"))
                    .accessibilityHidden(true)

                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.CustomColors.mutedRaspberry)
                        .offset(y: envelopeOpen ? 5 : 15)
                        .accessibilityAddTraits(.isHeader)
                }
                .frame(height: 60)
                .animation(reduceMotion ? nil : .easeInOut, value: envelopeOpen)

                VStack(spacing: 0) {
                    HStack(spacing: 4) {
                        ForEach(0 ..< 15, id: \.self) { _ in
                            Image(systemName: "heart.fill")
                                .font(.caption2)
                                .foregroundStyle(accentColor.opacity(0.2))
                        }
                    }
                    .padding(.top, 12)
                    .accessibilityHidden(true)

                    ScrollView {
                        Text(content)
                            .font(.body)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .opacity(isContentVisible ? 1 : 0)
                    }
                    .frame(maxHeight: UIScreen.current.bounds.height * 0.35)

                    HStack(spacing: 4) {
                        ForEach(0 ..< 15, id: \.self) { _ in
                            Image(systemName: "heart.fill")
                                .font(.caption2)
                                .foregroundStyle(accentColor.opacity(0.2))
                        }
                    }
                    .padding(.bottom, 12)
                    .padding(.top, 12)
                    .accessibilityHidden(true)

                    Button(action: closeCard) {
                        Text("Close")
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
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
            )
            .cornerRadius(20)
            .scaleEffect(scale)
            .offset(cardOffset)
            .opacity(opacity)
            .frame(width: UIScreen.current.bounds.width * 0.9)
            .frame(maxHeight: UIScreen.current.bounds.height * 0.65)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            if reduceMotion {
                opacity = 1.0
                scale = 1.0
                cardOffset = .zero
                envelopeOpen = true
                isContentVisible = true
                return
            }

            withAnimation(reduceMotion ? nil : .easeInOut) {
                opacity = 1.0
                scale = 1.0
                cardOffset = .zero
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(reduceMotion ? nil : .easeInOut) {
                    envelopeOpen = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(reduceMotion ? nil : .easeIn(duration: 0.4)) {
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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private func closeCard() {
        if reduceMotion {
            isContentVisible = false
            envelopeOpen = false
            opacity = 0.0
            scale = 0.8
            cardOffset = CGSize(width: 0, height: -50)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                OverlayWindowManager.shared.hideOverlay()
                isShowing = false
            }
            return
        }

        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
            isContentVisible = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(reduceMotion ? nil : .easeInOut) {
                envelopeOpen = false
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(reduceMotion ? nil : .easeInOut) {
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
        guard overlayWindow == nil else {
            return
        }

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
            .foregroundStyle(color.opacity(0.8))
        }
    }

    // MARK: Private

    private func addPreciseCornerStitches( // swiftlint:disable:this function_parameter_count
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
