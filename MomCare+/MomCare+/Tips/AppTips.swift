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

struct WaterLogAddEntryTip: Tip {
    var title: Text {
        Text("Log Water Intake")
    }

    var message: Text? {
        Text("Tap the quick-add buttons or use the '+' button to log exactly how much water you've had.")
    }

    var image: Image? {
        Image(systemName: "drop.fill")
    }
}

struct WaterLogSwipeActionsTip: Tip {
    var title: Text {
        Text("Edit or Delete Entries")
    }

    var message: Text? {
        Text("Swipe left on a water log entry to edit the amount or delete it if logged by mistake.")
    }

    var image: Image? {
        Image(systemName: "hand.draw.fill")
    }
}

struct BreathingExerciseTip: Tip {
    var title: Text {
        Text("Breathing Exercise")
    }

    var message: Text? {
        Text("Tap 'Start Breathing' to begin a guided breathing session. Deep breathing reduces stress and supports healthy oxygen levels during pregnancy.")
    }

    var image: Image? {
        Image(systemName: "wind")
    }
}

struct ExerciseCardTip: Tip {
    var title: Text {
        Text("Start Exercise")
    }

    var message: Text? {
        Text("Tap an exercise card to begin the video-guided workout. Long-press to view details like duration and difficulty.")
    }

    var image: Image? {
        Image(systemName: "figure.walk.circle")
    }
}

struct TriTrackAddSymptomTip: Tip {
    var title: Text {
        Text("Track Your Symptoms")
    }

    var message: Text? {
        Text("Tap '+' to log a new symptom. Tracking symptoms helps your doctor understand your pregnancy journey better.")
    }

    var image: Image? {
        Image(systemName: "stethoscope")
    }
}

struct TriTrackCalendarTip: Tip {
    var title: Text {
        Text("Browse Past Dates")
    }

    var message: Text? {
        Text("Tap any date on the calendar to view your events, reminders, and logged symptoms for that day.")
    }

    var image: Image? {
        Image(systemName: "calendar")
    }
}

struct ProfileEditTip: Tip {
    var title: Text {
        Text("Update Your Profile")
    }

    var message: Text? {
        Text("Tap 'Edit' to update your personal details. Keeping your due date and health metrics current improves your plan recommendations.")
    }

    var image: Image? {
        Image(systemName: "person.crop.circle.badge.plus")
    }
}

struct MoodPlaylistTip: Tip {
    var title: Text {
        Text("Mood-Based Playlists")
    }

    var message: Text? {
        Text("Tap a playlist to start listening. Music curated for your mood can help you relax, energise, or find calm during pregnancy.")
    }

    var image: Image? {
        Image(systemName: "music.note.list")
    }
}

struct WalkingGoalTip: Tip {
    var title: Text {
        Text("Set Your Walking Goal")
    }

    var message: Text? {
        Text("Tap the walking card to adjust your daily step goal. Even 10 minutes of light walking supports circulation and wellbeing.")
    }

    var image: Image? {
        Image(systemName: "figure.walk")
    }
}

struct SymptomDetailTip: Tip {
    var title: Text {
        Text("View Symptom History")
    }

    var message: Text? {
        Text("Tap a logged symptom to see its full history and edit details. Sharing this with your doctor can help track patterns over time.")
    }

    var image: Image? {
        Image(systemName: "waveform.path.ecg")
    }
}
