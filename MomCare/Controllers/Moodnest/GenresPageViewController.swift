//
//  GenresPageViewController.swift
//  MomCare
//
//  Created by Batch - 2  on 17/01/25.
//

import UIKit

class GenresPageViewController: UIViewController, UICollectionViewDataSource {
   
    
    @IBOutlet weak var MoodnestCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationBar = UINavigationBar()
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navigationBar)
        
        let image = UIImage(systemName: "Happy") // Use your desired image here
        let barButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(rightBarButtonTapped))
        
        self.navigationItem.rightBarButtonItem = barButtonItem
        navigationBar.items = [navigationItem]
        
        MoodnestCollectionView.register(UINib(nibName: "MainImage", bundle: nil), forCellWithReuseIdentifier: "MainImage")
        MoodnestCollectionView.register(UINib(nibName: "MoodNestMultipleImages", bundle: nil), forCellWithReuseIdentifier: "MoodNestMultipleImages")
        
        MoodnestCollectionView.delegate = self
        MoodnestCollectionView.dataSource = self
        MoodnestCollectionView.collectionViewLayout = MoodnestLayout()
        
        
    }
    
    @objc func rightBarButtonTapped() {
           // Action when the button is tapped
           print("Right navigation bar button tapped!")
       }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        <#code#>
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
    }
    
}

