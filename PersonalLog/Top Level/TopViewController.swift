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

    private let journal: Journal
    
    private lazy var journalVC: JournalViewController = { JournalViewController(data: journal, routes: journal, userTappedContent: userRequestedChromeChange) }()
    private lazy var historyVC = UINavigationController(rootViewController: journalVC)
    private lazy var toolbarVC: UIViewController = {
        let view = Toolbar(calendarButtonTapped: toggleDayPicker, addButtonTapped: addButtonTapped, shareButtonTapped: shareButtonTapped)
        return UIHostingController(rootView: view)
    }()
    private lazy var dayPickerVC: UIViewController = {
        let view = DayPicker(dayWasChosen: dayWasChosen)
        return UIHostingController(rootView: view)
    }()

    private var toolbar: UIView { toolbarVC.view! }
    private var dayPickerView: UIView { dayPickerVC.view! }
    private var historyView: UIView { historyVC.view! }

    private var dayPickerHidden: NSLayoutConstraint!
    private var toolbarHidden: NSLayoutConstraint!

    private var subscriptions = Set<AnyCancellable>()
        
    // MARK: - 
    
    init(journal: Journal) {
        self.journal = journal
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        [toolbarVC, dayPickerVC, historyVC].forEach { add(viewController: $0) }
        
        layoutChildren()

        listenForKeyboardEvents()
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // if we start up in landscape mode, we want to have the chrome look as expected
        orientationChanged(animated: false)
    }
    
    // MARK: - Layout
    
    private func layoutChildren() {
        
        [toolbar, dayPickerView, historyView]
            .forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
            }

        // if the contents of the toolbar grow outside its frame
        // they should overlay other content (e.g. the table view)
        toolbar.layer.zPosition = 1000
        
        toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        toolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        toolbarHidden = toolbar.heightAnchor.constraint(equalToConstant: toolbar.intrinsicContentSize.height)
        toolbarHidden.isActive = false
        
        dayPickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        dayPickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        dayPickerView.bottomAnchor.constraint(equalTo: toolbar.topAnchor).isActive = true
        dayPickerHidden = dayPickerView.heightAnchor.constraint(equalToConstant: 0)
        dayPickerHidden.isActive = true
        dayPickerView.layer.opacity = 0
        
        historyVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        historyVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        historyVC.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        historyVC.view.bottomAnchor.constraint(equalTo: dayPickerView.topAnchor).isActive = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        orientationChanged(animated: true)
    }

    private func orientationChanged(animated: Bool) {
        guard UIDevice.current.userInterfaceIdiom != .pad else { return }
        
        // Landscape orientation is for reading only
        // portrait is for reading OR editing
        
        // we don't want to show extra chrome when in landscape even on larger phones
        // that don't report a compact size class for landscape orientation,
        // so we don't look at size classes, just frame size
        let inLandscape = view.frame.size.width > view.frame.size.height
        if inLandscape && toolbarVisible ||
            !inLandscape && !toolbarVisible {
            
            // need the delay to deal with keyboard-watching code
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                self.toggleToolbar(animated: animated)
            }
        }
        
        if inLandscape && dayPickerVisible {
            toggleDayPicker()
        }
        
        historyVC.setNavigationBarHidden(inLandscape, animated: false)
    }
    
    // MARK: - Day Picker
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
        
        journalVC.scrollToEntriesforDay(of: day, animated: true)
    }
    
    // MARK: - Toolbar
    
    ///  The UI can either be chrome heavy (with any of toolbar, day picker, searchbar, etc.) or light (with all of that hidden)
    ///  This method is called when the user has done something to indicate that she wants to switch between these modes
    private func userRequestedChromeChange() {
        guard !dayPickerVisible else {
            toggleDayPicker()
            return
        }
        
        self.journalVC.hideSearchChromeIfNoSearchString()

        toggleToolbar(animated: true)
    }
    
    private var toolbarVisible: Bool { !toolbarHidden.isActive }
    private func toggleToolbar(animated: Bool) {
        
        self.toolbarHidden.isActive.toggle()
        
        UIView.animate(withDuration: animated ? 0.4 : 0, delay: 0) {
            self.view.layoutSubviews()
            self.toolbar.layer.opacity = self.toolbarHidden.isActive ? 0 : 1
        }
    }

    // MARK: - Responding to user input
    
    private func addButtonTapped() {
        setDayPickerVisible(false)
        journalVC.showNewEntryChrome()
    }

    private func searchButtonTapped() {
        setDayPickerVisible(false)
        journalVC.showSearchChrome()
    }

    private func shareButtonTapped() {
        Task {
            let summary = await journal.loadSummary()
            DispatchQueue.main.async { [weak self] in
                self?.share(summary)
            }
        }
    }

    // MARK: - Sharing
    
    private func share(_ string: String) {
        let vc = UIActivityViewController(activityItems: [string], applicationActivities: [])
        present(vc, animated: true)
    }
    
    // MARK: - TopViewController: Listening for Keyboard

    private func listenForKeyboardEvents() {
        // on iPad, the keyboard doesn't take up nearly as much space proportionally,
        // so we don't have to worry about this
        guard UIDevice.current.userInterfaceIdiom != .pad else { return }

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification).sink(receiveValue: keyboardWillAppear)
        .store(in: &subscriptions)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification).sink(receiveValue: keyboardWillDisappear)
        .store(in: &subscriptions)
    }

    private func keyboardWillAppear(_ unused: Any) {
        toolbarHidden.isActive = true
        toolbar.layer.opacity = 0
    }
    
    private func keyboardWillDisappear(_ unused: Any) {
        toolbarHidden.isActive = false
        toolbar.layer.opacity = 1
    }
}

// MARK: - UIViewController: Child View Controllers

extension UIViewController {
    func add(viewController: UIViewController) {
        viewController.willMove(toParent: self)
        self.addChild(viewController)
        self.view.addSubview(viewController.view)
        
        viewController.didMove(toParent: self)
    }
}
