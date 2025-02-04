//
//  MoodnestViewController.swift
//  MomCare
//
//  Created by Batch - 2  on 16/01/25.
//

import UIKit

class MoodnestViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var emotionsScrollView: UIScrollView!

    @IBOutlet var happyImageView: UIImageView!
    @IBOutlet var sadImageView: UIImageView!
    @IBOutlet var stressedImageView: UIImageView!
    @IBOutlet var angryImageView: UIImageView!

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

    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        if let destinationVC = storyboard?.instantiateViewController(withIdentifier: "genresPageView") as? GenresPageViewController {
            navigationController?.pushViewController(destinationVC, animated: true)
        }
    }
}
