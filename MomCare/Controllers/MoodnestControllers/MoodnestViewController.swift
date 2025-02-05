//
//  MoodnestViewController.swift
//  MomCare
//
//  Created by Batch - 2  on 16/01/25.
//

import UIKit

class MoodnestViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet weak var emotionsScrollView: UIScrollView!
    
    @IBOutlet weak var happyImageView: UIImageView!
    @IBOutlet weak var sadImageView: UIImageView!
    @IBOutlet weak var stressedImageView: UIImageView!
    @IBOutlet weak var angryImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emotionsScrollView.delegate = self
        emotionsScrollView.isPagingEnabled = true
        pageControl.numberOfPages = 4
        pageControl.currentPage = 0
        
        happyImageView.isUserInteractionEnabled = true
        sadImageView.isUserInteractionEnabled = true
        stressedImageView.isUserInteractionEnabled = true
        angryImageView.isUserInteractionEnabled = true
        
        addTapGesture(to: happyImageView)
        addTapGesture(to: sadImageView)
        addTapGesture(to: stressedImageView)
        addTapGesture(to: angryImageView)

    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(emotionsScrollView.contentOffset.x / emotionsScrollView.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
    
    func addTapGesture(to imageView: UIImageView) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        imageView.addGestureRecognizer(tapGesture)
    }
    
//    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
//        if let destinationVC = storyboard?.instantiateViewController(withIdentifier: "genresPageView") as? GenresPageViewController {
//            navigationController?.pushViewController(destinationVC, animated: true)
//        }
//    }
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        if let tappedImageView = sender.view as? UIImageView {
            performSegue(withIdentifier: "ShowGenres", sender: tappedImageView)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowGenres" {
            if let destination = segue.destination as? GenresPageViewController,
               let selectedImageView = sender as? UIImageView {
                destination.IconImageVar = selectedImageView.image
            }
        }
    }
}
