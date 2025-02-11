//
//  AppointmentsTableViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 17/01/25.
//

import UIKit
import EventKit

class AppointmentsTableViewController: UITableViewController {

    // MARK: Internal

    var data: [EKEvent] = []
    let store: EKEventStore = .init()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AppointmentCell", for: indexPath) as? AppointmentsTableViewCell

        guard let cell else { fatalError("mere rang me rangne wali 🎶") }

        cell.updateElements(with: data[indexPath.section])
        cell.showsReorderControl = false

        // config as per prototype. not my fault
        cell.backgroundColor = Converters.convertHexToUIColor(hex: "F2F2F7")
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.masksToBounds = true
        cell.clipsToBounds = true

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 3
    }

    func refreshData() {
        data = fetchEvents()
        tableView.reloadData()
    }

    // MARK: Private

    private func fetchEvents() -> [EKEvent] {
        let store = EKEventStore()

        let startDate = Calendar.current.startOfDay(for: Date())
        let endDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate)!
        let ekCalendars = getCalendar(with: "TriTrackEvent")

        let predicate = store.predicateForEvents(withStart: startDate, end: endDate, calendars: ekCalendars)
        return store.events(matching: predicate)
    }

    private func getCalendar(with identifierKey: String) -> [EKCalendar]? {
        if let identifier = UserDefaults.standard.string(forKey: identifierKey), let calendar = store.calendar(withIdentifier: identifier) {
            return [calendar]
        }

        return []
    }

}
