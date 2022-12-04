//
//  JournalViewController.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/4/22.
//

import UIKit
import SwiftUI

protocol JournalRoutes: ObservableObject {
    
    var entryIDs: [UUID] { get }
    
    func entryViewModelForCell(id: UUID) -> JournalEntryCell.ViewModel
    
    func entryViewModelForEditing(id: UUID) -> JournalViewController.ViewModel
}



class JournalViewController: UITableViewController {
    
    struct ViewModel {
        
        let date: Date?
        
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
        navigationItem.leftBarButtonItem = addButton
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return routes.entryIDs.count
    }
    
    private let cellReuseIdentifier = "JournalViewControllerCell"
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) ?? UITableViewCell(style:.default, reuseIdentifier:cellReuseIdentifier)
        
        let viewModel = routes.entryViewModelForCell(id: routes.entryIDs[indexPath.row])
        
        cell.contentConfiguration = UIHostingConfiguration() {
            JournalEntryCell(viewModel: viewModel)
        }

        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let viewModel = routes.entryViewModelForEditing(id: routes.entryIDs[indexPath.row])
        let vm = entryViewModelForEditing(viewModel)

        let journalEntryVC = UIHostingController(rootView: JournalEntryEditor(viewModel: vm))
        present(journalEntryVC, animated: true)
                                                 
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func entryViewModelForEditing(_ viewModel: JournalViewController.ViewModel) -> JournalEntryEditor.ViewModel {
        JournalEntryEditor.ViewModel(date: viewModel.date, mood: viewModel.mood, title: viewModel.title, prompt: viewModel.prompt, text: viewModel.text, tags: viewModel.tags, save: { print($0) })
    }

    @objc
    private func createNewEntry() {
        
        let viewModel = JournalEntryEditor.ViewModel() {
            print($0)
        }
        
        let journalEntryVC = UIHostingController(rootView: JournalEntryEditor(viewModel: viewModel))
        present(journalEntryVC, animated: true)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */
}
