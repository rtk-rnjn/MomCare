//
//  GenresPageViewController.swift
//  MomCare
//
//  Created by Batch - 2  on 17/01/25.
//

import UIKit

class GenresPageViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage(systemName: "Happy") // Use your desired image here
        let barButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(rightBarButtonTapped))
        
        self.navigationItem.rightBarButtonItem = barButtonItem
    }
    
    @objc func rightBarButtonTapped() {
           // Action when the button is tapped
           print("Right navigation bar button tapped!")
       }
}
