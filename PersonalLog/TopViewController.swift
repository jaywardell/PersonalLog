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
    private lazy var journalEntryVC = UIHostingController(rootView: JournalEntryView(viewModel: .init(cancel: {}, save: {})))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.isHidden = true
        
        self.viewControllers = [journalEntryVC, historyVC]
        
        showJournalEntry()
    }
    
    private let journalEntryIndex = 1
    private let journalIndex = 2
    
    public func showJournal() {
        self.selectedIndex = journalIndex
    }
    
    public func showJournalEntry() {
        self.selectedIndex = journalEntryIndex
    }
}
