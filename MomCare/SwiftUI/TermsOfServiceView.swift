import SwiftUI

struct TermsOfServiceView: View {
    let accentColor = Color(hex: "924350")
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    ZStack{
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(hex: "FFFFFF").opacity(0.12))
                            .frame(width: 60, height: 60)
                        Image(systemName: "lock.shield")
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
                
                Divider()
                
                // --- Section 1: Acceptance of Terms ---
                LegalSectionView(
                    iconName: "checkmark.seal.fill",
                    title: "Acceptance of Terms",
                    content: """
                    By downloading, installing, accessing, or using the MomCare mobile application and related services, you acknowledge that you have read, understood, and agreed to be bound by these Terms of Service and our Privacy Policy.
                    If you do not agree with these Terms, or any future updates to them, you must not access or use the App.Your continued use of the App after any changes or updates to these Terms constitutes your acceptance of those changes. It is your responsibility to review these Terms periodically. 
                    If you are accepting these Terms on behalf of another person (such as a partner or caregiver supporting a pregnant user), you confirm that you have the legal authority to do so.
""",
                    accentColor: accentColor
                )
                
                Divider()
                
                // --- Section 2: Eligibility ---
                EligibilitySectionView()
                
                Divider()
                
//                 --- Section 3: Description of Service ---
                OverviewOfServicesView()
                
                Divider()
                
                // --- Section 4: Disclaimers and Emergency Guidance ---
                LegalSectionView(
                    iconName: "exclamationmark.triangle.fill",
                    title: "Disclaimers and Emergency Guidance",
                    content: """
All content, recommendations, and features (including personalized plans, reminders, insights, and wellness tips) are provided for informational and wellness support purposes only. They are not intended to replace consultation with qualified healthcare professionals.
Always consult your doctor, gynecologist, or other qualified medical provider before making decisions related to your pregnancy, diet, physical activity, medications, or symptoms.
In case of any medical emergency — such as bleeding, severe abdominal pain, dizziness, reduced fetal movement, or any symptoms causing concern — immediately call your doctor, emergency medical services, or go to the nearest hospital. Do not rely on this app to detect or manage emergencies.
Use of the MomCare app is at your own discretion and risk. You are solely responsible for your health decisions and outcomes based on the app’s content or recommendations.
""",
                    accentColor: accentColor
                )
                
                
                Divider()
                
                // --- Section 5: User Responsibilities ---
                LegalSectionView(
                    iconName: "person.fill.checkmark",
                    title: "User Responsibilities",
                    content: """
                    You agree not to:
                       - Use the app in any unlawful or harmful manner.
                       - Tamper with or reverse engineer app functionalities.
                       - Submit misleading or false health-related data.
                       - Your use of the app is at your own discretion and risk.
""",
                    accentColor: accentColor
                )
                
                Divider()
                
                // --- Section 6: License and Intellectual Property ---
                LegalSectionView(
                    iconName: "c.circle.fill",
                    title: "License and Intellectual Property",
                    content: """
MomCare and all associated content, features, and branding are protected by intellectual property laws. This includes, but is not limited to:
The app design, interface, and layouts
All features and modules (e.g., ProgressHub™, MyPlan™, TriTrack™, MoodNest™)
Custom algorithms, logic flows, and personalized systems
Our logo, color palette, illustrations, and brand identity
All original text, icons, animations, and multimedia elements
These are the exclusive intellectual property of MomCare (or its parent company, if applicable) and are protected under applicable copyright, trademark, and design laws.
Usage Restrictions
You are granted a limited, non-exclusive, non-transferable license to use the App for personal, non-commercial purposes, in accordance with these Terms.
You may not:
Copy, modify, distribute, sell, or lease any part of the app or its content
Reverse engineer, extract, or tamper with any source code, algorithms, or backend structure
Use our trademarks, branding, or design elements without our prior written permission
Unauthorized use of our intellectual property is strictly prohibited and may result in legal action.
""",
                    accentColor: accentColor
                )
                
                Divider()
                
                // --- Section 7: Data Consent and Privacy ---
                LegalSectionView(
                    iconName: "lock.shield.fill",
                    title: "Data Consent & Privacy",
                    content: """
By using our Services, you grant MomCare the right to collect, store, and process your data in accordance with our [Privacy Policy]. This includes using anonymized and aggregated data to improve our algorithms, personalize your experience, and enhance our app features.
We do not sell your personal data, and we use it only for the purposes clearly outlined in our Privacy Policy.
""",
                    accentColor: accentColor
                )
                
