import SwiftUI

struct DisclaimersView: View {
    let accentColor = Color(hex: "924350")
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Main Header
                VStack(spacing: 16) {
                    ZStack{
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(hex: "FFFFFF").opacity(0.12))
                                                        .frame(width: 60, height: 60)
                                                    Image(systemName: "exclamationmark.shield")
                                                        .font(.system(size: 60, weight: .bold))
                                                        .foregroundColor(accentColor)
                    }
                    Text("Important Information")
                                                .font(.title.bold())
                                                .multilineTextAlignment(.center)
                    
                    Text("Your safety and understanding are important to us. Please review the information below before using MomCare+.")
                                                .font(.body)
                                                .foregroundColor(.primary)
                                                .multilineTextAlignment(.center)
                                        }
                                        .padding(.top, 32)
                                        .padding(.bottom, 8)
                
                Divider()
                
                // Section 1: General Medical Disclaimer
                DisclaimerSection(
                    icon: "stethoscope",
                    title: "1. General Medical Disclaimer",
                    content: """
                    This application is not a substitute for professional medical advice, diagnosis, or treatment.
                    The content provided in MomCare+, including all text, graphics, images, and other material, is for informational and educational purposes only. It is not intended to be a substitute for professional medical advice from your doctor, midwife, or other qualified healthcare provider.
                    Always seek the advice of your physician or another qualified health professional with any questions you may have regarding a medical condition or your pregnancy. Never disregard professional medical advice or delay in seeking it because of something you have read in this application. If you think you may have a medical emergency, call your doctor or emergency services immediately.
                    """,
                    source: nil,
                    accentColor: accentColor
                )
                
                Divider()
                
                // Section 2: Daily Tips
                DisclaimerSection(
                    icon: "lightbulb",
                    title: "2. Daily Tips",
                    content: """
                    DISCLAIMER: The daily tips provided on the dashboard are intended as general guidance and for informational purposes. While we strive to provide accurate and useful information, we make no representation or warranty of any kind regarding the accuracy, validity, or completeness of these tips. Following any tip is done at your own risk.
                    """,
                    source: nil,
                    accentColor: accentColor
                )
                
                Divider()
                
                // Section 3: Meal Plans
                DisclaimerSection(
                    icon: "fork.knife",
                    title: "3. Personalized Meal Plans",
                    content: """
                    DISCLAIMER: The meal plans provided in this app are personalized based on the health conditions, allergies, and dietary preferences that you provide. We use this information to generate meal suggestions that are tailored to your stated needs.
                    However, this automated plan is not a substitute for a direct, one-on-one consultation with a registered dietitian or your healthcare provider. A medical professional can perform a comprehensive assessment that an app cannot. It is your responsibility to ensure that all information you enter into the app is accurate and complete. Before following the meal plan, we strongly recommend you review it with your doctor to confirm it is appropriate for your specific health situation. MomCare+ is not liable for any adverse outcomes resulting from the meal plans, including those that may arise from inaccurate or incomplete self-reported data.
                    """,
                    source: "CITATION: The nutritional data and meal plan structures are based on the dataset provided by [Name of the Dataset Source, e.g., The USDA FoodData Central, or Name of the specific research paper/organization] which can be accessed here: [Link to the dataset or source website].",
                    accentColor: accentColor
                )
                
                Divider()
                
                // Section 4: Exercise & Yoga
                DisclaimerSection(
                    icon: "figure.walk",
                    title: "4. Exercise & Yoga Plans",
                    content: """
                    DISCLAIMER: The exercise and yoga videos in this app have been carefully curated to be generally safe and appropriate for the specific week of pregnancy you are in. We have taken care to select gentle, low-impact routines that are beneficial for most expectant mothers.
                    However, every pregnancy is unique. Your individual health status, fitness level, or specific medical conditions (like placenta previa or high-risk status) may require modifications or mean that certain exercises should be avoided. It remains essential to consult with your doctor or a qualified prenatal fitness instructor before beginning this or any exercise regimen. They can provide guidance tailored to your body. Listen to your body and stop immediately if you feel pain, dizziness, or discomfort. By participating in these exercises, you agree that you are doing so at your own risk and release MomCare+ from any and all claims or liabilities for any injury or harm you might sustain.
                    """,
                    source: "CITATION: The yoga and exercise video content is provided courtesy of Pexels.com. You can find more of their work at: https://www.pexels.com/search/videos/pregnancy%20yogas/.",
                    accentColor: accentColor
                )
                
                Divider()
                
                // Section 5: Baby Growth Tracker
                DisclaimerSection(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "5. Baby Growth and Development Tracker",
                    content: """
                    DISCLAIMER: The week-by-week baby size comparisons (e.g., "the size of an apple") are illustrative approximations meant to provide a fun and relatable way to visualize your baby's growth. Fetal development is unique to each pregnancy and can be influenced by various factors, including genetics, ethnicity, and maternal health. The data used in this app is based on general averages and may not perfectly reflect your baby's individual development. These comparisons are not a medical tool and should not be used for diagnostic purposes. For accurate information about your baby's growth, please rely on the ultrasound measurements and assessments provided by your healthcare professional.
                    """,
                    source: "CITATION: ",
                    accentColor: accentColor
                )
                
                Divider()
                
                // Section 6: Articles
                DisclaimerSection(
                    icon: "book",
                    title: "6. Pregnancy Articles",
                    content: """
                    Disclaimer: To provide you with reliable and helpful information, we have made a significant effort to carefully select and aggregate articles from highly reputable sources, including government health organizations, international maternal health forums, and leading medical publications. Our goal is to bring you trusted educational content to help you prepare for your pregnancy journey.
                    However, while we select sources known for their high standards of accuracy, MomCare+ does not independently verify every single fact within these articles and cannot guarantee its absolute accuracy or timeliness. This content is presented for educational purposes and does not necessarily reflect the views of MomCare+. As with all content in this app, this information is not a substitute for direct, professional medical advice from your healthcare provider.
                    """,
                    source: "CITATION: The articles featured in this section are sourced from [Name of the Source, e.g., The March of Dimes, What to Expect, etc.]. We are grateful for their contribution to maternal education. You can read more at: [Link to the source website].",
                    accentColor: accentColor
                )
                
                Divider()
                
                // Section 7: Mood Tracking
                DisclaimerSection(
                    icon: "face.smiling",
                    title: "7. Mood Tracking and Music Suggestions",
                    content: """
                    DISCLAIMER: We understand that pregnancy is an emotional journey. The mood tracking feature is designed to help you maintain your emotional well-being. Based on the mood you log, our system suggests music that has been thoughtfully categorized and selected in an effort to provide comfort, calm, or upliftment.
                    It is crucial to understand that this is an automated wellness feature intended for comfort and entertainment only. It is not a diagnostic tool and does not provide medical or psychological therapy. This feature cannot detect or treat conditions such as prenatal or postpartum depression or anxiety. If you are experiencing persistent low moods, anxiety, or have concerns about your mental health, it is essential that you speak with your healthcare provider or a mental health professional. Your well-being is the top priority, and professional care is the correct and necessary step.
                    """,
                    source: nil,
                    accentColor: accentColor
                )
                
                // Footer
                VStack(spacing: 16) {
                    
                    Text("By using MomCare+, you acknowledge that you have read and understood these disclaimers.")
                        .font(.footnote)
                        .foregroundColor(accentColor)
                }
                .padding(.top, 16)
            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)
                        }
                        .background(Color(.systemBackground))
                    }
                }

struct DisclaimerSection: View {
    let icon: String
    let title: String
    let content: String
    var source: String?
    let accentColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(accentColor)
                    .frame(width: 24, alignment: .leading)
                
                Text(title)
                    .font(.title3.weight(.semibold))
            }
            
            Text(.init(content))
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)
            
            if let source = source, !source.isEmpty {
                Text(.init(source))
                    .font(.footnote)
                    .italic()
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
    }
}

struct DisclaimersView_Previews: PreviewProvider {
    static var previews: some View {
        DisclaimersView()
    }
}
