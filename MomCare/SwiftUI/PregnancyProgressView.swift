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

    // MARK: - Body

    var body: some View {
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
                .overlay {
                    if showingBabyInfo {
                        PopupInfoCard(
                            title: "Baby Development",
                            content: babyInfo,
                            isShowing: $showingBabyInfo,
                            cardPosition: selectedCardPosition,
                            accentColor: Color(hex: "924350")
                        )
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.8).combined(with: .opacity),
                            removal: .scale(scale: 0.8).combined(with: .opacity)
                        ))
                    }

                    if showingMomInfo {
                        PopupInfoCard(
                            title: "Mom This Week",
                            content: momInfo,
                            isShowing: $showingMomInfo,
                            cardPosition: selectedCardPosition,
                            accentColor: Color(hex: "924350")
                        )
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.8).combined(with: .opacity),
                            removal: .scale(scale: 0.8).combined(with: .opacity)
                        ))
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .task {
            fruitImage = await trimesterData?.image
            babyImage = trimesterData?.babyImage
        }
    }

    // MARK: Private

    @State private var showingBabyInfo = false
    @State private var showingMomInfo = false
    @State private var selectedCardPosition: CGRect = .zero

    // MARK: - Component Views

    private var sizeComparisonView: some View {
        VStack(spacing: 12) {
            ComparisonView(fruitImage: fruitImage, babyImage: babyImage)

            Text(quote)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }

    private var growthStatsView: some View {
        HStack(spacing: 12) {
            // Height card
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "ruler")
                        .font(.system(size: 22))

                    Text("Height")
                        .font(.headline)
                }

                Text(babyHeight)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "924350"))
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            )

            // Weight card
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "scalemass")
                        .font(.system(size: 22))

                    Text("Weight")
                        .font(.headline)
                }

                Text(babyWeight)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "924350"))
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
        }
    }

    private var infoCardsView: some View {
        HStack(spacing: 12) {
            // Baby info card with content preview
            CompactInfoCard(
                title: "Baby Development",
                iconName: "👶",
                previewText: getTruncatedText(from: babyInfo, maxLength: 100),
                isEmoji: true,
                backgroundColor: Color(hex: "FBE8E5"),
                accentColor: Color(hex: "924350")
            )
            .background(
                GeometryReader { geo -> Color in
                    DispatchQueue.main.async {
                        if showingBabyInfo {
                            selectedCardPosition = geo.frame(in: .global)
                        }
                    }
                    return Color.clear
                }
            )
            .onTapGesture {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    showingBabyInfo = true
                }
            }
            
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
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    showingMomInfo = true
                }
            }
        }
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
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .opacity(opacity)
                .onTapGesture {
                    closeCard()
                }

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
                        .foregroundColor(Color(hex: "924350"))
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

                    // Content
                    ScrollView {
                        Text(content)
                            .font(.body)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .opacity(isContentVisible ? 1 : 0)
                    }
                    .frame(maxHeight: 350)

                    // Decorative bottom border
                    HStack(spacing: 4) {
                        ForEach(0..<15) { _ in
                            Image(systemName: "heart.fill")
                                .font(.system(size: 8))
                                .foregroundColor(accentColor.opacity(0.2))
                        }
                    }
                    .padding(.bottom, 12)

                    // Close button
                    Button(action: closeCard) {
                        Text("Close")
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: "924350"))
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
        }
        // Use a full-screen ZStack to position the card in the center of the device
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all) // Ensure it covers the entire screen
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                opacity = 1.0
                scale = 1.0
                cardOffset = .zero
            }

            // Animate the envelope opening
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                    envelopeOpen = true
                }

                // Then show the content
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeIn(duration: 0.4)) {
                        isContentVisible = true
                    }
                }
            }
        }
    }

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
                    isShowing = false
                }
            }
        }
    }
}

struct ComparisonView: View {

    // MARK: Internal

    let fruitImage: UIImage?
    let babyImage: UIImage?

    var body: some View {
        HStack(spacing: 20) {
            if let fruitImage {
                Image(uiImage: fruitImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
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

            Image(systemName: "arrow.right")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(isShowingAnimation ? Color(hex: "924350") : .secondary)
                .scaleEffect(isShowingAnimation ? 1.2 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 0.6)
                        .repeatCount(3, autoreverses: true),
                    value: isShowingAnimation
                )

            ZStack {
                Circle()
                    .fill(Color(hex: "E88683"))
                    .frame(width: 120, height: 120)

                if let babyImage {
                    Image(uiImage: babyImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 90, height: 90)
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
        VStack(alignment: .leading, spacing: 8) {
            // Header with icon and title
            HStack {
                // Icon
                if isEmoji {
                    Text(iconName)
                        .font(.system(size: 30))
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
            }
            
            // Preview text with ellipsis
            Text(previewText)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            // Tap indicator
            HStack {
                Spacer()
                
                Image(systemName: "chevron.right.circle")
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.6))
            }
            .padding(.top, 2)
        }
        .padding(12) // Reduced padding to save space
        .frame(maxWidth: .infinity)
        .frame(height: 120) // Fixed height to ensure no scrolling
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
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
