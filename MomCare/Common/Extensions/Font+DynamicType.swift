//
//  Font+DynamicType.swift
//  MomCare
//
//  Created by Copilot on 14/09/2024.
//

import SwiftUI

extension Font {
    
    /// Provides Dynamic Type support for custom font sizes
    static func dynamicSystem(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> Font {
        return .system(size: size, weight: weight, design: design)
    }
    
    /// Returns a font that scales appropriately with Dynamic Type settings
    static func scaledTitle(_ size: CGFloat = 28) -> Font {
        return .system(size: size, weight: .bold, design: .default)
    }
    
    static func scaledHeadline(_ size: CGFloat = 22) -> Font {
        return .system(size: size, weight: .semibold, design: .default)
    }
    
    static func scaledSubheadline(_ size: CGFloat = 16) -> Font {
        return .system(size: size, weight: .medium, design: .default)
    }
    
    static func scaledBody(_ size: CGFloat = 14) -> Font {
        return .system(size: size, weight: .regular, design: .default)
    }
    
    static func scaledCaption(_ size: CGFloat = 12) -> Font {
        return .system(size: size, weight: .regular, design: .default)
    }
}

/// Custom view modifier for applying scaled metrics
struct ScaledFont: ViewModifier {
    @ScaledMetric private var size: CGFloat
    private let weight: Font.Weight
    private let design: Font.Design
    
    init(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) {
        self._size = ScaledMetric(wrappedValue: size)
        self.weight = weight
        self.design = design
    }
    
    func body(content: Content) -> some View {
        content.font(.system(size: size, weight: weight, design: design))
    }
}

extension View {
    func scaledFont(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> some View {
        modifier(ScaledFont(size: size, weight: weight, design: design))
    }
}