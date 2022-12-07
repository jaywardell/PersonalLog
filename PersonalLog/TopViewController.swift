//
//  TopViewController.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/4/22.
//

import UIKit
import SwiftUI
import Combine

class TopViewController: UIViewController {

    
    private let logic = Journal()
    private lazy var journalVC: JournalViewController = { JournalViewController(data: logic, routes: logic, userTappedContent: toggleToolbar) }()
    private lazy var historyVC = UINavigationController(rootViewController: journalVC)
    
    private var dayPickerHidden: NSLayoutConstraint!
    private var toolbarHidden: NSLayoutConstraint!

    private var subscriptions = Set<AnyCancellable>()
    
    private var toolbar: UIView!
    private var dayPickerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.tintColor = .systemOrange
        view.backgroundColor = .systemBackground
        
        let topbar = Toolbar(searchButtonTapped: searchButtonTapped, calendarButtonTapped: toggleDayPicker, addButtonTapped: addButtonTapped)
        let topBarVC = UIHostingController(rootView: topbar)
        let toolbar = topBarVC.view!
        self.toolbar = toolbar
        
        // if the contents of the toolbar grow outside its frame
        // they should overlay other content (e.g. the table view)
        toolbar.layer.zPosition = 1000
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)
        
        toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        toolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        toolbarHidden = toolbar.heightAnchor.constraint(equalToConstant: toolbar.intrinsicContentSize.height)
        toolbarHidden.isActive = false

        let dayPicker = DayPicker(dayWasChosen: dayWasChosen)
        let dayPickerVC = UIHostingController(rootView: dayPicker)
        self.dayPickerView = dayPickerVC.view!
        dayPickerVC.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dayPickerView)
        
        dayPickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        dayPickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        dayPickerView.bottomAnchor.constraint(equalTo: toolbar.topAnchor).isActive = true
        dayPickerHidden = dayPickerView.heightAnchor.constraint(equalToConstant: 0)
        dayPickerHidden.isActive = true
        dayPickerView.layer.opacity = 0

        historyVC.willMove(toParent: self)
        self.addChild(historyVC)
        historyVC.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(historyVC.view)
        
        historyVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        historyVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        historyVC.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        historyVC.view.bottomAnchor.constraint(equalTo: dayPickerView.topAnchor).isActive = true

        historyVC.didMove(toParent: self)
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification).sink(receiveValue: keyboardWillAppear)
        .store(in: &subscriptions)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification).sink(receiveValue: keyboardWillDisappear)
        .store(in: &subscriptions)
    }
    
    private var dayPickerVisible: Bool { !dayPickerHidden.isActive }
    private func setDayPickerVisible(_ visible: Bool) {
        dayPickerHidden.isActive = !visible
        
        if visible {
            dayPickerView.layer.opacity = 1
        }
        
        view.setNeedsUpdateConstraints()

        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            if !visible {
                self.dayPickerView.layer.opacity = 0
            }
        }
    }
    private func toggleDayPicker() {
        setDayPickerVisible(!dayPickerVisible)
    }
    
    private func dayWasChosen(_ day: Date) {
        setDayPickerVisible(false)
        
        journalVC.scrollToEntriesforDay(of: day)
    }
    
    private func keyboardWillAppear(_ unused: Any) {
        toolbarHidden.isActive = true
        toolbar.layer.opacity = 0
    }
    
    private func keyboardWillDisappear(_ unused: Any) {
        toolbarHidden.isActive = false
        toolbar.layer.opacity = 1
    }
    
    private func toggleToolbar() {
        guard !dayPickerVisible else {
            toggleDayPicker()
            return
        }
        
        self.journalVC.hideSearchChromeIfNoSearchString()

        self.toolbarHidden.isActive.toggle()
        
        UIView.animate(withDuration: 0.4, delay: 0) {
            self.view.layoutSubviews()
            self.toolbar.layer.opacity = self.toolbarHidden.isActive ? 0 : 1
        }
    }

    private func addButtonTapped() {
        setDayPickerVisible(false)
        journalVC.showNewEntryChrome()
    }

    private func searchButtonTapped() {
        setDayPickerVisible(false)
        journalVC.showSearchChrome()
    }
}
