//

//  DashboardViewController.swift

//  MomCare

//

//  Created by Batch-2 on 15/01/25.

//

import UIKit

import UserNotifications

import EventKit

class DashboardViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {

    // MARK: Internal

    @IBOutlet var collectionView: UICollectionView!

    var addEventTableViewController: AddEventTableViewController?

    var profileButton: UIButton?

    var dataFetched: Bool = false

    var tip: Tip?

    override func viewDidLoad() {

        super.viewDidLoad()

        Task {

            await HealthKitHandler.shared.requestAccess()

            await requestAccessForNotification()

            await self.loadUser()

            if let user = MomCareUser.shared.user {

                self.tip = await ContentHandler.shared.fetchTips(from: user)

                DispatchQueue.main.async {

                    self.dataFetched = true

                    self.collectionView.reloadData()

                }

            }

        }

    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        prepareElements()

        collectionView.reloadItems(at: [IndexPath(row: 0, section: 1)])

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "segueShowAddEventTableViewController", let navigationController = segue.destination as? UINavigationController {

            let addEventTableViewController = navigationController.viewControllers.first as? AddEventTableViewController

            self.addEventTableViewController = addEventTableViewController

            addEventTableViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAddEvent))

            addEventTableViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAddEvent))

        }

        if segue.identifier == "segueShowProfilePageTableViewController", let navigationController = segue.destination as? UINavigationController {

            let profilePageTableViewController = navigationController.viewControllers.first as? ProfilePageTableViewController

            profilePageTableViewController?.logoutHandler = navigateToFrontPageViewController

        }

    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {

        return 3

    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return 2

    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeaderView", for: indexPath) as? DashboardSectionHeaderCollectionViewCell

        guard let cell else { fatalError() }

        cell.titleLabel.startShimmer()

        if !dataFetched {

            cell.titleLabel.text = "Loading..."

            return cell

        }

        cell.titleLabel.stopShimmer()

        cell.titleLabel.text = (indexPath.section == 2) ? "Daily Insights" : "Progress"

        return cell

    }

    @IBAction func unwinToDashboard(_ segue: UIStoryboardSegue) {}

    func setupProfileButton() {

        guard let navigationBar = navigationController?.navigationBar else { return }

        let customView = UIView()

        customView.backgroundColor = .clear

        let profileBtn = UIButton(type: .system)

        // Set symbol config for larger icon

        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)

        if let profileImage = UIImage(systemName: "person.crop.circle.fill", withConfiguration: config)?.withRenderingMode(.alwaysTemplate) {

            profileBtn.setImage(profileImage, for: .normal)

        }

        profileBtn.tintColor = UIColor(hex: "#924350")

        profileBtn.addTarget(self, action: #selector(profileIconTapped), for: .touchUpInside)

        profileBtn.imageView?.contentMode = .scaleAspectFit

        profileBtn.contentHorizontalAlignment = .fill

        profileBtn.contentVerticalAlignment = .fill

        customView.addSubview(profileBtn)

        navigationBar.addSubview(customView)

        profileBtn.translatesAutoresizingMaskIntoConstraints = false

        customView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            customView.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor, constant: -16), customView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -10), customView.widthAnchor.constraint(equalToConstant: 40), customView.heightAnchor.constraint(equalToConstant: 40), profileBtn.centerXAnchor.constraint(equalTo: customView.centerXAnchor), profileBtn.centerYAnchor.constraint(equalTo: customView.centerYAnchor), profileBtn.widthAnchor.constraint(equalToConstant: 36), profileBtn.heightAnchor.constraint(equalToConstant: 36)

        ])

        profileButton = profileBtn

    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let offsetY = scrollView.contentOffset.y

        if offsetY > 0 {

            hideProfileButton()

        } else {

            showProfileButton()

        }

    }

    @objc func profileIconTapped() {

        performSegue(withIdentifier: "segueShowProfilePageTableViewController", sender: nil)

    }

    func navigateToFrontPageViewController() {

        if let initialTabBarViewController = tabBarController as? InitialTabBarController {

            initialTabBarViewController.performSegue(withIdentifier: "segueShowFrontPageNavigationController", sender: nil)

        }

    }

    // MARK: Private

    private let refreshControl: UIRefreshControl = .init()

    private let cellIdentifiers = ["WeekCard", "EventCard", "DietProgress", "ExerciseProgress", "FocusCard", "TipCard"]

    private let headerIdentifier = "SectionHeaderView"

    private let interItemSpacing: CGFloat = 15

    private func prepareElements() {

        prepareCollectionView()

        collectionView.showsVerticalScrollIndicator = false

        collectionView.alwaysBounceVertical = true

        collectionView.refreshControl = refreshControl

        collectionView.delegate = self

        navigationController?.navigationBar.prefersLargeTitles = true

        setupProfileButton()

        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)

    }

    @objc private func didPullToRefresh(_ sender: Any) {

        refreshControl.beginRefreshing()

        Task {

            await loadUser()

            DispatchQueue.main.async {

                self.collectionView.reloadData()

                self.refreshControl.endRefreshing()

            }

        }

    }

    private func loadUser() async {

        await MomCareUser.shared.automaticFetchUserFromDatabase()

    }

    private func prepareCollectionView() {

        registerCells()

        collectionView.collectionViewLayout = createLayout()

        collectionView.delegate = self

        collectionView.dataSource = self

    }

    private func registerCells() {

        for cell in cellIdentifiers {

            collectionView.register(UINib(nibName: cell, bundle: nil), forCellWithReuseIdentifier: cell)

        }

        collectionView.register(UINib(nibName: headerIdentifier, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)

    }

    @objc private func cancelAddEvent() {

        dismiss(animated: true)

    }

    @objc private func doneAddEvent() {

        guard let eventTVC = addEventTableViewController, let title = eventTVC.titleField.text else { return }

        let recurrenceRules = eventTVC.selectedRepeatOption.map { TriTrackViewController.createRecurrenceRule(for: $0) }

        let alarm = eventTVC.selectedAlertTimeOption.map { EKAlarm(relativeOffset: -$0) }

        let startDate = eventTVC.startDateTimePicker.date

        let endDate = eventTVC.allDaySwitch.isOn ? startDate : eventTVC.endDateTimePicker.date.addingTimeInterval(eventTVC.selectedTravelTimeOption ?? 0)

        Task {

            await EventKitHandler.shared.createEvent(

                title: title, startDate: startDate, endDate: endDate, isAllDay: eventTVC.allDaySwitch.isOn, notes: nil, recurrenceRules: recurrenceRules, location: eventTVC.locationField.text, alarm: alarm

            )

            DispatchQueue.main.async {

                self.dismiss(animated: true) {

                    self.collectionView.reloadSections([1])

                }

            }

        }

    }

    private func hideProfileButton() {

        if let profileBtn = profileButton {

            profileBtn.alpha = 0

        }

    }

    private func showProfileButton() {

        if let profileBtn = profileButton {

            UIView.animate(withDuration: 0.5) {

                profileBtn.alpha = 1

            }

        }

    }

}

