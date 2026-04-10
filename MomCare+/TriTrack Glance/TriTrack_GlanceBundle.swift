import SwiftUI
import WidgetKit

@main
struct TriTrack_GlanceBundle: WidgetBundle {
    var body: some Widget {
        TriTrack_Glance()

        if #available(iOS 18.0, *) {
            TriTrack_GlanceControl()
        }

        TriTrack_GlanceLiveActivity()
    }
}
