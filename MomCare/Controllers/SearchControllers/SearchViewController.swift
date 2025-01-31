//
//  SearchViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 31/01/25.
//

import UIKit

class SearchViewController: UIViewController {
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var searchTableView: UITableView!

    let allFoods = SampleFoodData.uniqueFoodItems
    var searchedFood: [FoodItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTable()
        prepareSearchBar()
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func prepareTable() {
        searchTableView.delegate = self
        searchTableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath) as? SearchTableViewCell
        guard let cell else { fatalError("abhi na jao chhordke, ki dil abhi bhara nahi") }
        cell.updateElements(with: searchedFood[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedFood.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension SearchViewController: UISearchBarDelegate {
    func prepareSearchBar() {
        searchBar.delegate = self
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedFood = allFoods.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        searchTableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchedFood = []
        searchTableView.reloadData()
    }
}