extension DashboardViewController {

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {

        for indexPath in indexPaths {

            if let contextMenu = contextMenu(indexPath) {

                return contextMenu

            }

        }

        return nil

    }

    private func contextMenuForEventCard(_ indexPath: IndexPath) -> UIContextMenuConfiguration? {

        if let previewProvider = previewProvider(for: indexPath, sender: nil) {

            return UIContextMenuConfiguration(previewProvider: previewProvider) { _ in

                return UIMenu(children: [

                    UIAction(title: "View event in calendar", image: UIImage(systemName: "calendar")) { _ in

                        Task {

                            guard let event = await EventKitHandler.shared.fetchUpcomingAppointment() else { return }

                            let startDate = event.startDate

                            let interval = startDate?.timeIntervalSinceReferenceDate

                            guard let interval else { return }

                            DispatchQueue.main.async {

                                if let url = URL(string: "calshow:\(interval)") {

                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)

                                }

                            }

                        }

                    }

                ])

            }

        }

        return nil

    }

    private func contextMenu(_ indexPath: IndexPath) -> UIContextMenuConfiguration? {

        if indexPath.section == 0 && indexPath.row == 1 {

            return contextMenuForEventCard(indexPath)

        }

        return nil

    }

    private func previewProvider(for indexPath: IndexPath, sender: Any?) -> (() -> UIViewController?)? {

        if indexPath.section == 0 && indexPath.row == 1 {

            return {

                let cell = self.collectionView.cellForItem(at: indexPath) as? EventCardCollectionViewCell

                if let cell {

                    return EventDetailsViewController(cell: cell)

                }

                return nil

            }

        }

        return nil

    }

}