                Divider()
                
                // --- Section 8: Third-Party Services ---
                LegalSectionView(
                    iconName: "puzzlepiece.extension.fill",
                    title: "Third-Party Services",
                        content:
                        """
                    To deliver a personalized and feature-rich experience, MomCare integrates with a number of third-party services, frameworks, and APIs. These services may handle or process certain types of data to enable app functionality. The following third-party technologies are currently used:
                    Apple Frameworks & Services
                    HealthKit – To collect and analyze health data such as activity, steps, and other metrics, if access is granted by the user.
                    EventKit – To allow appointment logging, calendar integration, and management of pregnancy-related reminders and events.
                    UserNotifications – For delivering local notifications about reminders, tips, hydration alerts, exercise tracking, and more.
                    AVFoundation & MediaPlayer – To power audio playback features in MoodNest, including mood-specific calming soundtracks.
                    AI Services
                    Generative AI (GenAI) – Utilized for powering certain smart recommendations, personalized wellness suggestions, or adaptive daily tips. All outputs are generated in response to user-provided context and inputs.

                    Use of these services is subject to their respective privacy policies and terms of use. By using MomCare, you acknowledge and consent to the processing of relevant data by these services, solely for the purposes of enhancing your experience and delivering the app’s features.
                    We do not share or sell your data to third parties for advertising or marketing purposes.
""",
                    accentColor: accentColor
                )
                
                Divider()
                
                // --- Section 9: Subscriptions ---
                LegalSectionView(
                    iconName: "creditcard.fill",
                    title: "Subscriptions",
                    content: """
Some advanced features may be available through a subscription or one-time payment:
Subscription details, pricing, and renewal terms will be clearly disclosed.
Payments are processed via the App Store or Google Play and are subject to their terms.
You can manage or cancel your subscription anytime through your app store account settings.
""",
                    accentColor: accentColor
                )
                
                Divider()
                
                // --- Section 10: Limitation of Liability ---
                LegalSectionView(
                    iconName: "hand.raised.slash.fill",
                    title: "Limitation of Liability",
                    content: """
                    To the extent permitted by law:
                    MomCare provides the app “as-is” without warranties of any kind.
                    We are not liable for any indirect, incidental, or consequential damages arising from your use of the app.
                    We do not guarantee the app will be error-free or continuously available.
""",
                    accentColor: accentColor
                )
                
                Divider()
                
                // --- Section 11: Governing Law ---
                LegalSectionView(
                    iconName: "globe.asia.australia.fill",
                    title: "Governing Law",
                    content: "These terms are governed by the laws of India. Any disputes shall be resolved in the courts of Gautam Budh Nagar.",
                    accentColor: accentColor
                )
                
                Divider()
                
                // --- Section 12: Contact Us ---
                LegalSectionView(
                    iconName: "envelope.fill",
                    title: "Contact Us",
                    content: "For any questions or feedback, please contact us at: \nEmail: support@momcare.com\nWebsite: www.momcare.com",
                    accentColor: accentColor
                )
                
                .padding(.horizontal, 30)
                .padding(.bottom, 16)
            }
            .padding(.horizontal, 30)
        }
        .background(Color(.systemBackground))
    }
}

// Reusable view for each legal section
struct LegalSectionView: View {
    let iconName: String
    let title: String
    let content: String
    let accentColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(accentColor)
                    .frame(width: 24, alignment: .leading)
                
                Text(title)
                    .font(.title3.weight(.semibold))
            }
            
            Text(.init(content))
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)
            
        }
    }
}

