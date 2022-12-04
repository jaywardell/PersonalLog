//
//  TopViewController.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/4/22.
//

import UIKit
import SwiftUI

class TopViewController: UITabBarController {

    private let journalVC = JournalViewController(style: .grouped)
    private lazy var historyVC = UINavigationController(rootViewController: journalVC)
    private lazy var journalEntryVC = UIHostingController(rootView: JournalEntryView())
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.isHidden = true
        
        self.viewControllers = [journalEntryVC, historyVC]
    }
}
