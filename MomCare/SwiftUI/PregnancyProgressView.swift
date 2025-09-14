//
//  PregnancyProgressView.swift
//  MomCare
//
//  Created by Aryan Singh on 24/07/25.
//

import SwiftUI

struct PregnancyProgressView: View {

    // MARK: Lifecycle

    init?() {
        guard let pregnancyData = MomCareUser.shared.user?.pregancyData else {
            fatalError("Pregnancy data is not available")
        }
        trimester = pregnancyData.trimester
        weekDay = "Week \(pregnancyData.week) - Day \(pregnancyData.day)"

        let trimesterData = TriTrackData.getTrimesterData(for: pregnancyData.week)

        babyWeight = "\(trimesterData?.babyWeightInGrams ?? 0) g"
        babyHeight = "\(trimesterData?.babyHeightInCentimeters ?? 0) cm"
        quote = trimesterData?.quote ?? "Keep growing strong!"

        babyInfo = trimesterData?.babyTipText ?? "Your baby is developing rapidly this week. Keep up with your prenatal care!"
        momInfo = trimesterData?.momTipText ?? "Remember to stay hydrated and get plenty of rest. Your body is doing amazing things!"

        self.trimesterData = trimesterData
    }

    // MARK: Internal

    @State var fruitImage: UIImage?
    @State var babyImage: UIImage?

    var trimester: String
    var weekDay: String
    var babyHeight: String
    var babyWeight: String
    var babyInfo: String
    var momInfo: String
    var quote: String

    var trimesterData: TrimesterData?

    var body: some View {
        ZStack {
            GeometryReader { _ in
                ScrollView {
                    VStack(spacing: 16) {
                        VStack(spacing: 2) {
                            Text(trimester)
                                .font(.title3)
                                .fontWeight(.semibold)

                            Text(weekDay)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "924350"))
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
                fruitImage = await trimesterData?.image
                babyImage = trimesterData?.babyImage
            }

            // REMOVE the popup cards from this ZStack - they will be handled by the OverlayWindowManager
        }
        .edgesIgnoringSafeArea(.all)
    }

    // MARK: Private

    // MARK: - Body

    @State private var isScrollEnabled = true

    @State private var showingBabyInfo = false
    @State private var showingMomInfo = false
    @State private var selectedCardPosition: CGRect = .zero

    // MARK: - Component Views

    private var sizeComparisonView: some View {
        VStack(spacing: 0) { // Reduce spacing to avoid empty gaps
            // Comparison view with images
            ComparisonView(fruitImage: fruitImage, babyImage: babyImage)
                .frame(height: 120)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Baby size comparison")
                .accessibilityHint("Your baby is currently the size shown in the comparison")

            // Quote text - moved closer to the comparison view
            Text(quote)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.vertical, 12) // More vertical padding to fill space evenly
                .accessibilityAddTraits(.isStaticText)
        }
        .padding(.vertical, 12) // Consistent vertical padding
        .padding(.horizontal, 12)
        .background(
            ZStack {
                // Base card background
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))

                // Stitching effect overlay
                StitchingBorder(cornerRadius: 16, color: Color(hex: "924350"))
            }
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Baby size comparison: \(quote)")
    }

    private var growthStatsView: some View {
        GeometryReader { geo in
            HStack(spacing: 12) {
                // Height card with stitching effect only
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "ruler")
                            .font(.system(size: 22))
                            .accessibilityHidden(true)

                        Text("Height")
                            .font(.headline)
                            .accessibilityAddTraits(.isHeader)
                    }

                    Text(babyHeight)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "924350"))
                }
                .padding()
                .frame(width: (geo.size.width - 12) / 2)
                .frame(height: 110)
                .background(
                    ZStack {
                        // Base card background - using system background with no shadow
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            // Shadow removed

                        // Only keep the stitching effect overlay
                        StitchingBorder(cornerRadius: 16, color: Color(hex: "924350"))
                    }
                )
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Baby height: \(babyHeight)")
                .accessibilityAddTraits(.isStaticText)

                // Weight card with stitching effect only
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "scalemass")
                            .font(.system(size: 22))
                            .accessibilityHidden(true)

                        Text("Weight")
                            .font(.headline)
                            .accessibilityAddTraits(.isHeader)
                    }

                    Text(babyWeight)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "924350"))
                }
                .padding()
                .frame(width: (geo.size.width - 12) / 2)
                .frame(height: 110)
                .background(
                    ZStack {
                        // Base card background - using system background with no shadow
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            // Shadow removed

                        // Only keep the stitching effect overlay
                        StitchingBorder(cornerRadius: 16, color: Color(hex: "924350"))
                    }
                )
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Baby weight: \(babyWeight)")
                .accessibilityAddTraits(.isStaticText)
            }
        }
        .frame(height: 110) // Set the overall height
    }

    private var infoCardsView: some View {
        HStack(spacing: 12) {
            // Baby info card with content preview
            CompactInfoCard(
                title: "Baby This Week",
                iconName: "👶",
                previewText: getTruncatedText(from: babyInfo, maxLength: 100),
                isEmoji: true,
                backgroundColor: Color(hex: "FBE8E5"),
                accentColor: Color(hex: "924350")
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
                // Create popup card directly
                let popupContent = PopupInfoCard(
                    title: "Baby This Week",
                    content: babyInfo,
                    isShowing: $showingBabyInfo,
                    cardPosition: selectedCardPosition,
                    accentColor: Color(hex: "924350")
                )

                // First show overlay window
                OverlayWindowManager.shared.showOverlay()

                // Set content in the overlay window - this will display the popup
                OverlayWindowManager.shared.setContent(popupContent)

                // Update state
                showingBabyInfo = true
            }
            .accessibilityAddTraits(.isButton)

            // Mom info card with content preview
            CompactInfoCard(
                title: "Mom This Week",
                iconName: "🤰",
                previewText: getTruncatedText(from: momInfo, maxLength: 100),
                isEmoji: true,
                backgroundColor: Color(hex: "FBE8E5"),
                accentColor: Color(hex: "924350")
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
                // Create and show popup using the overlay window manager directly
                showingMomInfo = true

                // Create popup card directly in the overlay window
                let popupContent = PopupInfoCard(
                    title: "Mom This Week",
                    content: momInfo, // Pass the full content
                    isShowing: $showingMomInfo,
                    cardPosition: selectedCardPosition,
                    accentColor: Color(hex: "924350")
                )

                // First show overlay window
                OverlayWindowManager.shared.showOverlay()

                // Set content in the overlay window
                DispatchQueue.main.async {
                    OverlayWindowManager.shared.setContent(popupContent)
                }
            }
            .accessibilityAddTraits(.isButton)
        }
        .accessibilityElement(children: .contain)
    }
}

