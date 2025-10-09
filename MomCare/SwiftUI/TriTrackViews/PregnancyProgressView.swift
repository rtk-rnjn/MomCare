//
//  PregnancyProgressView.swift
//  MomCare
//
//  Created by Aryan Singh on 24/07/25.
//

import SwiftUI

struct PregnancyProgressView: View {

    // MARK: Lifecycle

    init(trimesterData: TrimesterData, pregnancyData: (week: Int, day: Int, trimester: String)) {
        self.trimesterData = trimesterData
        self.pregnancyData = pregnancyData
    }

    // MARK: Internal

    @State var fruitImage: UIImage?
    @State var babyImage: UIImage?

    @State var trimesterData: TrimesterData
    @State var pregnancyData: (week: Int, day: Int, trimester: String)

    var body: some View {
        ZStack {
            GeometryReader { _ in
                ScrollView {
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
                        .padding(.horizontal)
                    }
                }
                .scrollIndicators(.hidden)
                .scrollDisabled(!isScrollEnabled)
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DisableScrolling"))) { _ in
                    isScrollEnabled = false
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("EnableScrolling"))) { _ in
                    isScrollEnabled = true
                }
            }
            .task {
                fruitImage = await trimesterData.image
                babyImage = trimesterData.babyImage
            }
        }
        .edgesIgnoringSafeArea(.all)
    }

    // MARK: Private

    @State private var isScrollEnabled = true

    @State private var showingBabyInfo = false
    @State private var showingMomInfo = false
    @State private var selectedCardPosition: CGRect = .zero

    private var sizeComparisonView: some View {
        VStack(spacing: 0) {
            ComparisonView(fruitImage: fruitImage, babyImage: babyImage)
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
        GeometryReader { geo in
            HStack(spacing: 12) {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "ruler")
                            .font(.system(size: 22))

                        Text("Height")
                            .font(.headline)
                    }

                    if let babyHeight = trimesterData.babyHeightInCentimeters {
                        Text("\(String(format: "%.2f", babyHeight)) cm")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.CustomColors.mutedRaspberry)
                    }
                }
                .padding()
                .frame(width: (geo.size.width - 12) / 2)
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

                    if let grams = trimesterData.babyWeightInGrams {
                        Text("\(String(format: "%.2f", grams)) g")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.CustomColors.mutedRaspberry)
                    }

                }
                .padding()
                .frame(width: (geo.size.width - 12) / 2)
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
        .frame(height: 110)
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
                GeometryReader { geo -> Color in
                    DispatchQueue.main.async {
                        selectedCardPosition = geo.frame(in: .global)
                    }
                    return Color.clear
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
                GeometryReader { geo -> Color in
                    DispatchQueue.main.async {
                        if showingMomInfo {
                            selectedCardPosition = geo.frame(in: .global)
                        }
                    }
                    return Color.clear
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

struct InfoCardButton: View {
    let title: String
    let subtitle: String
    let iconName: String
    var isEmoji: Bool = false
    let backgroundColor: Color
    let accentColor: Color

    var body: some View {
        HStack {
            if isEmoji {
                Text(iconName)
                    .font(.system(size: 30))
                    .padding(.trailing, 4)
            } else {
                Image(systemName: iconName)
                    .font(.system(size: 24))
                    .foregroundColor(accentColor)
                    .padding(.trailing, 4)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

struct PopupInfoCard: View {
    let title: String
    let content: String
    @Binding var isShowing: Bool
    let cardPosition: CGRect
    let accentColor: Color

    @State private var cardOffset: CGSize = .init(width: 0, height: -50)
    @State private var opacity = 0.0
    @State private var scale = 0.8
    @State private var isContentVisible = false
    @State private var envelopeOpen = false

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
                        ForEach(0..<15) { _ in
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

                    // Heart decoration at bottom
                    HStack(spacing: 4) {
                        ForEach(0..<15) { _ in
                            Image(systemName: "heart.fill")
                                .font(.system(size: 8))
                                .foregroundColor(accentColor.opacity(0.2))
                        }
                    }
                    .padding(.bottom, 12)
                    .padding(.top, 12)

                    // Close button
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
            disableParentScroll()

            // Start animations
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                opacity = 1.0
                scale = 1.0
                cardOffset = .zero
            }

            // Animation sequence
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
        .onDisappear {
            enableParentScroll()
        }
    }

    private func disableParentScroll() {
        NotificationCenter.default.post(name: NSNotification.Name("DisableScrolling"), object: nil)
    }

    private func enableParentScroll() {
        NotificationCenter.default.post(name: NSNotification.Name("EnableScrolling"), object: nil)
    }

    private func closeCard() {
        // Animation sequence remains the same
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

                    enableParentScroll()
                    isShowing = false
                }
            }
        }
    }
}

@MainActor class OverlayWindowManager {

    // MARK: Internal

    static let shared: OverlayWindowManager = .init()

    func showOverlay() {
        guard overlayWindow == nil else { return }

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let overlay = UIWindow(windowScene: windowScene)
            overlay.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            overlay.windowLevel = UIWindow.Level.normal + 1

            let overlayVC = UIViewController()
            overlayVC.view.backgroundColor = .clear
            overlay.rootViewController = overlayVC

            overlay.isHidden = false
            overlay.makeKeyAndVisible()

            overlayWindow = overlay

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

    func setContent<Content: View>(_ content: Content) {
        if let contentWindow {
            let hostingVC = UIHostingController(rootView: AnyView(content))
            hostingVC.view.backgroundColor = .clear
            contentWindow.rootViewController = hostingVC
        }
    }

    func hideOverlay() {
        contentWindow?.isHidden = true
        contentWindow = nil
        overlayWindow?.isHidden = true
        overlayWindow = nil
    }

    // MARK: Private

    private var overlayWindow: UIWindow?
    private var contentWindow: UIWindow?

}

struct ComparisonView: View {

    // MARK: Internal

    let fruitImage: UIImage?
    let babyImage: UIImage?

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .center) {
                if let fruitImage {
                    Image(uiImage: fruitImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: min(90, UIScreen.main.bounds.width * 0.22))
                        .rotation3DEffect(
                            .degrees(wiggleAmount ? 5 : -5),
                            axis: (x: 0, y: 1, z: 0)
                        )
                        .animation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true),
                            value: wiggleAmount
                        )
                        .onAppear {
                            wiggleAmount.toggle()
                        }
                }
            }
            .frame(maxWidth: .infinity)

            Image(systemName: "arrow.right")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(isShowingAnimation ? .CustomColors.mutedRaspberry : .secondary)
                .scaleEffect(isShowingAnimation ? 1.2 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 0.6)
                        .repeatCount(3, autoreverses: true),
                    value: isShowingAnimation
                )
                .frame(width: 40)

            VStack(alignment: .center) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "E88683"))
                        .frame(width: min(110, UIScreen.main.bounds.width * 0.28))

                    if let babyImage {
                        Image(uiImage: babyImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: min(75, UIScreen.main.bounds.width * 0.18))
                            .scaleEffect(isShowingAnimation ? 1.1 : 1.0)
                            .rotationEffect(isShowingAnimation ? Angle(degrees: 10) : Angle(degrees: 0))
                            .animation(
                                Animation.easeInOut(duration: 1)
                                    .repeatCount(2, autoreverses: true),
                                value: isShowingAnimation
                            )
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: 110)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .onTapGesture {
            isShowingAnimation = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                isShowingAnimation = false
            }
        }
    }

    // MARK: Private

    @State private var isShowingAnimation = false
    @State private var wiggleAmount = false
}

