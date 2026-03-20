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

struct BreathingExerciseTip: Tip {
    var title: Text {
        Text("Guided Breathing")
    }

    var message: Text? {
        Text("Tap the breathing card for step-by-step instructions on calming exercises tailored to your trimester.")
    }

    var image: Image? {
        Image(systemName: "lungs.fill")
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

struct PersonalInfoEditTip: Tip {
    var title: Text {
        Text("Keep Your Info Current")
    }

    var message: Text? {
        Text("Tap 'Edit' to update your measurements. Accurate data ensures the best nutrition and exercise recommendations.")
    }

    var image: Image? {
        Image(systemName: "person.crop.circle")
    }
}

struct WaterLogQuickAddTip: Tip {
    var title: Text {
        Text("Log Water Quickly")
    }

    var message: Text? {
        Text("Tap a preset button to log your water intake instantly. Enable reminders from the menu to stay on track.")
    }

    var image: Image? {
        Image(systemName: "drop.fill")
    }
}