// Info card button component
struct InfoCardButton: View {
    let title: String
    let subtitle: String
    let iconName: String
    var isEmoji: Bool = false // Flag to determine if we're using emoji or SF Symbol
    let backgroundColor: Color
    let accentColor: Color

    var body: some View {
        HStack {
            // Use either emoji or SF Symbol based on isEmoji flag
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
            // Clear background (the overlay is in a separate window)
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    closeCard()
                }
                .edgesIgnoringSafeArea(.all)
                .accessibilityLabel("Close popup")
                .accessibilityHint("Tap to close the information popup")
                .accessibilityAddTraits(.isButton)

            // Card content
            VStack(spacing: 0) {
                // Card header with envelope flap
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
                        .foregroundColor(Color(hex: "924350"))
                        .offset(y: envelopeOpen ? 5 : 15)
                        .accessibilityAddTraits(.isHeader)
                }
                .frame(height: 60)
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: envelopeOpen)

                // Content section
                VStack(spacing: 0) {
                    // Heart decoration at top
                    HStack(spacing: 4) {
                        ForEach(0..<15) { _ in
                            Image(systemName: "heart.fill")
                                .font(.system(size: 8))
                                .foregroundColor(accentColor.opacity(0.2))
                        }
                    }
                    .padding(.top, 12)

                    // Content in ScrollView
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
                                    .fill(Color(hex: "924350"))
                            )
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)
                    }
                    .accessibilityLabel("Close")
                    .accessibilityHint("Close this information popup")
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

    // Helper methods remain the same
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
                    // Hide the overlay window when closing
                    OverlayWindowManager.shared.hideOverlay()

                    enableParentScroll()
                    isShowing = false
                }
            }
        }
    }
}

// Helper extension to remove .onAppear from a SwiftUI view
extension View {
    func removeOnAppear() -> some View {
        onAppear {}
    }
}

// Helper struct to create a full screen overlay that integrates with UIKit
@MainActor class OverlayWindowManager {

