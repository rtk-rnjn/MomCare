import Foundation

struct DisclaimerItem: Identifiable {
    let id: UUID = .init()
    let icon: String
    let title: String
    let content: String
    var source: String?
}

enum DisclaimerData {
    public static let allDisclaimers: [DisclaimerItem] = [
        DisclaimerItem(
            icon: "stethoscope",
            title: "1. General Medical Disclaimer",
            content: """
            This application is not a substitute for professional medical advice, diagnosis, or treatment.
            The content provided in MomCare+, including all text, graphics, images, and other material, is for informational and educational purposes only. It is not intended to be a substitute for professional medical advice from your doctor, midwife, or other qualified healthcare provider.
            Always seek the advice of your physician or another qualified health professional with any questions you may have regarding a medical condition or your pregnancy. Never disregard professional medical advice or delay in seeking it because of something you have read in this application. If you think you may have a medical emergency, call your doctor or emergency services immediately.
            """,
            source: nil
        ),
        DisclaimerItem(
            icon: "lightbulb",
            title: "2. Daily Tips",
            content: "DISCLAIMER: The daily tips provided on the dashboard are intended as general guidance and for informational purposes. While we strive to provide accurate and useful information, we make no representation or warranty of any kind regarding the accuracy, validity, or completeness of these tips.",
            source: nil
        ),
        DisclaimerItem(
            icon: "fork.knife",
            title: "3. Personalized Meal Plans",
            content: """
            DISCLAIMER: The meal plans provided in this app are personalized based on the health conditions, allergies, and dietary preferences that you provide. We use this information to generate meal suggestions that are tailored to your stated needs.
            However, this automated plan is not a substitute for a direct, one-on-one consultation with a registered dietitian or your healthcare provider. A medical professional can perform a comprehensive assessment that an app cannot. It is your responsibility to ensure that all information you enter into the app is accurate and complete. MomCare+ is not liable for any adverse outcomes resulting from the meal plans, including those that may arise from inaccurate or incomplete self-reported data.
            """,
            source: "CITATION: The nutritional data and meal plan structures are based on the dataset provided by [Kaggle](https://www.kaggle.com/datasets/sayyamsancheti/indian-state-wise-meals-with-nutritional-values)."
        ),
        DisclaimerItem(
            icon: "figure.walk",
            title: "4. Exercise & Yoga Plans",
            content: """
            DISCLAIMER: The exercise and yoga videos in this app have been carefully curated to be generally safe and appropriate for the specific week of pregnancy you are in. We have taken care to select gentle, low-impact routines that are beneficial for most expectant mothers.
            However, every pregnancy is unique. Your individual health status, fitness level, or specific medical conditions (like placenta previa or high-risk status) may require modifications or mean that certain exercises should be avoided. It remains essential to consult with your doctor or a qualified prenatal fitness instructor before beginning this or any exercise regimen. They can provide guidance tailored to your body. Listen to your body and stop immediately if you feel pain, dizziness, or discomfort. By participating in these exercises, you agree that you are doing so at your own risk and release MomCare+ from any and all claims or liabilities for any injury or harm you might sustain.
            """,
            source: "CITATION: The yoga and exercise video content is provided courtesy of [Pexels.com](https://www.pexels.com/search/videos/pregnancy%20yogas/)."
                    ),
        DisclaimerItem(
            icon: "chart.line.uptrend.xyaxis",
            title: "5. Baby Growth and Development Tracker",
            content: """
            DISCLAIMER: The week-by-week baby size comparisons (e.g., "the size of an apple") are illustrative approximations meant to provide a fun and relatable way to visualize your baby's growth. Fetal development is unique to each pregnancy and can be influenced by various factors, including genetics, ethnicity, and maternal health. The data used in this app is based on general averages and may not perfectly reflect your baby's individual development. These comparisons are not a medical tool and should not be used for diagnostic purposes. For accurate information about your baby's growth, please rely on the ultrasound measurements and assessments provided by your healthcare professional.
            """,
            source: "CITATION: Icons are used from [Icons8](https://icons8.com/)."
                    ),
        DisclaimerItem(
            icon: "book",
            title: "6. Pregnancy Articles",
            content: """
            Disclaimer: To provide you with reliable and helpful information, we have made a significant effort to carefully select and aggregate articles from highly reputable sources, including government health organizations, international maternal health forums, and leading medical publications. Our goal is to bring you trusted educational content to help you prepare for your pregnancy journey.
            However, while we select sources known for their high standards of accuracy, MomCare+ does not independently verify every single fact within these articles and cannot guarantee its absolute accuracy or timeliness. This content is presented for educational purposes and does not necessarily reflect the views of MomCare+. As with all content in this app, this information is not a substitute for direct, professional medical advice from your healthcare provider.
            """,
            source: """
                        CITATION:
                        • [American College of Obstetricians and Gynecologists](https://www.acog.org/womens-health/patient-education)
                        • [BabyCenter](https://www.babycenter.com/pregnancy-week-by-week)
                        • [What to Expect](https://www.whattoexpect.com/pregnancy/week-by-week/)
                        • [WomensHealth.gov](https://www.womenshealth.gov/pregnancy/)
                        """
                    ),

        DisclaimerItem(
            icon: "face.smiling",
            title: "7. Mood Tracking and Music Suggestions",
            content: """
            DISCLAIMER: We understand that pregnancy is an emotional journey. The mood tracking feature is designed to help you maintain your emotional well-being. Based on the mood you log, our system suggests music that has been thoughtfully categorized and selected in an effort to provide comfort, calm, or upliftment.
            It is crucial to understand that this is an automated wellness feature intended for comfort and entertainment only. It is not a diagnostic tool and does not provide medical or psychological therapy. This feature cannot detect or treat conditions such as prenatal or postpartum depression or anxiety. If you are experiencing persistent low moods, anxiety, or have concerns about your mental health, it is essential that you speak with your healthcare provider or a mental health professional. Your well-being is the top priority, and professional care is the correct and necessary step.
            """,
            source: "CITATION: Images and Tunes are taken from [Free To Use](https://freetouse.com)."
                    )
    ]
}

