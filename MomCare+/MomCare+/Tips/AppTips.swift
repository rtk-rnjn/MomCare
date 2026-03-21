import TipKit

struct WeekCardTip: Tip {
    var title: Text {
        Text("Your Pregnancy Week")
    }

    var message: Text? {
        Text("Tap to explore detailed baby development info, trimester milestones, and weekly growth statistics.")
    }

    var image: Image? {
        Image(systemName: "heart.fill")
            .foregroundStyle(.pink) as? Image
    }
}

struct AddEventTip: Tip {
    var title: Text {
        Text("Schedule Appointments")
    }

    var message: Text? {
        Text("Tap 'Add Event' to create checkups, reminders, and important dates directly from your dashboard.")
    }

    var image: Image? {
        Image(systemName: "calendar.badge.plus")
    }
}

struct DietContextMenuTip: Tip {
    var title: Text {
        Text("Nutrition Graph")
    }

    var message: Text? {
        Text("Long-press the progress card to view your calorie and nutrient breakdown as an interactive graph.")
    }

    var image: Image? {
        Image(systemName: "chart.bar.xaxis")
    }
}

struct FoodItemSwipeActionsTip: Tip {
    var title: Text {
        Text("Manage Food Log")
    }

    var message: Text? {
        Text("Swipe left or right to delete or mark food as consumed, keeping your nutrition log accurate and up-to-date.")
    }

    var image: Image? {
        Image(systemName: "hand.draw")
    }
}

struct FoodItemContextMenuTip: Tip {
    var title: Text {
        Text("Food Details")
    }

    var message: Text? {
        Text("Long-press a food item to view detailed nutrition info, edit servings, or add notes about how it made you feel.")
    }

    var image: Image? {
        Image(systemName: "hand.tap")
    }
}

struct AddFoodButtonTip: Tip {
    var title: Text {
        Text("Add Food Entry")
    }

    var message: Text? {
        Text("Tap the 'Add Food' button to quickly log meals, snacks, and beverages, helping you track your nutrition throughout pregnancy.")
    }

    var image: Image? {
        Image(systemName: "plus.circle")
    }
}

struct MoodSliderTip: Tip {
    var title: Text {
        Text("Choose Your Mood")
    }

    var message: Text? {
        Text("Drag the slider to set your current mood, then tap 'Set Mood' for personalized playlist recommendations.")
    }

    var image: Image? {
        Image(systemName: "face.smiling")
    }
}
