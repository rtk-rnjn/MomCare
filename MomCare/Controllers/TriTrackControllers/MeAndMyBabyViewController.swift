//
//  MeAndMyBabyViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 17/01/25.
//

import UIKit

class MeAndMyBabyViewController: UIViewController {
    @IBOutlet var trimesterLabel: UILabel!
    @IBOutlet var weekDayLabel: UILabel!
    @IBOutlet var quoteLabel: UILabel!
    @IBOutlet var literalHeightLabel: UILabel!
    @IBOutlet var heightLabel: UILabel!
    @IBOutlet var literalWeightLabel: UILabel!
    @IBOutlet var weightLabel: UILabel!

    func prepareImageView(for imageView: UIImageView) {
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let pregnancyData = Utils.pregnancyWeekAndDay(dueDate: MomCareUser.shared.user?.medicalData?.dueDate ?? Date())
        guard let pregnancyData else { return }
        guard let data = TriTrackData.getTrimesterData(for: pregnancyData.week) else { return }
        
        updateElements(with: data)
    }
    
    func updateElements(with data: TrimesterData) {
        trimesterLabel.text = "Trimester \(data.trimesterNumber)"
        weekDayLabel.text = "Week \(data.weekNumber) - Day \(data.dayNumber)"
        quoteLabel.text = data.quote
        heightLabel.text = "\(data.babyHeightInCentimeters) cm"
        weightLabel.text = "\(data.babyWeightInKilograms) kg"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue.identifier ?? "NO IDENTIFIER")
    }
}