enum LegalSectionType {
    case standard(icon: String, title: String, content: String)
    case eligibility
    case overview
    case thirdParty
}

struct LegalSectionItem: Identifiable {
    let id: UUID = .init()
    let type: LegalSectionType
}

enum TermsData {
    static let allSections: [LegalSectionItem] = [
        LegalSectionItem(type: .standard(
            icon: "checkmark.seal.fill",
            title: "Acceptance of Terms",
            content: "By downloading, installing, accessing, or using the MomCare mobile application and related services, you acknowledge that you have read, understood, and agreed to be bound by these Terms of Service and our Privacy Policy.\n\nIf you do not agree with these Terms, or any future updates to them, you must not access or use the App. Your continued use of the App after any changes or updates to these Terms constitutes your acceptance of those changes."
        )),
        LegalSectionItem(type: .eligibility),
        LegalSectionItem(type: .overview),
        LegalSectionItem(type: .standard(
            icon: "exclamationmark.triangle.fill",
            title: "Disclaimers and Emergency Guidance",
            content: "All content and features are for informational purposes only and are not a substitute for professional medical advice. In case of any medical emergency, immediately call your doctor or go to the nearest hospital. Use of the MomCare app is at your own discretion and risk."
        )),
        LegalSectionItem(type: .standard(
            icon: "person.fill.checkmark",
            title: "User Responsibilities",
            content: "You agree not to use the app in any unlawful manner, tamper with its functionalities, or submit misleading health data."
        )),
        LegalSectionItem(type: .standard(
            icon: "c.circle.fill",
            title: "License and Intellectual Property",
            content: "MomCare and all associated content, features, and branding are the exclusive intellectual property of MomCare and are protected by law. You are granted a limited, non-exclusive license for personal, non-commercial use only. You may not copy, modify, distribute, or reverse engineer any part of the app."
        )),
        LegalSectionItem(type: .standard(
            icon: "lock.shield.fill",
            title: "Data Consent & Privacy",
            content: "By using our Services, you grant MomCare the right to collect, store, and process your data in accordance with our Privacy Policy. We use anonymized and aggregated data to improve our services and will never sell your personal data."
        )),
        LegalSectionItem(type: .thirdParty),
        LegalSectionItem(type: .standard(
            icon: "creditcard.fill",
            title: "Subscriptions",
            content: "Some advanced features may require a subscription. Payments are processed via the App Store, and you can manage or cancel your subscription in your account settings."
        )),
        LegalSectionItem(type: .standard(
            icon: "hand.raised.fill",
            title: "Limitation of Liability",
            content: "MomCare provides the app “as-is” without warranties. We are not liable for indirect damages from your use of the app and do not guarantee it will be error-free."
        )),
        LegalSectionItem(type: .standard(
            icon: "building.columns.fill",
            title: "Governing Law",
            content: "These terms are governed by the laws of India. Any disputes shall be resolved in the courts of Gautam Budh Nagar."
        )),
        LegalSectionItem(type: .standard(
            icon: "envelope.fill",
            title: "Contact Us",
            content: "For questions or feedback, please contact us at:\n**Email:** support@ourdomain\n**Website:** "
        ))
    ]
}

