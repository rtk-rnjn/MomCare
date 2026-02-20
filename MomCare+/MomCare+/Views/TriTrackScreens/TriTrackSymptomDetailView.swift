//
//  TriTrackSymptomDetailView.swift
//  MomCare
//
//  Created by Aryan singh on 18/02/26.
//

import SwiftUI

struct TriTrackSymptomDetailView: View {

    // MARK: Internal

    let themeColor: Color = .CustomColors.mutedRaspberry
    let accentColor: Color = .init(hex: "E9D3D3")
    let symptom: Symptom

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 40) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(symptom.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)

                    HStack {
                        ForEach(symptom.trimesters, id: \.self) { trimester in
                            Text(trimester)
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 10).padding(.vertical, 5)
                                .background(Color.black.opacity(0.05))
                                .foregroundColor(.black.opacity(0.8))
                                .clipShape(Capsule())
                        }
                    }
                }

                ForEach(topInfoSections) { section in
                    SymptomSectionView(
                        title: section.title,
                        iconName: section.iconName,
                        color: themeColor,
                        content: section.content
                    )
                }

                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        Image(systemName: "list.bullet.clipboard.fill")
                            .foregroundColor(themeColor)
                        Text("What you can do")
                            .foregroundColor(.black)
                    }
                    .font(.headline)

                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(symptom.remedies, id: \.self) { remedy in
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 6))
                                    .foregroundColor(accentColor)
                                Text(remedy)
                            }
                        }
                    }
                    .foregroundColor(Color(.darkGray))
                }

                ForEach(bottomInfoSections) { section in
                    SymptomSectionView(
                        title: section.title,
                        iconName: section.iconName,
                        color: themeColor,
                        content: section.content
                    )
                }
            }
            .padding()
        }
        .background(Color.white)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) { Text("") }
        }
    }

    // MARK: Private

    private var topInfoSections: [SymptomInfoSection] {
        [
            .init(title: "What is it?", iconName: "questionmark.bubble.fill", content: symptom.whatIsIt),
            .init(title: "Why is this happening?", iconName: "arrow.2.squarepath", content: symptom.symotomDescription),
        ]
    }

    private var bottomInfoSections: [SymptomInfoSection] {
        [
            .init(title: "When to call your doctor", iconName: "phone.fill", content: symptom.whenToCallDoctor),
            .init(title: "Sources", iconName: "book.fill", content: symptom.sources),
        ]
    }
}

struct SymptomSectionView: View {
    let title: String, iconName: String, color: Color, content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: iconName).foregroundColor(color)
                Text(title).foregroundColor(.black)
            }.font(.headline)

            Text(LocalizedStringKey(content))
                .font(.body)
                .foregroundColor(Color(.darkGray))
        }
    }
}
