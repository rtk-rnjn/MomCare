//
//  SearchViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 31/01/25.
//

import UIKit

actor Debouncer {

    // MARK: Internal

    func run(delay: TimeInterval, action: @escaping @Sendable () async -> Void) {
        currentTask?.cancel()
        currentTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            guard !Task.isCancelled else { return }
            await action()
        }
    }

    // MARK: Private

    private var currentTask: Task<Void, Never>?

}

class SearchViewController: UIViewController, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {

    // MARK: Internal

    @IBOutlet var tableView: UITableView!

    var searchBarController: UISearchController = .init()

    var completionHandlerOnFoodItemAdd: (() -> Void)?

    var searchedFood: [FoodItem] = .init()

    var mealName: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.searchController = searchBarController
        searchBarController.searchResultsUpdater = self

        searchBarController.delegate = self
        searchBarController.searchBar.delegate = self

        searchBarController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true

        prepareTable()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        searchBarController.isActive = true

        DispatchQueue.main.async {
            self.searchBarController.searchBar.becomeFirstResponder()
            self.searchBarController.becomeFirstResponder()
        }
    }

    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""

        Task {
            await debouncer.run(delay: 0.5) {
                await self.searchFood(query: searchText)
            }
        }
    }

    @objc func refresh() {
        Task {
            let searchText = searchBarController.searchBar.text ?? ""
            await searchFood(query: searchText)

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchedFood = .init()
        tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        searchedFood = .init()
        tableView.reloadData()
    }

    // MARK: Private

    private var debouncer: Debouncer = .init()

    private func searchFood(query: String) async {
        searchedFood = .init()

        if query.isEmpty {
            return
        }

        await ContentHandler.shared.searchStreamedFoodName(with: query) { foodItem in
            DispatchQueue.main.async {
                self.searchedFood.append(foodItem)
                self.tableView.reloadData()

//                self.fetchImage(for: foodItem)
            }
        }
    }

    private func fetchImage(for foodItem: FoodItem) {
        // TODO: Implement image fetching logic if needed
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func prepareTable() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath) as? SearchTableViewCell
        guard let cell else { fatalError("abhi na jao chhordke, ki dil abhi bhara nahi") }
        cell.updateElements(with: searchedFood[indexPath.row], sender: self)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedFood.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
