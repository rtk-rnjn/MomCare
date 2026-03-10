import SwiftUI
import WidgetKit

@main
struct TriTrack_GlanceBundle: WidgetBundle {
    var body: some Widget {
        TriTrack_Glance()
        TriTrack_GlanceControl()
        TriTrack_GlanceLiveActivity()
    }
}
