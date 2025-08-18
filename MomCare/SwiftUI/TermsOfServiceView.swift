import SwiftUI

struct TermsOfServiceView: View {

    private let accentColor = Color(hex: "924350")

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(spacing: 16) {
                        ZStack{
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color(hex: "FFFFFF").opacity(0.12))
                                                            .frame(width: 60, height: 60)
                                                        Image(systemName: "text.page")
                                                            .font(.system(size: 60, weight: .bold))
                                                            .foregroundColor(accentColor)
                        }
                        
                        Text("Good rules create a space where everyone can feel safe and respected.")
                            .font(.system(size: 28, weight: .semibold, design: .default))
                                .tracking(-0.5)
                                .multilineTextAlignment(.center)
                                .lineSpacing(0)
                        
                        Text("Clarity is the foundation of trust. Our terms are designed to be clear, so our relationship can be strong.")
                            .font(.subheadline)
                                                    .foregroundColor(.primary)
                                                    .multilineTextAlignment(.center)
                                            }
                                            .padding(.top, 32)
                                            .padding(.bottom, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)

                    VStack(alignment: .leading, spacing: 24) {
                        
                        Divider()
                        LegalSectionView(
                            iconName: "checkmark.seal.fill",
                            title: "Acceptance of Terms",
                            content: "By downloading, installing, accessing, or using the MomCare mobile application and related services, you acknowledge that you have read, understood, and agreed to be bound by these Terms of Service and our Privacy Policy.\n\nIf you do not agree with these Terms, or any future updates to them, you must not access or use the App. Your continued use of the App after any changes or updates to these Terms constitutes your acceptance of those changes.",
                            accentColor: accentColor
                        )

                        Divider()

                        EligibilitySectionView(accentColor: accentColor)

                        Divider()
                        
                        OverviewOfServicesView(accentColor: accentColor)

                        Divider()

                        LegalSectionView(
                            iconName: "exclamationmark.triangle.fill",
                            title: "Disclaimers and Emergency Guidance",
                            content: "All content and features are for informational purposes only and are not a substitute for professional medical advice. In case of any medical emergency, immediately call your doctor or go to the nearest hospital. Use of the MomCare app is at your own discretion and risk.",
                            accentColor: accentColor
                        )

                        Divider()

                        LegalSectionView(
                            iconName: "person.fill.checkmark",
                            title: "User Responsibilities",
                            content: "You agree not to use the app in any unlawful manner, tamper with its functionalities, or submit misleading health data.",
                            accentColor: accentColor
                        )

                        Divider()

                        LegalSectionView(
                            iconName: "c.circle.fill",
                            title: "License and Intellectual Property",
                            content: "MomCare and all associated content, features, and branding are the exclusive intellectual property of MomCare and are protected by law. You are granted a limited, non-exclusive license for personal, non-commercial use only. You may not copy, modify, distribute, or reverse engineer any part of the app.",
                            accentColor: accentColor
                        )
                        
                        Divider()

                        LegalSectionView(
                            iconName: "lock.shield.fill",
                            title: "Data Consent & Privacy",
                            content: "By using our Services, you grant MomCare the right to collect, store, and process your data in accordance with our Privacy Policy. We use anonymized and aggregated data to improve our services and will never sell your personal data.",
                            accentColor: accentColor
                        )
                        
                        Divider()

//                        LegalSectionView(
//                            iconName: "puzzlepiece.extension.fill",
//                            title: "Third-Party Services",
//                            content: "To deliver a rich experience, MomCare integrates with third-party services like Apple's HealthKit and Generative AI for smart recommendations. Use of these features is subject to their respective policies. We do not share your data with third parties for marketing purposes.",
//                            accentColor: accentColor
//                        )
                        ThirdPartyServicesView(accentColor: accentColor)
                        
                        Divider()
                        
                        LegalSectionView(
                            iconName: "creditcard.fill",
                            title: "Subscriptions",
                            content: "Some advanced features may require a subscription. Payments are processed via the App Store, and you can manage or cancel your subscription in your account settings.",
                            accentColor: accentColor
                        )
                        
                        Divider()

                        LegalSectionView(
                            iconName: "hand.raised.slash.fill",
                            title: "Limitation of Liability",
                            content: "MomCare provides the app “as-is” without warranties. We are not liable for any indirect damages from your use of the app and do not guarantee it will be error-free.",
                            accentColor: accentColor
                        )
                        
                        Divider()

                        LegalSectionView(
                            iconName: "building.columns.fill",
                            title: "Governing Law",
                            content: "These terms are governed by the laws of India. Any disputes shall be resolved in the courts of Gautam Budh Nagar.",
                            accentColor: accentColor
                        )
                        
                        Divider()

                        LegalSectionView(
                            iconName: "envelope.fill",
                            title: "Contact Us",
                            content: "For questions or feedback, please contact us at:\n**Email:** support@momcare.com\n**Website:** www.momcare.com",
                            accentColor: accentColor
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .background(Color(.systemGroupedBackground))
        }
    }

struct LegalSectionView: View {
    let iconName: String
    let title: String
    let content: String
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(accentColor)
                    .frame(width: 24, alignment: .center)
                