    // MARK: Internal

    static let shared: OverlayWindowManager = .init()

    func showOverlay() {
        guard overlayWindow == nil else { return }

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            // Step 1: Create overlay window (darkens everything)
            let overlay = UIWindow(windowScene: windowScene)
            overlay.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            overlay.windowLevel = UIWindow.Level.normal + 1

            let overlayVC = UIViewController()
            overlayVC.view.backgroundColor = .clear
            overlay.rootViewController = overlayVC

            overlay.isHidden = false
            overlay.makeKeyAndVisible()

            overlayWindow = overlay

            // Step 2: Create content window (will hold the popup)
            let content = UIWindow(windowScene: windowScene)
            content.backgroundColor = UIColor.clear
            content.windowLevel = UIWindow.Level.normal + 2 // Above overlay

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
            // Left section with fruit
            VStack(alignment: .center) {
                if let fruitImage {
                    Image(uiImage: fruitImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: min(90, UIScreen.main.bounds.width * 0.22)) // Slightly smaller
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

            // Center arrow - keep centered vertically
            Image(systemName: "arrow.right")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(isShowingAnimation ? Color(hex: "924350") : .secondary)
                .scaleEffect(isShowingAnimation ? 1.2 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 0.6)
                        .repeatCount(3, autoreverses: true),
                    value: isShowingAnimation
                )
                .frame(width: 40)

            // Right section with baby - making the baby smaller and better centered
            VStack(alignment: .center) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "E88683"))
                        .frame(width: min(110, UIScreen.main.bounds.width * 0.28)) // Slightly smaller circle

