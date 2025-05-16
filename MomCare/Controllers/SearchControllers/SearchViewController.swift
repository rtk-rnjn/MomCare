//
//  SearchViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 31/01/25.
//

import UIKit

class SearchViewController: UIViewController, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {

    // MARK: Internal

    @IBOutlet var tableView: UITableView!

    var searchBarController: UISearchController = .init()
    var refreshControl: UIRefreshControl = .init()

    var completionHandlerOnFoodItemAdd: (() -> Void)?

    var searchedFood: [FoodItem] = []

    var mealName: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.searchController = searchBarController
        searchBarController.searchResultsUpdater = self

        searchBarController.delegate = self
        searchBarController.searchBar.delegate = self

        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)

        prepareTable()
    }

    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""

        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(0.7) * 1_000_000_000)
            await searchFood(query: searchText)

            DispatchQueue.main.async {
                self.tableView.reloadData()
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

        refreshControl.endRefreshing()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchedFood = []
        tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        searchedFood = []
        tableView.reloadData()
    }

    // MARK: Private
    private var debounceTask: Task<Void, Never>?

    private func searchFood(query: String) async {
        guard !query.isEmpty else {
            searchedFood = []
            return
        }

        searchedFood = await MomCareAgents.shared.searchFoods(with: query)
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedFood.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
