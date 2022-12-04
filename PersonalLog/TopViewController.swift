//
//  TopViewController.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/4/22.
//

import UIKit

class TopViewController: UITabBarController {

    private let journalVC = JournalViewController(style: .grouped)
    private lazy var historyVC = UINavigationController(rootViewController: journalVC)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.isHidden = true
        
        self.viewControllers = [historyVC]
    }
}