struct GDPRRightItem: Identifiable {
    let id: UUID = .init()
    let iconName: String
    let title: String
    let description: String
}

enum GDPRData {
    static let allRights: [GDPRRightItem] = [
        GDPRRightItem(
            iconName: "person.text.rectangle.fill",
            title: "The Right to Access",
            description: "You have the right to request a copy of the personal data we hold about you."
        ),
        GDPRRightItem(
            iconName: "pencil.circle.fill",
            title: "The Right to Rectification",
            description: "If you believe any of the data we hold about you is inaccurate or incomplete, you have the right to have it corrected."
        ),
        GDPRRightItem(
            iconName: "trash.fill",
            title: "The Right to Erasure",
            description: "You can request that we delete your personal data from our systems. This is also known as the 'Right to be Forgotten'."
        ),
        GDPRRightItem(
            iconName: "pause.circle.fill",
            title: "The Right to Restrict Processing",
            description: "You have the right to request that we temporarily or permanently stop processing all or some of your personal data."
        ),
        GDPRRightItem(
            iconName: "arrow.down.doc.fill",
            title: "The Right to Data Portability",
            description: "You can request a copy of your personal data in a common, machine-readable format to transfer to another service."
        ),
        GDPRRightItem(
            iconName: "speaker.slash.fill",
            title: "The Right to Object",
            description: "You have the right to object to us processing your personal data for specific purposes, such as direct marketing."
        )
    ]
}

struct TeamMember: Identifiable {
    let id: UUID = .init()
    let imageName: String?
    let name: String
    let role: String
}

struct Credit: Identifiable {
    let id: UUID = .init()
    let name: String
    let description: String
}

enum CreditsData {
    static let teamMembers: [TeamMember] = [
        .init(imageName: nil, name: "Aryan Singh", role: "Team Lead, UI/UX & Ideation"),
        .init(imageName: nil, name: "Khushi Rana", role: "Frontend & Research"),
        .init(imageName: nil, name: "Nupur Sharma", role: "Frontend & Research"),
        .init(imageName: nil, name: "Ritik Ranjan", role: "Frontend/Backend Developer")
    ]

    static let mentors: [Credit] = [
        .init(name: "Vinod Kumar", description: "For his dedicated guidance."),
        .init(name: "Valuable Feedback From", description: "Kiran Singh, Probeer Shaw, Runumi Devi and Shruti Sachdeva.")
    ]

    static let specialThanks: [Credit] = [
        .init(name: "Anand Pillai · Apple", description: "For expert insights."),
        .init(name: "Prasad BS · Infosys", description: "For feedback on UI and business aspects.")
    ]
}

struct LicenseInfo: Identifiable {
    let id: UUID = .init()
    let name: String
    let license: String
    let urlString: String
}

enum LicenseData {
    static let appLicense: [LicenseInfo] = [
        .init(
            name: "MomCare+",
            license: "GNU General Public License v2.0",
            urlString: "https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html"
        )
    ]

    static let projectReport: [LicenseInfo] = [
        .init(
            name: "MomCare+ Project Report",
            license: "View project documentation",
            urlString: "https://github.com/rtk-rnjn/MomCare"
        )
    ]

    static let thirdPartyLicenses: [LicenseInfo] = [
        .init(
            name: "LNPopupController",
            license: "MIT License",
            urlString: "https://github.com/LeoNatan/LNPopupController"
        ),
        .init(
            name: "FSCalendar",
            license: "MIT License",
            urlString: "https://github.com/WenchaoD/FSCalendar"
        ),
        .init(
            name: "Realm Swift",
            license: "Apache License 2.0",
            urlString: "https://github.com/realm/realm-swift"
        )
    ]
}
