//
//  TopViewController.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/4/22.
//

import UIKit
import SwiftUI

class TopViewController: UIViewController {

    private let logic = Journal()
    private lazy var journalVC: JournalViewController = { JournalViewController(data: logic, routes: logic) }()
    private lazy var historyVC = UINavigationController(rootViewController: journalVC)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let toolbar = UIView()
        toolbar.backgroundColor = .purple
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)
        
        toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        toolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        toolbar.heightAnchor.constraint(equalToConstant: 100).isActive = true

        
        historyVC.willMove(toParent: self)
        self.addChild(historyVC)
        historyVC.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(historyVC.view)
        
        historyVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        historyVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        historyVC.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        historyVC.view.bottomAnchor.constraint(equalTo: toolbar.topAnchor).isActive = true

        historyVC.didMove(toParent: self)
    }
}
