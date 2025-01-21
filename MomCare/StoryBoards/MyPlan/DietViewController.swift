//

//  DietViewController.swift

//  MomCare

//

//  Created by Nupur on 18/01/25.

//

import UIKit

class DietViewController: UIViewController {
    
    @IBOutlet var circularProgressView: CircularProgressView!
    
    
    
    
    
    override func viewDidLoad() {
            super.viewDidLoad()
            
            // Set the initial progress
            circularProgressView.progress = 0.75  // Display 75% progress for testing
        }
    /*

    // MARK: - Navigation



    // In a storyboard-based application, you will often want to do a little preparation before navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // Get the new view controller using segue.destination.

        // Pass the selected object to the new view controller.

    }

    */

}