                    if let babyImage {
                        Image(uiImage: babyImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: min(75, UIScreen.main.bounds.width * 0.18)) // Smaller baby image
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
        .frame(height: 110) // Slightly shorter height
        .padding(.vertical, 10) // Added vertical padding to center everything better
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

// Square info card component for side-by-side layout
struct InfoCardSquare: View {
    let title: String
    let iconName: String
    var isEmoji: Bool = false
    let backgroundColor: Color
    let accentColor: Color

    var body: some View {
        VStack(spacing: 12) {
            // Icon at the top
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

            // Subtle indicator to tap
            Image(systemName: "chevron.right.circle")
                .font(.system(size: 16))
                .foregroundColor(.secondary.opacity(0.6))
                .padding(.top, 4)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(1.0, contentMode: .fill) // Keep it square
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

// Rectangular info card component that matches the height/weight cards
struct RectangularInfoCard: View {
    let title: String
    let iconName: String
    var isEmoji: Bool = false
    let backgroundColor: Color
    let accentColor: Color

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                // Icon
                if isEmoji {
                    Text(iconName)
                        .font(.system(size: 32))
                } else {
                    Image(systemName: iconName)
                        .font(.system(size: 26))
                        .foregroundColor(accentColor)
                }

                // Title
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                // Subtle indicator to tap
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
            // Header with icon and title in a more compact layout
            HStack(spacing: 2) {
                // Icon - reduced size
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

                // Title - slightly smaller font with minimized spacing
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .default))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .accessibilityAddTraits(.isHeader)
            }

            // Preview text with more space
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

// Custom stitching border effect with improved corners and consistency
struct StitchingBorder: View {

    // MARK: Internal

    let cornerRadius: CGFloat
    let color: Color
    let stitchLength: CGFloat = 5 // Slightly shorter for more consistent appearance
    let stitchSpacing: CGFloat = 5 // Equal spacing for consistency
    let stitchInset: CGFloat = 6

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                // Calculate dimensions
                let width = geometry.size.width
                let height = geometry.size.height

                // Define the effective radius with consistent inset
                let effectiveRadius = max(cornerRadius - stitchInset, 0)

                // Calculate stitch counts to ensure consistency
                let horizontalStitchCount = Int((width - 2 * (cornerRadius + stitchInset)) / (stitchLength + stitchSpacing))
                let verticalStitchCount = Int((height - 2 * (cornerRadius + stitchInset)) / (stitchLength + stitchSpacing))
                let cornerStitchCount = 5 // Fixed number of stitches for corners for consistency

                // Top edge with exact positioning
                let horizontalSpacing = (width - 2 * (cornerRadius + stitchInset) - CGFloat(horizontalStitchCount) * stitchLength) / max(CGFloat(horizontalStitchCount - 1), 1)

                for i in 0..<horizontalStitchCount {
                    let startX = cornerRadius + stitchInset + CGFloat(i) * (stitchLength + horizontalSpacing)
                    path.move(to: CGPoint(x: startX, y: stitchInset))
                    path.addLine(to: CGPoint(x: startX + stitchLength, y: stitchInset))
                }

                // Right edge with exact positioning
                let verticalSpacing = (height - 2 * (cornerRadius + stitchInset) - CGFloat(verticalStitchCount) * stitchLength) / max(CGFloat(verticalStitchCount - 1), 1)

                for i in 0..<verticalStitchCount {
                    let startY = cornerRadius + stitchInset + CGFloat(i) * (stitchLength + verticalSpacing)
                    path.move(to: CGPoint(x: width - stitchInset, y: startY))
                    path.addLine(to: CGPoint(x: width - stitchInset, y: startY + stitchLength))
                }

                // Bottom edge with exact positioning
                for i in 0..<horizontalStitchCount {
                    let startX = width - cornerRadius - stitchInset - CGFloat(i) * (stitchLength + horizontalSpacing)
                    path.move(to: CGPoint(x: startX, y: height - stitchInset))
                    path.addLine(to: CGPoint(x: startX - stitchLength, y: height - stitchInset))
                }

                // Left edge with exact positioning
                for i in 0..<verticalStitchCount {
                    let startY = height - cornerRadius - stitchInset - CGFloat(i) * (stitchLength + verticalSpacing)
                    path.move(to: CGPoint(x: stitchInset, y: startY))
                    path.addLine(to: CGPoint(x: stitchInset, y: startY - stitchLength))
                }

                // Improved corner stitches with perfect spacing
                // Top-right corner
                addPreciseCornerStitches(
                    to: &path,
                    center: CGPoint(x: width - cornerRadius, y: cornerRadius),
                    radius: effectiveRadius,
                    startAngle: -.pi/2,
                    endAngle: 0,
                    stitchCount: cornerStitchCount
                )

                // Bottom-right corner
                addPreciseCornerStitches(
                    to: &path,
                    center: CGPoint(x: width - cornerRadius, y: height - cornerRadius),
                    radius: effectiveRadius,
                    startAngle: 0,
                    endAngle: .pi/2,
                    stitchCount: cornerStitchCount
                )

                // Bottom-left corner
                addPreciseCornerStitches(
                    to: &path,
                    center: CGPoint(x: cornerRadius, y: height - cornerRadius),
                    radius: effectiveRadius,
                    startAngle: .pi/2,
                    endAngle: .pi,
                    stitchCount: cornerStitchCount
                )

                // Top-left corner
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

    // Improved helper function for precise corner stitch placement
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

// Preview provider
struct PregnancyProgressView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a preview with sample data
        GeometryReader { _ in
            ScrollView {
                VStack(spacing: 16) {
                    Text("Trimester 2")
                        .font(.title3)
                        .fontWeight(.semibold)

                    Text("Week 14 - Day 1")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "924350"))

                    // Sample size comparison and stats
                    VStack(spacing: 16) {
                        // Rest of your preview content

                        // Test the new compact info cards
                        HStack(spacing: 12) {
                            CompactInfoCard(
                                title: "Baby Development",
                                iconName: "👶",
                                previewText: "At this point, your baby is the size of a peach. The baby is developing more defined facial features and unique fingerprints...",
                                isEmoji: true,
                                backgroundColor: Color(hex: "FBE8E5"),
                                accentColor: Color(hex: "924350")
                            )

                            CompactInfoCard(
                                title: "Mom This Week",
                                iconName: "🤰",
                                previewText: "Your pregnancy is starting to show! Morning sickness should be easing up as the second trimester begins...",
                                isEmoji: true,
                                backgroundColor: Color(hex: "FBE8E5"),
                                accentColor: Color(hex: "924350")
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

// Helper method to truncate text with ellipsis
private func getTruncatedText(from text: String, maxLength: Int) -> String {
    if text.count <= maxLength {
        return text
    }

    // Find a good breaking point (space) near the maxLength
    let index = text.index(text.startIndex, offsetBy: min(maxLength - 3, text.count))
    let truncatedText = text[..<index]

    // Try to find the last space to make a clean break
    if let lastSpace = truncatedText.lastIndex(of: " ") {
        return text[..<lastSpace] + "..."
    }

    return String(truncatedText) + "..."
}
