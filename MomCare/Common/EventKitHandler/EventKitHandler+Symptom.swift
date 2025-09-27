//
//  EventKitHandler+Symptom.swift
//  MomCare
//
//  Created by Aryan Singh on 17/09/25.
//

import Foundation
import RealmSwift
import EventKit

extension EventKitHandler {
    func fetchSymptoms(startDate: Date? = nil, endDate: Date? = nil) -> [EventInfo] {
        guard let startDate, let endDate else {
            return fetchAllSymptoms()
        }
        let events: [EKEventSymptoms]? = try? fetchSymptoms(startDate: startDate, endDate: endDate)
        return events?.compactMap { fetchEKEvent(fromEventIdentifier: $0.eventIdentifier) } ?? []
    }

    @discardableResult
    func createSymptom(title: String, startDate: Date, endDate: Date, notes: String? = nil) -> EventInfo? {
        guard let event = createEvent(title: title, startDate: startDate, endDate: endDate, notes: notes) else {
            return nil
        }

        let symptom = EKEventSymptoms()
        symptom.eventIdentifier = event.eventIdentifier
        symptom.title = event.title
        symptom.calendarItemIdentifier = event.calendarItemIdentifier
        symptom.startDate = event.startDate
        symptom.endDate = event.endDate

        try? saveSymptom(symptom)

        return event
    }

    func fetchAllSymptoms() -> [EventInfo] {
        let symptoms: [EKEventSymptoms]? = try? fetchAllSymptoms()
        return symptoms?.compactMap { fetchEKEvent(fromEventIdentifier: $0.eventIdentifier) } ?? []

    }

    private func saveSymptom(_ symptom: EKEventSymptoms) throws {
        let realm = try Realm()
        try realm.write {
            realm.add(symptom, update: .all)
        }
    }

    private func fetchAllSymptoms() throws -> [EKEventSymptoms] {
        let realm = try Realm()
        return realm.objects(EKEventSymptoms.self).map(\.self)
    }

    private func fetchSymptoms(startDate: Date, endDate: Date) throws -> [EKEventSymptoms] {
        let realm = try Realm()

        return realm.objects(EKEventSymptoms.self).filter("startDate >= %@ AND endDate <= %@", startDate as NSDate, endDate as NSDate).map(\.self)
    }

    private func fetchSymptom(eventIdentifier: String) throws -> EKEventSymptoms? {
        let realm = try Realm()
        let results = realm.objects(EKEventSymptoms.self).filter("eventIdentifier == %@", eventIdentifier)
        return results.first
    }

    private func deleteSymptom(eventIdentifier: String) throws {
        let realm = try Realm()
        try realm.write {
            realm.delete(realm.objects(EKEventSymptoms.self).filter("eventIdentifier == %@", eventIdentifier))
        }
    }

    private func fetchEKEvent(fromEventIdentifier eventIdentifier: String) -> EventInfo? {
        guard let event = eventStore.event(withIdentifier: eventIdentifier) else {
            try? deleteSymptom(eventIdentifier: eventIdentifier)
            return nil
        }

        return getEventInfo(from: event)
    }
}
