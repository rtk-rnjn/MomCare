import SwiftUI

struct PregnancyProgressView: View {
    // MARK: - Properties
    
    // Sample data - you'll inject these from your existing model
    var trimester: String
    var weekDay: String
    var babyHeight: String
    var babyWeight: String
    var babyInfo: String
    var momInfo: String
    var fruitComparisonName: String // e.g., "watermelon"
    
    // State for popup presentations
    @State private var showingBabyInfo = false
    @State private var showingMomInfo = false
    @State private var selectedCardPosition: CGRect = .zero
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 16) {
                // Week/trimester info (without its own card background)
                VStack(spacing: 2) {
                    Text(trimester)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text(weekDay)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "924350"))
                }
                
                // Content in cards with spacing
                VStack(spacing: 16) {
                    // Baby size comparison with visuals
                    sizeComparisonView
                    
                    // Growth stats cards
                    growthStatsView
                    
                    // Information cards
                    infoCardsView
                }
                .padding(.horizontal)
            }
            .overlay {
                // Popup info card
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
    }
    
    // MARK: - Component Views
    
    private var sizeComparisonView: some View {
        VStack(spacing: 12) {
            // Interactive size comparison
            ComparisonView(fruitName: fruitComparisonName)
            
            Text("I'm currently the size of a \(fruitComparisonName.lowercased())")
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
        VStack(spacing: 16) {
            // Baby info card
            InfoCardButton(
                title: "Baby Development",
                subtitle: "Your baby is fully developed and ready to meet you!",
                iconName: "baby.head",
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
            
            // Mom info card
            InfoCardButton(
                title: "Mom This Week",
                subtitle: "You've made it to the final week! Your body is preparing for labor...",
                iconName: "figure.dress.line.vertical.figure",
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
    let backgroundColor: Color
    let accentColor: Color
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .font(.system(size: 24))
                .foregroundColor(accentColor)
                .padding(.trailing, 4)
            
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

// Pop-up info card with envelope/message design
struct PopupInfoCard: View {
    let title: String
    let content: String
    @Binding var isShowing: Bool
    let cardPosition: CGRect 
    let accentColor: Color
    
    @State private var cardOffset = CGSize(width: 0, height: -50)
    @State private var opacity = 0.0
    @State private var scale = 0.8
    @State private var isContentVisible = false
    @State private var envelopeOpen = false
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all) // Cover the entire screen
                .opacity(opacity)
                .onTapGesture {
                    closeCard()
                }
            
            // Paper card
            VStack(spacing: 0) {
                // Cute envelope flap
                ZStack {
                    // Envelope flap
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 0))
                        path.addLine(to: CGPoint(x: UIScreen.main.bounds.width * 0.9, y: 0))
                        path.addLine(to: CGPoint(x: UIScreen.main.bounds.width * 0.45, y: envelopeOpen ? -20 : 40))
                        path.addLine(to: CGPoint(x: 0, y: 0))
                    }
                    .fill(Color(hex: "FBE8E5"))
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: -2)
                    
                    // Title on the envelope flap - fixed positioning
                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "924350"))
                        .offset(y: envelopeOpen ? 5 : 15) // Adjusted to be more visible
                }
                .frame(height: 60) // Increased height to give more space for the title
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: envelopeOpen)
                                
                // Content area with decorative elements
                VStack(spacing: 0) {                    
                    // Decorative top border
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
        // First hide the content
        withAnimation(.easeOut(duration: 0.2)) {
            isContentVisible = false
        }
        
        // Close the envelope
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                envelopeOpen = false
            }
            
            // Then dismiss the card
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    opacity = 0.0
                    scale = 0.8
                    cardOffset = CGSize(width: 0, height: -50)
                }
                
                // Finally set the state
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isShowing = false
                }
            }
        }
    }
}

struct ComparisonView: View {
    let fruitName: String
    @State private var isShowingAnimation = false
    @State private var wiggleAmount = false
    
    var body: some View {
        HStack(spacing: 20) {
            // Fruit image
            Image(fruitName.lowercased())
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
                    // Start gentle wiggle animation
                    wiggleAmount.toggle()
                }
            
            // Arrow that pulses when active
            Image(systemName: "arrow.right")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(isShowingAnimation ? Color(hex: "924350") : .secondary)
                .scaleEffect(isShowingAnimation ? 1.2 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 0.6)
                        .repeatCount(3, autoreverses: true),
                    value: isShowingAnimation
                )
            
            // Baby image
            ZStack {
                Circle()
                    .fill(Color(hex: "E88683"))
                    .frame(width: 120, height: 120)
                
                Image("baby_fetus")
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
        .contentShape(Rectangle())
        .onTapGesture {
            isShowingAnimation = true
            // Reset after animation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                isShowingAnimation = false
            }
        }
    }
}


// Preview provider with sample data
struct PregnancyProgressView_Previews: PreviewProvider {
    static var previews: some View {
        PregnancyProgressView(
            trimester: "Trimester 3",
            weekDay: "Week 40, Day 4",
            babyHeight: "51.2 cm",
            babyWeight: "3462.0 g",
            babyInfo: "You've reached the official due date though many babies arrive a little before or after. Your baby weighs about 7.5 to 8 pounds (3.4 to 3.6 kg) and is around 20.5 to 21 inches (52–53.3 cm) long — about the size of a small pumpkin. Most of the lanugo (fine body hair) is gone, and only a small amount of vernix may remain. Your baby's organs are fully developed, and the lungs are secreting surfactant to help with the transition to breathing air. The fingernails and toenails may now reach the fingertips. The skull bones are still soft and not yet fused to allow for flexibility during birth. While the baby is completely developed, the placenta is still supplying oxygen and nutrients.",
            momInfo: "You've made it to the final week! At this point, you might feel extremely impatient, uncomfortable, and ready to meet your baby. Your body is preparing for labor with potential signs like lightening (when the baby drops lower), more frequent Braxton Hicks contractions, mucus plug discharge, or diarrhea. You may notice more pressure on your pelvis and bladder but less pressure on your diaphragm, making breathing easier. Sleep might be difficult as finding a comfortable position becomes challenging. Stay hydrated, rest when possible, and continue gentle movement like walking to encourage labor.",
            fruitComparisonName: "Watermelon"
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
