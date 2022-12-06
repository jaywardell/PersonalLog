//
//  TopViewController.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/4/22.
//

import UIKit
import SwiftUI

class TopViewController: UITabBarController {

    private let logic = Journal()
    private lazy var journalVC: JournalViewController = { JournalViewController(data: logic, routes: logic) }()
    private lazy var historyVC = UINavigationController(rootViewController: journalVC)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.isHidden = true
        
        self.viewControllers = [historyVC]
    }
}
