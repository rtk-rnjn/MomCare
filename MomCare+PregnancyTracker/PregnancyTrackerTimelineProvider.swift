//
//  PregnancyTrackerTimelineProvider.swift
//  MomCare
//
//  Created by Ritik Ranjan on 25/07/25.
//

import WidgetKit

struct TriTrackEntry: TimelineEntry {
    let date: Date
    let week: Int
    let day: Int
    let trimester: String
    
    // Totals from MyPlan
    let totalCalories: Double
    let totalCarbs: Double
    let totalFat: Double
    let totalProtein: Double
    
    // Current meal or day totals
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let sodium: Double
    
    // Calories burned fetched from HealthKit
    let caloriesBurned: Double
}

struct PregnancyTrackerTimelineProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> TriTrackEntry {
        return TriTrackEntry(
            date: Date(),
            week: 11,
            day: 4,
            trimester: "I",
            totalCalories: 1800,
            totalCarbs: 220,
            totalFat: 60,
            totalProtein: 60,
            calories: 600,
            protein: 30,
            carbs: 70,
            fat: 20,
            sodium: 500,
            caloriesBurned: 200
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (TriTrackEntry) -> Void) {
        let plan = SharedResourceSync.getMyPlan() ?? MyPlan()
        
        let entry = TriTrackEntry(
            date: Date(),
            week: SharedResourceSync.getWeek(),
            day: SharedResourceSync.getDay(),
            trimester: SharedResourceSync.getTrimester(),
            totalCalories: plan.totalCalories,
            totalCarbs: plan.totalCarbs,
            totalFat: plan.totalFat,
            totalProtein: plan.totalProtien,
            calories: plan.totalCalories, // can customize for per-meal if needed
            protein: plan.totalProtien,
            carbs: plan.totalCarbs,
            fat: plan.totalFat,
            sodium: plan.allMeals().reduce(0) { $0 + $1.sodium },
            caloriesBurned: 0 // placeholder; fetch real value from HealthKit later
        )
        
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @Sendable @escaping (Timeline<TriTrackEntry>) -> Void) {
        let currentDate = Date()
        let plan = SharedResourceSync.getMyPlan() ?? MyPlan()
        
        // Here, you will fetch caloriesBurned from HealthKit asynchronously
        // For now, let's put 0 or a default
        let entry = TriTrackEntry(
            date: currentDate,
            week: SharedResourceSync.getWeek(),
            day: SharedResourceSync.getDay(),
            trimester: SharedResourceSync.getTrimester(),
            totalCalories: plan.totalCalories,
            totalCarbs: plan.totalCarbs,
            totalFat: plan.totalFat,
            totalProtein: plan.totalProtien,
            calories: plan.totalCalories, // can adjust per meal if desired
            protein: plan.totalProtien,
            carbs: plan.totalCarbs,
            fat: plan.totalFat,
            sodium: plan.allMeals().reduce(0) { $0 + $1.sodium },
            caloriesBurned: 0 // fetch from HealthKit
        )
        
        let nextRefresh = Calendar.current.date(byAdding: .hour, value: 6, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
        completion(timeline)
    }
}