struct EligibilitySectionView: View {
    let accentColor = Color(hex: "924350")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "person.crop.circle.badge.checkmark")
                    .font(.title2)
                    .foregroundColor(accentColor)
                    .frame(width: 24, alignment: .leading)
                
                Text("Eligibility – Who Can Use MomCare")
                    .font(.title3.weight(.semibold))
            }
            
            Text("To use the MomCare app and its services, you must meet the following criteria:")
                .font(.body)
            
            VStack(alignment: .leading, spacing: 12) {
                // Bullet 1
                HStack(alignment: .top) {
                    Text("•")
                    Text("You must be ")
                        + Text("at least 18 years old").bold()
                        + Text(" or the legal age of majority in your country or state of residence.")
                }
                
                // Bullet 2 with sub-bullets
                HStack(alignment: .top) {
                    Text("•")
                    VStack(alignment: .leading, spacing: 6) {
                        Text("You must be:")
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(alignment: .top) {
                                Text("◦")
                                Text("Pregnant").bold() + Text(" or planning to become pregnant,")
                            }
                            HStack(alignment: .top) {
                                Text("◦")
                                Text("A ").bold() + Text("caregiver, partner, or support person").bold() + Text(" for someone who is pregnant,")
                            }
                            HStack(alignment: .top) {
                                Text("◦")
                                Text("Or a user seeking to understand and support the prenatal journey for educational or wellness purposes.")
                            }
                        }
                    }
                }
                
                // Bullet 3
                HStack(alignment: .top) {
                    Text("•")
                    Text("You must ")
                        + Text("agree to and comply with").bold()
                        + Text(" these Terms of Service and our Privacy Policy.")
                }
                
                // Bullet 4
                HStack(alignment: .top) {
                    Text("•")
                    Text("You must ")
                        + Text("not use the app for commercial, clinical, or diagnostic purposes").bold()
                        + Text(", unless explicitly ")
                        + Text("authorized").bold()
                        + Text(" by us in writing.")
                }
            }
            
            Text("The MomCare app is ")
                + Text("not intended for use by children").bold()
                + Text(", nor is it a tool for professional medical personnel to manage patient records or diagnostics.")
                .font(.body)

            
            Text("We reserve the right to deny access, suspend, or terminate accounts if we believe a user is misusing the app, falsifying information, or violating these eligibility requirements.")
                .font(.body)
                .padding(.top, 8)
        }
        .padding(.horizontal, 12)
    }
}

import SwiftUI

struct OverviewOfServicesView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Overview of Services")
                    .font(.title2.bold())
                    .padding(.bottom, 4)
                
                Text("MomCare offers a range of pregnancy wellness and self-care tools designed to enhance your experience during this important journey. Our Services include:")
                    .font(.body)
                
                // ProgressHub Section
                Text("ProgressHub")
                    .font(.title3.bold())
                    .padding(.top, 8)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        Text("•")
                        Text(.init("Displays a **comprehensive summary** of your daily and weekly **exercise and diet progress**."))
                    }
                    HStack(alignment: .top) {
                        Text("•")
                        Text(.init("Provides **daily insights** like _“Today’s Focus”_, curated **Daily Tips**, and your current **trimester, week, and day**."))
                    }
                    HStack(alignment: .top) {
                        Text("•")
                        Text(.init("Shows **upcoming appointments** and helps you stay **organized** with reminders."))
                    }
                }
                
                // MyPlan Section
                Text("MyPlan")
                    .font(.title3.bold())
                    .padding(.top, 8)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        Text("•")
                        Text(.init("Delivers **personalized daily recommendations** for diet and exercise based on your input regarding **allergies, medical conditions,** and **dietary preferences**."))
                    }
                    HStack(alignment: .top) {
                        Text("•")
                        Text(.init("Tracks **diet adherence, weekly exercise goals**, and provides tools like **guided breathing exercises**, stretching routines, and more."))
                    }
                }
                
                // TriTrack Section
                Text("TriTrack")
                    .font(.title3.bold())
                    .padding(.top, 8)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        Text("•")
                        Text(.init("Offers a _“Me & Baby” view_, highlighting the current **stage of pregnancy**, along with baby’s **estimated height, weight**, and a relatable **fruit size comparison**."))
                    }
                    HStack(alignment: .top) {
                        Text("•")
                        Text(.init("Includes detailed, trimester-specific content: _“Baby This Week”_ and _“Mom This Week”_, **summarizing** what’s happening during each stage."))
                    }
                    HStack(alignment: .top) {
                        Text("•")
                        Text(.init("Allows users to **log appointments**, set **reminders**, and track **symptoms** to facilitate informed medical consultations."))
                    }
                }
                
                // MoodNest Section
                Text("MoodNest")
                    .font(.title3.bold())
                    .padding(.top, 8)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        Text("•")
                        Text(.init("Features a **mood-based audio experience with tunes tailored** to emotional states such as happy, sad, angry, or stressed."))
                    }
                    HStack(alignment: .top) {
                        Text("•")
                        Text(.init("Designed with a **cheerful, comforting UI** to help support your emotional well-being and bring moments of calm throughout your day."))
                    }
                }
            }
            .padding(.horizontal, 12)
        }
    }
}

// Xcode preview
struct TermsOfServiceView_Previews: PreviewProvider {
    static var previews: some View {
        TermsOfServiceView()
    }
}
