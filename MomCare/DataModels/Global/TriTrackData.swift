//
//  TriTrackData.swift
//  MomCare
//
//  Created by Ritik Ranjan on 04/03/25.
//

enum TriTrackData {
    public static let trimesterData: [TrimesterData] = [
        .init(
            weekNumber: 1,
            babyTipText: "Although conception hasn’t happened yet, Week 1 marks the start of your pregnancy based on your last menstrual period. At this point, there is no baby yet—your body is preparing for ovulation and fertilization. Hormonal signals are initiating the cycle that leads to the release of an egg and thickening of the uterine lining. This is a foundational week for the baby’s eventual development.",
            momTipText: "You may not feel pregnant, but your body is beginning the process. Hormones like estrogen and progesterone begin to fluctuate, preparing the uterus for a possible embryo. You might experience menstrual symptoms like cramping or bleeding, but internally, a fresh start is taking shape. This is a good time to begin prenatal vitamins, especially folic acid, to support healthy fetal development once conception occurs."
        ),
        .init(
            weekNumber: 2,
            babyTipText: "This is the week ovulation typically occurs. The egg, released from the ovary, travels down the fallopian tube, where it may meet sperm and become fertilized. The fertilized egg (zygote) contains a full set of DNA that determines the baby’s sex, hair color, eye color, and more. Though still microscopic, this is the actual beginning of new life.",
            momTipText: "You're at the most fertile point in your cycle. Your body releases luteinizing hormone (LH), which triggers ovulation. You may notice an increase in cervical mucus and a slight rise in basal body temperature. Some women feel a slight pain on one side of their abdomen, known as mittelschmerz. This is a crucial time for conception if you're trying to get pregnant."
        ),
        .init(
            weekNumber: 3,
            babyTipText: "Fertilization has occurred! The single-celled zygote begins rapidly dividing and becomes a blastocyst as it journeys through the fallopian tube toward the uterus. By the end of the week, implantation into the uterine wall begins. This is when the pregnancy truly begins and the placenta starts to form.",
            momTipText: "Although you won’t notice any outward symptoms, incredible changes are underway. Your body produces more progesterone to maintain the uterine lining. Some women may experience light spotting (implantation bleeding), fatigue, or heightened senses. Your hCG hormone level is starting to rise, though still too low for a home pregnancy test to detect."
        ),
        .init(
            weekNumber: 4,
            quote: "I’m currently the size of an poppy seed",
            leftImageUri: "https://img.icons8.com/material-two-tone/24/lentil.png",
            babyHeightInCentimeters: 0.2,
            babyWeightInKilograms: 0.002,
            babyTipText: "The blastocyst has implanted in the uterine wall and is now called an embryo. It is forming two layers: the epiblast and the hypoblast, which will eventually give rise to the baby and supporting tissues. The amniotic sac and yolk sac begin to form, providing protection and nourishment. The embryo is about the size of a poppy seed.",
            momTipText: "You might begin to suspect you're pregnant. Some early signs include mild cramping, breast tenderness, mood swings, or nausea. A missed period is the most noticeable sign. The hormone hCG (human chorionic gonadotropin) is now being produced in detectable amounts, confirming pregnancy on a test. Your body is working overtime to create a safe environment for your developing baby."
        ),

        // TODO: Fill the data @write2nupu
    ]

    public static func getTrimesterData(for week: Int) -> TrimesterData? {
        return trimesterData.first { $0.weekNumber == week }
    }
}
