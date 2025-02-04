//
//  MoodnestViewController.swift
//  MomCare
//
//  Created by Batch - 2  on 16/01/25.
//

import UIKit

class MoodnestViewController: UIViewController {
    
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet weak var happyImageView: UIImageView!
    @IBOutlet weak var sadImageView: UIImageView!
    @IBOutlet weak var stressedImageView: UIImageView!
    @IBOutlet weak var angryImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        happyImageView.isUserInteractionEnabled = true
        sadImageView.isUserInteractionEnabled = true
        stressedImageView.isUserInteractionEnabled = true
        angryImageView.isUserInteractionEnabled = true
        
        addTapGesture(to: happyImageView)
        addTapGesture(to: sadImageView)
        addTapGesture(to: stressedImageView)
        addTapGesture(to: angryImageView)

    }
    
    func addTapGesture(to imageView: UIImageView) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        imageView.addGestureRecognizer(tapGesture)
    }
    
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        if let destinationVC = storyboard?.instantiateViewController(withIdentifier: "genresPageView") as? GenresPageViewController {
            navigationController?.pushViewController(destinationVC, animated: true)
        }
    }
}
