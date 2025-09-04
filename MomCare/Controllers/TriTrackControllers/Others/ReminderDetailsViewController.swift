//

//  ReminderDetailsViewController.swift

//  MomCare

//

//  Created by RITIK RANJAN on 08/06/25.

//

import SwiftUI

import UIKit

class ReminderDetailsViewController: UIHostingController<ReminderDetailsView> {

    // MARK: Lifecycle

    init(reminder: ReminderInfo, cell: UITableViewCell) {

        super.init(rootView: ReminderDetailsView(reminder: reminder, cellWidth: cell.frame.width))

    }

    required init?(coder aDecoder: NSCoder) {

        fatalError("init(coder:) has not been implemented")

    }

    // MARK: Internal

    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()

        preferredContentSize = view.intrinsicContentSize

    }

}
