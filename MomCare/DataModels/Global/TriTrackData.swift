//
//  TriTrackData.swift
//  MomCare
//
//  Created by Ritik Ranjan on 04/03/25.
//

enum TriTrackData {
    public static let trimesterData: [TrimesterData] = [
        .init(
            trimesterNumber: 2,
            weekNumber: 19,
            dayNumber: 5,
            quote: "I am currently the size of a large banana",
            leftImageName: "", rightImageName: "",
            babyHeightInCentimeters: 15.2,
            babyWeightInKilograms: 0.23,
            babyTipText: "Talk and Sing to Your Baby: At this stage, your baby’s hearing is developing, and they can start recognizing your voice! Talking, reading, or singing can help strengthen the bond and may even soothe the baby after birth.",
            momTipText: "Focus on Posture: As your belly grows, your center of gravity shifts, which can cause back pain. Practice good posture by keeping your shoulders back and avoiding standing for too long. Using a pregnancy pillow at night can also provide extra support."
        )
    ]

    public static func getTrimesterData(for week: Int) -> TrimesterData? {
        return trimesterData.first { $0.weekNumber == week }
    }
}
