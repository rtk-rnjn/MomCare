//
//  PregnancySymptoms.swift
//  MomCare
//
//  Created by Khushi Rana on 14/09/25.
//

import Foundation

enum PregnancySymptoms {
    static let allSymptoms: [Symptom] = [
        Symptom(
            name: "Back Pain",
            whatIsIt: "A common ache or stiffness felt in the upper or, more commonly, lower back area during pregnancy.",
            trimesters: ["2nd Trimester", "3rd Trimester"],
            description: "Common due to hormonal changes that loosen joints, the shift in your center of gravity, and extra weight gain. The pain is often felt in the lower back.",
            remedies: ["Practice good posture.", "Wear low-heeled, supportive shoes.", "Sleep on your side with a pillow between your knees.", "Apply a warm compress to the painful area.", "Incorporate gentle exercise like walking or swimming."],
            whenToCallDoctor: "If the back pain is severe, constant, accompanied by a fever, or if you feel rhythmic cramping pains, as this could be a sign of preterm labor.",
            sources: "[NHS](https://www.nhs.uk/pregnancy/related-conditions/common-symptoms/back-pain/), [Mayo Clinic](https://www.mayoclinic.org/healthy-lifestyle/pregnancy-week-by-week/in-depth/pregnancy/art-20046080)"
        ),
        Symptom(
            name: "Bleeding Gums",
            whatIsIt: "A condition also known as 'pregnancy gingivitis', where gums become more sensitive and may bleed when brushing.",
            trimesters: ["1st Trimester", "2nd Trimester", "3rd Trimester"],
            description: "Hormonal changes can make your gums more susceptible to plaque, leading to inflammation and bleeding.",
            remedies: ["Use a softer toothbrush.", "Brush gently and thoroughly twice a day.", "Continue to floss daily, but be gentle.", "Schedule a regular dental check-up during pregnancy."],
            whenToCallDoctor: "If you have severe pain, a toothache, or persistent bleeding that doesn't improve with better hygiene.",
            sources: "[NHS](https://www.nhs.uk/pregnancy/related-conditions/common-symptoms/bleeding-gums/), [Cleveland Clinic](https://my.clevelandclinic.org/health/diseases/22484-pregnancy-gingivitis)"
        ),
        Symptom(
            name: "Constipation",
            whatIsIt: "A condition where you have infrequent bowel movements or difficulty passing stools.",
            trimesters: ["1st Trimester", "2nd Trimester", "3rd Trimester"],
            description: "The pregnancy hormone progesterone slows down your digestive system. The pressure of your growing uterus on your rectum can also contribute.",
            remedies: ["Eat a high-fiber diet (fruits, vegetables, whole grains).", "Drink plenty of water throughout the day.", "Engage in regular physical activity.", "Talk to your doctor before taking any laxatives."],
            whenToCallDoctor: "If you have severe abdominal pain, constipation lasts for more than a week, or it's accompanied by nausea and vomiting.",
            sources: "[Mayo Clinic](https://www.mayoclinic.org/healthy-lifestyle/pregnancy-week-by-week/expert-answers/pregnancy-constipation/faq-20058550)"
        ),
        Symptom(
            name: "Cramps",
            whatIsIt: "A pulling or dull aching sensation in the lower abdomen, similar to mild menstrual cramps.",
            trimesters: ["1st Trimester", "2nd Trimester", "3rd Trimester"],
            description: "Mild cramping is often caused by the stretching of your uterus or 'round ligament pain' as it supports your growing belly. It often feels like a pulling sensation.",
            remedies: ["Change your position slowly.", "Sit down and rest if a cramp strikes.", "Stay well-hydrated.", "A warm bath can help relax the muscles."],
            whenToCallDoctor: "If cramping is severe, persistent, or accompanied by any spotting, bleeding, fever, or unusual vaginal discharge.",
            sources: "[American Pregnancy Association](https://americanpregnancy.org/healthy-pregnancy/pregnancy-health-wellness/muscle-cramps-during-pregnancy/)"
        ),
        Symptom(
            name: "Dizziness",
            whatIsIt: "A feeling of being lightheaded, unsteady, or faint.",
            trimesters: ["1st Trimester", "2nd Trimester", "3rd Trimester"],
            description: "Your circulatory system expands rapidly during pregnancy, which can lead to lower blood pressure and feelings of lightheadedness. Low blood sugar can also be a cause.",
            remedies: ["Get up slowly from sitting or lying down.", "Avoid standing for very long periods.", "Eat regular, small meals to avoid low blood sugar.", "Stay hydrated."],
            whenToCallDoctor: "If you faint, or if dizziness is accompanied by blurred vision, severe headaches, or heart palpitations.",
            sources: "[NHS](https://www.nhs.uk/pregnancy/related-conditions/common-symptoms/tiredness/)"
        ),
        Symptom(
            name: "Feeling Hot",
            whatIsIt: "A persistent feeling of being warmer than usual, unrelated to the weather.",
            trimesters: ["1st Trimester", "2nd Trimester", "3rd Trimester"],
            description: "An increased metabolic rate and a higher volume of blood circulating in your body can make you feel warmer than usual.",
            remedies: ["Wear loose, breathable clothing.", "Drink plenty of cool water.", "Use a fan or air conditioning.", "Take lukewarm showers."],
            whenToCallDoctor: "If you have a fever (a temperature of 38°C or 100.4°F or higher), as this could indicate an infection.",
            sources: "[The Bump](https://www.thebump.com/a/hot-flashes-pregnancy)"
        ),
        Symptom(
            name: "Food Cravings and Aversions",
            whatIsIt: "A sudden, strong desire for a specific food (craving) or an intense dislike of a food you previously enjoyed (aversion).",
            trimesters: ["1st Trimester", "2nd Trimester"],
            description: "Rapidly changing hormones are thought to be the main cause of strong cravings for certain foods and sudden aversions to others you used to enjoy.",
            remedies: ["Indulge cravings in moderation.", "Find healthy substitutes for unhealthy cravings.", "Don't force yourself to eat foods that make you feel nauseous."],
            whenToCallDoctor: "If you crave non-food items like dirt, clay, or ice (a condition called pica), as it can be a sign of a nutritional deficiency.",
            sources: "[healthline](https://www.healthline.com/health/pregnancy/food-aversions)"
        ),
        Symptom(
            name: "Headaches",
            whatIsIt: "A pain or ache felt in the head or upper neck. Tension headaches are most common in early pregnancy.",
            trimesters: ["1st Trimester", "2nd Trimester", "3rd Trimester"],
            description: "Hormonal shifts, especially in the first trimester, are a common cause. Dehydration, stress, and lack of sleep can also trigger them.",
            remedies: ["Get plenty of rest.", "Stay hydrated.", "Apply a cold or warm compress to your forehead.", "Practice relaxation techniques like deep breathing."],
            whenToCallDoctor: "If your headache is severe, persistent, or accompanied by blurred vision or swelling in your hands and face, especially in the second or third trimester (sign of preeclampsia).",
            sources: "[NHS](https://www.nhs.uk/pregnancy/related-conditions/common-symptoms/headaches/)"
        ),
        Symptom(
            name: "Incontinence",
            whatIsIt: "The unintentional leaking of urine, often when you cough, sneeze, laugh, or exercise (known as stress incontinence).",
            trimesters: ["2nd Trimester", "3rd Trimester"],
            description: "The growing uterus puts pressure on your bladder, which can cause leakage of urine.",
            remedies: ["Practice Kegel exercises to strengthen pelvic floor muscles.", "Urinate frequently; don't wait until your bladder is full.", "Wear a panty liner for protection."],
            whenToCallDoctor: "If you experience pain or a burning sensation when you urinate, as this could be a urinary tract infection (UTI).",
            sources: "[Babycenter](https://www.babycenter.com/pregnancy/your-body/urinary-incontinence-during-pregnancy_20004870)"
        ),
        Symptom(
            name: "Indigestion and Heartburn",
            whatIsIt: "Heartburn is a burning feeling in the chest. Indigestion is a feeling of fullness, bloating, or discomfort after eating.",
            trimesters: ["1st Trimester", "2nd Trimester", "3rd Trimester"],
            description: "Pregnancy hormones relax the muscular valve at the top of the stomach, allowing stomach acid to flow back up into the esophagus.",
            remedies: ["Eat smaller, more frequent meals.", "Avoid spicy, fatty, and acidic foods.", "Stay upright for at least an hour after eating.", "Prop your head up with extra pillows when sleeping."],
            whenToCallDoctor: "If heartburn is severe, prevents you from eating or sleeping, or if you have difficulty swallowing.",
            sources: "[NHS](https://www.nhs.uk/pregnancy/related-conditions/common-symptoms/indigestion-and-heartburn/)"
        ),
        Symptom(
            name: "Leaking from Nipples",
            whatIsIt: "The leakage of a yellowish, thick fluid called colostrum, which is the first milk your breasts produce.",
            trimesters: ["2nd Trimester", "3rd Trimester"],
            description: "Your breasts may start to leak colostrum as early as the second trimester. This is your body's way of preparing to produce breast milk.",
            remedies: ["Place nursing pads inside your bra to absorb the leakage."],
            whenToCallDoctor: "This is usually normal. However, you should mention it to your doctor if the discharge is bloody.",
            sources: "[NHS](https://www.nhs.uk/pregnancy/related-conditions/common-symptoms/leaking-nipples/)"
        ),
        Symptom(
            name: "Nosebleeds",
            whatIsIt: "Bleeding from the inside of your nose, which can be more frequent during pregnancy.",
            trimesters: ["1st Trimester", "2nd Trimester", "3rd Trimester"],
            description: "Increased blood volume and hormonal changes can cause the delicate blood vessels in your nose to swell and rupture more easily.",
            remedies: ["Use a humidifier to keep the air moist.", "Blow your nose gently.", "If you get a nosebleed, sit down, lean forward, and pinch your nostrils firmly for 10-15 minutes."],
            whenToCallDoctor: "If you have frequent nosebleeds or if the bleeding is heavy and doesn't stop after 20 minutes of pressure.",
            sources: "[NHS](https://www.nhs.uk/pregnancy/related-conditions/common-symptoms/nosebleeds/)"
        ),
        Symptom(
            name: "Peeing a Lot",
            whatIsIt: "A noticeable increase in the frequency of urination throughout the day and night.",
            trimesters: ["1st Trimester", "3rd Trimester"],
            description: "Your body produces more blood, and your kidneys work harder to filter it, creating more urine. Later in pregnancy, your baby's head presses on your bladder.",
            remedies: ["Lean forward when you urinate to fully empty your bladder.", "Avoid drinking large amounts right before bed to reduce nighttime trips.", "Do not cut back on fluids during the day."],
            whenToCallDoctor: "If you feel pain, burning, or a sense of urgency with very little urine, as these are signs of a UTI.",
            sources: "[Babycenter](https://www.babycenter.com/pregnancy/your-body/frequent-urination-during-pregnancy_237)"
        ),
        Symptom(
            name: "Pelvic Pain",
            whatIsIt: "Pain felt in the front or back of the pelvic area, also known as Pelvic Girdle Pain (PGP) or Symphysis Pubis Dysfunction (SPD).",
            trimesters: ["2nd Trimester", "3rd Trimester"],
            description: "Hormones soften the ligaments that stabilize your pelvis, causing pain and instability as your body prepares for birth.",
            remedies: ["Wear a pelvic support belt.", "Avoid activities that make the pain worse, like heavy lifting.", "Keep your knees together when getting out of a car or bed.", "Ask your doctor about physical therapy."],
            whenToCallDoctor: "If the pain is severe and limits your ability to move around and perform daily activities.",
            sources: "[NHS](https://www.nhs.uk/pregnancy/related-conditions/common-symptoms/pelvic-pain/)"
        ),
        Symptom(
            name: "Piles (Hemorrhoids)",
            whatIsIt: "Swollen veins in or around the rectum and anus that can be itchy and painful.",
            trimesters: ["2nd Trimester", "3rd Trimester"],
            description: "These are often caused by increased pressure from the uterus and constipation-related straining.",
            remedies: ["Avoid constipation by eating fiber and drinking fluids.", "Don't strain during bowel movements.", "Use witch hazel pads or ice packs for relief.", "Avoid sitting for long periods."],
            whenToCallDoctor: "If you have significant rectal bleeding or if the pain is severe.",
            sources: "[NHS](https://www.nhs.uk/pregnancy/related-conditions/common-symptoms/piles/), [Mayo Clinic](https://www.mayoclinic.org/healthy-lifestyle/pregnancy-week-by-week/expert-answers/hemorrhoids-during-pregnancy/faq-20058149)"
        ),
        Symptom(
            name: "Skin Changes",
            whatIsIt: "Changes to your skin, including stretch marks, a dark line on your belly (linea nigra), or dark patches on your face (melasma).",
            trimesters: ["2nd Trimester", "3rd Trimester"],
            description: "Hormones are the primary cause of these common skin changes during pregnancy.",
            remedies: ["Use sunscreen with high SPF to prevent melasma from worsening.", "Keep skin well-moisturized to help with itching from stretch marks.", "Most changes fade after delivery."],
            whenToCallDoctor: "If you develop a new rash or severe itching, especially on your hands and feet (a potential sign of cholestasis).",
            sources: "[Mayo Clinic](https://www.mayoclinic.org/healthy-lifestyle/pregnancy-week-by-week/in-depth/pregnancy/art-20047732)"
        ),
        Symptom(
            name: "Stomach Pain",
            whatIsIt: "Mild aches or pains in the abdomen that are usually not a cause for concern.",
            trimesters: ["1st Trimester", "2nd Trimester", "3rd Trimester"],
            description: "Mild stomach pain can be due to gas, constipation, or the stretching of round ligaments. It is usually temporary and not severe.",
            remedies: ["For gas or bloating, avoid trigger foods and eat slowly.", "For round ligament pain, move slowly and avoid sudden movements."],
            whenToCallDoctor: "Call immediately for severe or persistent pain, especially if it's accompanied by fever, bleeding, contractions, or changes in vaginal discharge.",
            sources: "[NHS](https://www.nhs.uk/pregnancy/related-conditions/common-symptoms/stomach-pain/)"
        ),
        Symptom(
            name: "Swollen Ankles, Feet, and Fingers",
            whatIsIt: "A common condition known as edema, which is swelling caused by your body holding on to more fluid than usual.",
            trimesters: ["2nd Trimester", "3rd Trimester"],
            description: "Your body retains more fluid during pregnancy, and the pressure from your uterus can slow blood return from your legs.",
            remedies: ["Elevate your feet whenever possible.", "Avoid long periods of standing or sitting.", "Wear comfortable shoes and avoid tight socks.", "Drink plenty of water."],
            whenToCallDoctor: "Call immediately if there is a sudden and severe increase in swelling, or if it affects your face and hands, as this can be a sign of preeclampsia.",
            sources: "[NHS](https://www.nhs.uk/pregnancy/related-conditions/common-symptoms/swollen-ankles-feet-and-fingers/)"
        ),
        Symptom(
            name: "Tender, Swollen Breasts",
            whatIsIt: "One of the earliest signs of pregnancy, where breasts feel sore, sensitive, and heavy.",
            trimesters: ["1st Trimester"],
            description: "Hormonal changes increase blood flow and cause changes in breast tissue to prepare for breastfeeding.",
            remedies: ["Wear a well-fitting, supportive bra, even at night if it helps.", "Avoid underwire bras that can dig in.", "A cotton sports bra can be a comfortable option."],
            whenToCallDoctor: "This is a normal symptom. Contact your doctor if you find a new or changing lump.",
            sources: "[Mayo Clinic](https://www.mayoclinic.org/healthy-lifestyle/pregnancy-week-by-week/in-depth/pregnancy/art-20047208), [What To Expect](https://www.whattoexpect.com/pregnancy/symptoms-and-solutions/breast-tenderness.aspx)"
        ),
        Symptom(
            name: "Tiredness and Sleep Problems",
            whatIsIt: "A feeling of extreme fatigue or exhaustion, especially common in the first and third trimesters.",
            trimesters: ["1st Trimester", "3rd Trimester"],
            description: "Your body is working hard to grow the placenta and the baby, and hormonal changes can disrupt your sleep patterns.",
            remedies: ["Listen to your body and rest or nap when you need to.", "Engage in light exercise during the day.", "Create a relaxing bedtime routine.", "Use pillows to find a comfortable sleeping position."],
            whenToCallDoctor: "If fatigue is so severe it impacts your daily life, or if you suspect you may have anemia or depression.",
            sources: "[NHS](https://www.nhs.uk/pregnancy/related-conditions/common-symptoms/tiredness/)" ),
        Symptom(
            name: "Thrush (Yeast Infection)",
            whatIsIt: "A common vaginal yeast infection that can cause itching, irritation, and a white discharge.",
            trimesters: ["2nd Trimester", "3rd Trimester"],
            description: "Hormonal changes can alter the pH balance of the vagina, making it easier for yeast to grow.",
            remedies: ["Wear loose, cotton underwear.", "Avoid scented soaps or bubble baths.", "Consult your doctor for a pregnancy-safe antifungal treatment."],
            whenToCallDoctor: "Always consult your doctor to confirm it's a yeast infection and to get the correct, pregnancy-safe medication.",
            sources: "[NHS](https://www.nhs.uk/pregnancy/related-conditions/common-symptoms/thrush/)"
        ),
        Symptom(
            name: "Vaginal Bleeding",
            whatIsIt: "Any amount of blood coming from the vagina during pregnancy, ranging from light spotting to heavy bleeding.",
            trimesters: ["1st Trimester", "2nd Trimester", "3rd Trimester"],
            description: "Bleeding during pregnancy requires medical attention to rule out serious conditions. While light spotting can be normal in early pregnancy, it should always be checked.",
            remedies: ["There are no home remedies. Your only action should be to contact your doctor or midwife immediately."],
            whenToCallDoctor: "Call your doctor or go to the hospital immediately for any amount of vaginal bleeding, with or without pain or cramping.",
            sources: "[NHS](https://www.nhs.uk/pregnancy/related-conditions/common-symptoms/vaginal-bleeding/), [Mayo Clinic](https://www.mayoclinic.org/symptoms/bleeding-during-pregnancy/basics/when-to-see-doctor/sym-20050636)"
        ),
        Symptom(
            name: "Vaginal Discharge",
            whatIsIt: "An increase in a thin, milky-white, and mild-smelling discharge known as leukorrhea.",
            trimesters: ["1st Trimester", "2nd Trimester", "3rd Trimester"],
            description: "An increase in leukorrhea is normal during pregnancy due to increased estrogen production and blood flow to the vaginal area.",
            remedies: ["Wear a panty liner for comfort.", "Keep the area clean and dry.", "Do not douche, as it can disrupt the natural balance."],
            whenToCallDoctor: "If the discharge changes color (greenish, yellowish), has a strong odor, or is accompanied by itching or burning, as this could be an infection.",
            sources: "[NHS](https://www.nhs.uk/pregnancy/related-conditions/common-symptoms/vaginal-discharge/), [American Pregnancy Association](https://americanpregnancy.org/healthy-pregnancy/pregnancy-health-wellness/vaginal-discharge-during-pregnancy/)"
        ),
        Symptom(
            name: "Varicose Veins",
            whatIsIt: "Swollen, twisted veins that you can see under the skin, most often in the legs.",
            trimesters: ["2nd Trimester", "3rd Trimester"],
            description: "The weight of the growing uterus puts pressure on the large vein on the right side of your body (the inferior vena cava), increasing pressure in the leg veins.",
            remedies: ["Avoid sitting or standing for long periods.", "Elevate your legs when you rest.", "Wear compression stockings.", "Get regular exercise."],
            whenToCallDoctor: "If the veins are red, swollen, tender, and warm to the touch, which could be a sign of a blood clot.",
            sources: "[Mayo Clinic](https://www.mayoclinic.org/healthy-lifestyle/pregnancy-week-by-week/expert-answers/vulvar-varicosities-during-pregnancy/faq-20419426)"
        ),
        Symptom(
            name: "Vomiting and Morning Sickness",
            whatIsIt: "Nausea and vomiting that can occur at any time of day, most commonly experienced in the first trimester.",
            trimesters: ["1st Trimester"],
            description: "Nausea and vomiting are very common, especially in the first trimester, likely caused by rapidly rising hormone levels.",
            remedies: ["Eat small, frequent meals.", "Keep plain crackers by your bed to eat before getting up.", "Avoid smells that trigger nausea.", "Try sipping ginger ale or ginger tea."],
            whenToCallDoctor: "If you are vomiting multiple times a day, unable to keep any food or liquid down, and losing weight. This could be hyperemesis gravidarum.",
            sources: "[NHS](https://www.nhs.uk/pregnancy/related-conditions/common-symptoms/vomiting-and-morning-sickness/)"
        )
    ]
}