struct InfoCardSquare: View {
    let title: String
    let iconName: String
    var isEmoji: Bool = false
    let backgroundColor: Color
    let accentColor: Color

    var body: some View {
        VStack(spacing: 12) {
            if isEmoji {
                Text(iconName)
                    .font(.system(size: 36))
            } else {
                Image(systemName: iconName)
                    .font(.system(size: 32))
                    .foregroundColor(accentColor)
            }

            // Title below
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)

            Image(systemName: "chevron.right.circle")
                .font(.system(size: 16))
                .foregroundColor(.secondary.opacity(0.6))
                .padding(.top, 4)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(1.0, contentMode: .fill)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

struct RectangularInfoCard: View {
    let title: String
    let iconName: String
    var isEmoji: Bool = false
    let backgroundColor: Color
    let accentColor: Color

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                if isEmoji {
                    Text(iconName)
                        .font(.system(size: 32))
                } else {
                    Image(systemName: iconName)
                        .font(.system(size: 26))
                        .foregroundColor(accentColor)
                }

                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

// More compact info card component that shows content preview
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

                for i in 0..<horizontalStitchCount {
                    let startX = cornerRadius + stitchInset + CGFloat(i) * (stitchLength + horizontalSpacing)
                    path.move(to: CGPoint(x: startX, y: stitchInset))
                    path.addLine(to: CGPoint(x: startX + stitchLength, y: stitchInset))
                }

                let verticalSpacing = (height - 2 * (cornerRadius + stitchInset) - CGFloat(verticalStitchCount) * stitchLength) / max(CGFloat(verticalStitchCount - 1), 1)

                for i in 0..<verticalStitchCount {
                    let startY = cornerRadius + stitchInset + CGFloat(i) * (stitchLength + verticalSpacing)
                    path.move(to: CGPoint(x: width - stitchInset, y: startY))
                    path.addLine(to: CGPoint(x: width - stitchInset, y: startY + stitchLength))
                }

                for i in 0..<horizontalStitchCount {
                    let startX = width - cornerRadius - stitchInset - CGFloat(i) * (stitchLength + horizontalSpacing)
                    path.move(to: CGPoint(x: startX, y: height - stitchInset))
                    path.addLine(to: CGPoint(x: startX - stitchLength, y: height - stitchInset))
                }

                for i in 0..<verticalStitchCount {
                    let startY = height - cornerRadius - stitchInset - CGFloat(i) * (stitchLength + verticalSpacing)
                    path.move(to: CGPoint(x: stitchInset, y: startY))
                    path.addLine(to: CGPoint(x: stitchInset, y: startY - stitchLength))
                }

                addPreciseCornerStitches(
                    to: &path,
                    center: CGPoint(x: width - cornerRadius, y: cornerRadius),
                    radius: effectiveRadius,
                    startAngle: -.pi/2,
                    endAngle: 0,
                    stitchCount: cornerStitchCount
                )

                addPreciseCornerStitches(
                    to: &path,
                    center: CGPoint(x: width - cornerRadius, y: height - cornerRadius),
                    radius: effectiveRadius,
                    startAngle: 0,
                    endAngle: .pi/2,
                    stitchCount: cornerStitchCount
                )

                addPreciseCornerStitches(
                    to: &path,
                    center: CGPoint(x: cornerRadius, y: height - cornerRadius),
                    radius: effectiveRadius,
                    startAngle: .pi/2,
                    endAngle: .pi,
                    stitchCount: cornerStitchCount
                )

                addPreciseCornerStitches(
                    to: &path,
                    center: CGPoint(x: cornerRadius, y: cornerRadius),
                    radius: effectiveRadius,
                    startAngle: .pi,
                    endAngle: 3 * .pi/2,
                    stitchCount: cornerStitchCount
                )
            }
            .stroke(style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
            .foregroundColor(color.opacity(0.8))
        }
    }

    // MARK: Private

    private func addPreciseCornerStitches(to path: inout Path, center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, stitchCount: Int) { // swiftlint:disable:this function_parameter_count
        let totalAngle = abs(endAngle - startAngle)
        let angleStep = totalAngle / CGFloat(stitchCount)

        for i in 0..<stitchCount {
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
