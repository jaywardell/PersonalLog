//
//  JournalViewController.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/4/22.
//

import UIKit
import SwiftUI

protocol JournalRoutes: ObservableObject {
        
    var days: [Date] { get }
    func entryIDs(for date: Date) -> [any Equatable]
    
    func entryViewModelForCell(id: any Equatable) -> JournalEntryCell.ViewModel
    
    func entryViewModelForEditing(id: any Equatable) -> JournalViewController.ViewModel
    
    func creatNewEntry(from viewModel: JournalEntryEditor.ViewModel)
    func updateEntry(id: any Equatable, from viewModel: JournalEntryEditor.ViewModel)
    func deleteEntry(id: any Equatable)
}



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
    
    init(routes: any JournalRoutes) {

        self.routes = routes
        
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
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewEntry))
        
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButtonPressed))
        let calendarButton = UIBarButtonItem(image: UIImage(systemName: "calendar"), style: .plain, target: self, action: #selector(calendarButtonPressed))

        navigationItem.rightBarButtonItem = addButton
        navigationItem.leftBarButtonItems = [searchButton, calendarButton]
        
        tableView.separatorStyle = .none
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return routes.days.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let day = routes.days[section]
        return routes.entryIDs(for: day).count
    }
    
    private func id(for indexPath: IndexPath) -> any Equatable {
        let day = routes.days[indexPath.section]
        let ids = routes.entryIDs(for: day)
        return ids[indexPath.row]
    }
    
    private let cellReuseIdentifier = "JournalViewControllerCell"
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) ?? UITableViewCell(style:.default, reuseIdentifier:cellReuseIdentifier)
        
        let id = id(for: indexPath)
        let viewModel = routes.entryViewModelForCell(id: id)
        
        cell.contentConfiguration = UIHostingConfiguration() {
            JournalEntryCell(viewModel: viewModel)
        }

        return cell
    }
        
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let id = id(for: indexPath)
        let viewModel = routes.entryViewModelForEditing(id: id)
        let vm = JournalEntryEditor.ViewModel(date: viewModel.date, mood: viewModel.mood, title: viewModel.title, prompt: viewModel.prompt, text: viewModel.text, tags: viewModel.tags) { [weak self] in
            self?.routes.updateEntry(id: id, from: $0)
            self?.tableView.reloadData()
       }


        let journalEntryVC = UIHostingController(rootView: JournalEntryEditor(viewModel: vm))
        present(journalEntryVC, animated: true)
                                                 
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc
    private func createNewEntry() {
        
        let viewModel = JournalEntryEditor.ViewModel() { [weak self] in
            self?.routes.creatNewEntry(from: $0)
            self?.tableView.reloadData()
      }
        
        let journalEntryVC = UIHostingController(rootView: JournalEntryEditor(viewModel: viewModel))
        present(journalEntryVC, animated: true)
    }

    @objc
    private func searchButtonPressed() {
        print(#function)
    }

    @objc
    private func calendarButtonPressed() {
        print(#function)
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {

            let day = routes.days[indexPath.section]
            let id = id(for: indexPath)

            routes.deleteEntry(id: id)
            
            if routes.entryIDs(for: day).isEmpty {
                tableView.deleteSections([indexPath.section], with: .fade)
            }
            else {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let day = routes.days[section]
        return DateFormatter.localizedString(from: day, dateStyle: .full, timeStyle: .none)
    }
}