                Text(title)
                    .font(.title3.weight(.semibold))
            }
            
            Text(.init(content))
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineSpacing(4)
        }
    }
}

struct EligibilitySectionView: View {
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "person.crop.circle.badge.checkmark")
                    .font(.title2)
                    .foregroundColor(accentColor)
                    .frame(width: 24, alignment: .center)
                Text("Eligibility – Who Can Use MomCare")
                    .font(.title3.weight(.semibold))
            }
            
            VStack(alignment: .leading, spacing: 10) {
                BulletPoint(text: "You must be **at least 18 years old** or the legal age of majority in your country.")
                BulletPoint(text: "You must be **pregnant**, planning a pregnancy, or a caregiver/support person.")
                BulletPoint(text: "You must **agree to and comply** with these Terms of Service and our Privacy Policy.")
            }
            
            Text("The MomCare app is **not intended for use by children**, nor is it a tool for professional medical personnel to manage patient records.")
                .font(.subheadline)
                .foregroundColor(.primary)
                .padding(.top, 8)
        }
    }
}

struct OverviewOfServicesView: View {
    let accentColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundColor(accentColor)
                    .frame(width: 24, alignment: .center)
                Text("Overview of Services")
                    .font(.title3.weight(.semibold))
            }
            
            Text("MomCare offers a range of tools designed to enhance your pregnancy journey:")
                .font(.subheadline)
                .foregroundColor(.primary)

            VStack(alignment: .leading, spacing: 12) {
                ServiceDetail(title: "ProgressHub", description: "A comprehensive summary of your daily/weekly exercise and diet progress, with daily insights and tips.")
                ServiceDetail(title: "MyPlan", description: "Personalized daily recommendations for diet and exercise based on your health input.")
                ServiceDetail(title: "TriTrack", description: "A “Me & Baby” view, highlighting your stage of pregnancy with size comparisons and week-by-week summaries.")
                ServiceDetail(title: "MoodNest", description: "A mood-based audio experience with tunes tailored to your emotional state.")
            }
        }
    }
}

// --- Helper View: ServiceDetail ---
struct ServiceDetail: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            Text(description)
                .foregroundColor(.primary)
        }
    }
}

struct ThirdPartyServicesView: View {
    let accentColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Main Header
            HStack(spacing: 12) {
                Image(systemName: "puzzlepiece.extension.fill")
                    .font(.title2)
                    .foregroundColor(accentColor)
                    .frame(width: 24, alignment: .center)
                Text("Third-Party Services and Frameworks")
                    .font(.title3.weight(.semibold))
            }
            
            // Introductory Paragraph
            Text("To deliver a personalized and feature-rich experience, MomCare integrates with a number of third-party services, frameworks, and APIs. These services may handle or process certain types of data to enable app functionality.")
                .font(.subheadline)
                .foregroundColor(.primary)
            
            // Apple Frameworks Subsection
            VStack(alignment: .leading, spacing: 12) {
                Text("Apple Frameworks & Services")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.top, 8)
                
                ServiceBulletPoint(title: "HealthKit", description: "To collect and analyze health data such as activity, steps, and other metrics, if access is granted by the user.")
                ServiceBulletPoint(title: "EventKit", description: "To allow appointment logging, calendar integration, and management of pregnancy-related reminders and events.")
                ServiceBulletPoint(title: "UserNotifications", description: "For delivering local notifications about reminders, tips, hydration alerts, exercise tracking, and more.")
                ServiceBulletPoint(title: "AVFoundation & MediaPlayer", description: "To power audio playback features in MoodNest, including mood-specific calming soundtracks.")
            }
            
            // AI Services Subsection
            VStack(alignment: .leading, spacing: 12) {
                Text("AI Services")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.top, 8)
                
                ServiceBulletPoint(title: "Generative AI (GenAI)", description: "Utilized for powering certain smart recommendations, personalized wellness suggestions, or adaptive daily tips. All outputs are generated in response to user-provided context and inputs.")
            }
            
            // Concluding Paragraphs
            VStack(alignment: .leading, spacing: 10) {
                 Text("Use of these services is subject to their respective privacy policies and terms of use. By using MomCare, you acknowledge and consent to the processing of relevant data by these services, solely for the purposes of enhancing your experience and delivering the app’s features.")
                 Text("We do not share or sell your data to third parties for advertising or marketing purposes.")
            }
            .font(.subheadline)
            .foregroundColor(.primary)
            .padding(.top, 8)
        }
    }
}

struct ServiceBulletPoint: View {
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.subheadline)
            
            VStack(alignment: .leading) {
                Text(.init("**\(title)** – \(description)"))
            }
        }
        .font(.subheadline)
        .foregroundColor(.primary)
    }
}

// --- Helper View: BulletPoint ---
struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
            Text(.init(text))
        }
        .font(.subheadline)
        .foregroundColor(.primary)
    }
}




// --- Xcode Preview ---
struct TermsOfServiceView_Previews: PreviewProvider {
    static var previews: some View {
        TermsOfServiceView()
    }
}
