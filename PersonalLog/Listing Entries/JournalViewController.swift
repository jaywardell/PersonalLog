//
//  JournalViewController.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/4/22.
//

import UIKit
import SwiftUI

protocol JournalData: ObservableObject {
    
    var searchString: String { get set }
    
    var days: [Date] { get }
    func entryIDs(for date: Date) -> [any Equatable]
    
    func entryViewModelForCell(id: any Equatable) -> JournalEntryCell.ViewModel
    
    func entryViewModelForEditing(id: any Equatable) -> JournalViewController.ViewModel
}

protocol JournalRoutes {
    func creatNewEntry(from viewModel: JournalEntryEditor.ViewModel)
    func updateEntry(id: any Equatable, from viewModel: JournalEntryEditor.ViewModel)
    func deleteEntry(id: any Equatable)
}

// MARK: -

class JournalViewController: UITableViewController {
    
    struct ViewModel {
        
        let date: Date
        
        // tends to be an emoji, only 1 character long
        let mood: String
        
        // empty by default
        let title: String
        
        // empty by default
        let prompt: String
        
        // empty for new entries
        let text: String
        
        let tags: [String]
    }

    let routes: any JournalRoutes
    let data: any JournalData
    
    let userTappedContent: ()->()
    
    private let searchController: UISearchController = {
        let out = UISearchController(searchResultsController: nil)
        out.obscuresBackgroundDuringPresentation = false
        out.searchBar.placeholder = "Search"
        out.isActive = true
        out.searchBar.searchTextField.autocapitalizationType = .none
        
        return out
    }()
    
    init(data: any JournalData, routes: any JournalRoutes, userTappedContent: @escaping ()->()) {

        self.routes = routes
        self.data = data
        
        self.userTappedContent = userTappedContent
        
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Personal Log"
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        searchController.searchResultsUpdater = self

        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.separatorStyle = .none
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showEntries(for: Date())
    }
    
    // MARK: - JournalData Integration
   
    private func id(for indexPath: IndexPath) -> any Equatable {
        let day = data.days[indexPath.section]
        let ids = data.entryIDs(for: day)
        return ids[indexPath.row]
    }

    private func title(for section: Int) -> String {
        let day = data.days[section]
        return DateFormatter.localizedString(from: day, dateStyle: .full, timeStyle: .none)
    }
    
    // MARK: - Responding to User Actions
    
    func showEntries(for date: Date) {
        
        let days = data.days
        guard !days.isEmpty else { return }
        
        var section = days.firstIndex { d in
            Calendar.current.startOfDay(for: date) == Calendar.current.startOfDay(for: d)
        }
        if nil == section {
            if let lastDay = days.last,
                    date > lastDay {
                section = days.count-1
            }
            else {
                section = 0
            }
        }
        
        tableView.scrollToRow(at: IndexPath(row: 0, section: section!), at: .top, animated: true)
        
        // if the search bar is active, deactivate it
        searchController.isActive = false
    }

    private func showEditor(forEntryWithID id: some Equatable) {
        let viewModel = data.entryViewModelForEditing(id: id)
        let vm = JournalEntryEditor.ViewModel(date: viewModel.date, mood: viewModel.mood, title: viewModel.title, prompt: viewModel.prompt, text: viewModel.text, tags: viewModel.tags) { [weak self] in
            self?.routes.updateEntry(id: id, from: $0)
            self?.tableView.reloadData()
       }

        let journalEntryVC = UIHostingController(rootView: JournalEntryEditor(viewModel: vm))
        present(journalEntryVC, animated: true)
    }
    
    func showNewEntryChrome() {
        
        let viewModel = JournalEntryEditor.ViewModel() { [weak self] in
            self?.routes.creatNewEntry(from: $0)
            self?.tableView.reloadData()
      }
        
        let journalEntryVC = UIHostingController(rootView: JournalEntryEditor(viewModel: viewModel))
        present(journalEntryVC, animated: true)
    }

    func showSearchChrome() {
        
        navigationItem.searchController = searchController

        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.searchController.isActive = true
            self.searchController.searchBar.becomeFirstResponder()
        }
    }

    func hideSearchChromeIfNoSearchString() {
        guard data.searchString.isEmpty else { return }
        
        navigationItem.searchController = nil
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int { data.days.count }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let day = data.days[section]
        return data.entryIDs(for: day).count
    }
        
    private static var EntryCellResuseIdentifier: String { #function }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: Self.EntryCellResuseIdentifier)
        ?? UITableViewCell(style:.default, reuseIdentifier:Self.EntryCellResuseIdentifier)
        
        let id = id(for: indexPath)
        let viewModel = data.entryViewModelForCell(id: id)
        
        cell.contentConfiguration = UIHostingConfiguration() {
            JournalEntryCell(viewModel: viewModel)
                .onTapGesture(perform: userTappedContent)
                .onLongPressGesture { [weak self] in
                    self?.showEditor(forEntryWithID: id)
                }
        }

        return cell
    }
        
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: .zero)
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        label.text = "   " + title(for: section)
        label.textColor = .tintColor
        label.sizeToFit()
        let view = UIView(frame: CGRect(origin: .zero, size: label.intrinsicContentSize))
        view.backgroundColor = .secondarySystemBackground
        view.addSubview(label)

        return view
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool { false }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { true }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {

            let day = data.days[indexPath.section]
            let id = id(for: indexPath)

            routes.deleteEntry(id: id)
            
            if data.entryIDs(for: day).isEmpty {
                tableView.deleteSections([indexPath.section], with: .fade)
            }
            else {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
}

// MARK: - JournalViewController: UISearchResultsUpdating

extension JournalViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        data.searchString = searchController.searchBar.text ?? ""
        tableView.reloadData()
    }
}
