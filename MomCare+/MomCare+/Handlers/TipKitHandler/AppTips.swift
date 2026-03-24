import TipKit

enum MomCareTips {
    enum Dashboard {
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
    }

    enum MyPlan {
        struct ProgressCardTip: Tip {
            var title: Text {
                Text("Progress Card")
            }

            var message: Text? {
                Text("The Progress Card provides an overview of your daily nutrition intake compared to your goals.")
            }
        }

        struct HeaderRowAddTip: Tip {
            static let dismissedEvent: Event = .init(id: "headerRowAddTipDismissed")

            var title: Text {
                Text("Add Food Items")
            }

            var message: Text? {
                Text("You can add food items to your meal plan by tapping the pencil icon in the meal header.")
            }
        }

        struct ItemRowSlideTip: Tip {
            var title: Text {
                Text("Mark as Consumed or Delete")
            }

            var message: Text? {
                Text("You can also mark a food item as consumed or delete it by swiping left or right on the item.")
            }

            var image: Image? {
                Image(systemName: "checkmark.circle")
                    .symbolRenderingMode(.palette)
                    .symbolColorRenderingMode(.flat)
            }

            var rules: [Rule] {
                #Rule(HeaderRowAddTip.dismissedEvent) { !$0.donations.isEmpty }
            }
        }
    }
}
