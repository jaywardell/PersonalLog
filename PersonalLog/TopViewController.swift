//
//  TopViewController.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/4/22.
//

import UIKit
import SwiftUI

class TopViewController: UITabBarController {

    private let journalVC = JournalViewController(routes: Routes())
    private lazy var historyVC = UINavigationController(rootViewController: journalVC)
    private lazy var journalEntryVC = UIHostingController(rootView: JournalEntryEditor(viewModel: .init(mood: "😀", title: "", prompt: "How was the weather today?", text: "sunny", tags: ["happy", "weather"], save: { _ in })))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.isHidden = true
        
        self.viewControllers = [journalEntryVC, historyVC]
        
        showJournal()
    }
    
    private let journalEntryIndex = 0
    private let journalIndex = 1
    
    public func showJournal() {
        self.selectedIndex = journalIndex
    }
    
    public func showJournalEntry() {
        self.selectedIndex = journalEntryIndex
    }
}
