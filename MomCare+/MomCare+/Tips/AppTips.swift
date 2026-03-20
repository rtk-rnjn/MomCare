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
