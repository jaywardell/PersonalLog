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
    
    private var dayPickerHidden: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let topbar = Toolbar(searchButtonTapped: {}, calendarButtonTapped: toggleDayPicker
                             , tagsButtonTapped: {}, addButtonTapped: journalVC.createNewEntry)
        let topBarVC = UIHostingController(rootView: topbar)
        let toolbar = topBarVC.view!
        
        // if the contents of the toolbar grow outside its frame
        // they should overlay other content (e.g. the table view)
        toolbar.layer.zPosition = 1000
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)
        
        toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        toolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        let dayPicker = DayPicker(dayWasChosen: dayWasChosen)
        let dayPickerVC = UIHostingController(rootView: dayPicker)
        let dayPickerView = dayPickerVC.view!
        dayPickerVC.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dayPickerView)
        
        dayPickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        dayPickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        dayPickerView.bottomAnchor.constraint(equalTo: toolbar.topAnchor).isActive = true
        dayPickerHidden = dayPickerView.heightAnchor.constraint(equalToConstant: 0)
        dayPickerHidden.isActive = true

        historyVC.willMove(toParent: self)
        self.addChild(historyVC)
        historyVC.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(historyVC.view)
        
        historyVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        historyVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        historyVC.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        historyVC.view.bottomAnchor.constraint(equalTo: dayPickerView.topAnchor).isActive = true

        historyVC.didMove(toParent: self)
    }
    
    private var dayPickerVisible: Bool { !dayPickerHidden.isActive }
    private func setDayPickerVisible(_ visible: Bool) {
        dayPickerHidden.isActive = !visible
        
        view.setNeedsUpdateConstraints()

        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0) {
            self.view.layoutIfNeeded()
        }
    }
    private func toggleDayPicker() {
        setDayPickerVisible(!dayPickerVisible)
    }
    
    private func dayWasChosen(_ day: Date) {
        setDayPickerVisible(false)
        
        print(day)
    }
}
