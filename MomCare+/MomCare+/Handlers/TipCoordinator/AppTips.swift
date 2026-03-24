import TipKit
import UIKit

enum MomCareTips {

    enum Dashboard {
        struct DashboardWeekCardTip: Tip {
            var title: Text {
                Text("Pregnancy Progress Card")
            }

            var message: Text? {
                Text("This card shows your current week and day of pregnancy, as well as the trimester you're in.")
            }

            var image: Image? {
                Image(systemName: "calendar")
                    .symbolRenderingMode(.multicolor)
                    .symbolRenderingMode(.palette)
            }
        }

        struct DashboardEventCardTip: Tip {
            var title: Text {
                Text("Upcoming Event")
            }

            var message: Text? {
                Text("This card shows your next upcoming event and allows you to add new events.")
            }

            var image: Image? {
                Image(systemName: "calendar.badge.clock")
                    .symbolRenderingMode(.multicolor)
                    .symbolRenderingMode(.palette)
            }
        }
    }

    enum DietPlan {
        struct ProgressCardSlideOrTapTip: Tip {
            var title: Text {
                Text("Progress Card")
            }

            var message: Text? {
                Text("Swipe up or down to cycle between calories, macros, and micros. Tap to expand details.")
            }

            var image: Image? {
                UIImage(systemName: "hand.tap")
                    .map { $0.withTintColor(.black, renderingMode: .alwaysOriginal) }
                    .map(Image.init(uiImage:))
            }
        }

        struct HeaderRowAddTip: Tip {
            var title: Text {
                Text("Add Food Items")
            }

            var message: Text? {
                Text("Tap the pencil icon in a meal header to add food items to that meal.")
            }
        }

        struct ItemRowSlideTip: Tip {
            var title: Text {
                Text("Swipe to Act")
            }

            var message: Text? {
                Text("Swipe right to mark as consumed, swipe left to delete. Long press for more options.")
            }

            var image: Image? {
                UIImage(systemName: "hand.draw")
                    .map { $0.withTintColor(.black, renderingMode: .alwaysOriginal) }
                    .map(Image.init(uiImage:))
            }
        }
    }

    enum ExercisePlan {
        struct WalkingCardTapTip: Tip {
            static let dismissedEvent: Event = .init(id: String(describing: Self.self))

            var title: Text {
                Text("Walking Card")
            }

            var message: Text? {
                Text("Tap the card to view your walking history.")
            }

            var image: Image? {
                UIImage(systemName: "hand.tap")
                    .map { $0.withTintColor(.black, renderingMode: .alwaysOriginal) }
                    .map(Image.init(uiImage:))

            }
        }
    }

    enum MoodNest {
        struct MoodNestSliderTip: Tip {
            var title: Text {
                Text("Mood Slider")
            }
            
            var message: Text? {
                Text("Drag the slider to indicate how you're feeling today.")
            }
            
            var image: Image? {
                UIImage(systemName: "hand.draw")
                    .map { $0.withTintColor(.black, renderingMode: .alwaysOriginal) }
                    .map(Image.init(uiImage:))
            }
        }
    }
}
