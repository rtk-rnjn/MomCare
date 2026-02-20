import SwiftUI

enum MomCareAccent {
    static let primary: Color = .init("primaryAppColor")
    static let secondary: Color = .init("secondaryAppColor")
}

enum MoodColors {
    static let happyBackground: Color = .init(hex: "#FFD0CB")
    static let happyFace: Color = .init(hex: "#814c45")

    static let sadBackground: Color = .init(hex: "#8DC1D4")
    static let sadFace: Color = .init(hex: "#2F4C5A")

    static let stressedBackground: Color = .init(hex: "#D5E5C9")
    static let stressedFace: Color = .init(hex: "#4A593D")

    static let angryBackground: Color = .init(hex: "#F79E90")
    static let angryFace: Color = .init(hex: "#583933")
}

extension MoodColors {
    static let happyBackgroundSwiftUI: Color = .init(happyBackground)
    static let sadBackgroundSwiftUI: Color = .init(sadBackground)
    static let stressedBackgroundSwiftUI: Color = .init(stressedBackground)
    static let angryBackgroundSwiftUI: Color = .init(angryBackground)

    static let happyFaceSwiftUI: Color = .init(happyFace)
    static let sadFaceSwiftUI: Color = .init(sadFace)
    static let stressedFaceSwiftUI: Color = .init(stressedFace)
    static let angryFaceSwiftUI: Color = .init(angryFace)
}
