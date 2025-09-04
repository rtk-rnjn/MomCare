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

        VStack(spacing: 8) {

            Text("Week \(entry.week)")

                .font(.title2)

                .fontWeight(.semibold)

            Text("Day \(entry.day)")

                .font(.title3)

        }

        .padding()

    }

}
