//
//  PregnancyTrackerEntryView.swift
//  MomCare
//
//  Created by Ritik Ranjan on 25/07/25.
//

import SwiftUI

struct PregnancyTrackerEntryView: View {
    var entry: PregnancyTrackerTimelineProvider.Entry

    var body: some View {
        VStack {
            Text("Week: \(entry.week), Day: \(entry.day)")
                .font(.headline)
                .padding()
        }
    }
}
