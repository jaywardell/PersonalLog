//
//  Journal.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/4/22.
//

import Foundation

final class Journal: ObservableObject {
    
    @Published var days: [Date] = []

    let archiver = JournalArchiver()
    
    init() {
        updateEntries()
    }
    
    private func updateEntries() {
        days = archiver.allDays()
    }
}

extension Journal: JournalData {
    
    func entryIDs(for date: Date) -> [any Equatable] {
        archiver.journalEntries(on: date)
    }
    
    func entryViewModelForCell(id: any Equatable) -> JournalEntryCell.ViewModel {
        let entry = archiver.journalEntry(for: id)!
        return JournalEntryCell.ViewModel(date: entry.date, mood: entry.mood, title: entry.title, text: entry.text, tags: entry.tags)
    }
    
    func entryViewModelForEditing(id: any Equatable) -> JournalViewController.ViewModel {
        let entry = archiver.journalEntry(for: id)!
        return JournalViewController.ViewModel(date: entry.date, mood: entry.mood, title: entry.title, prompt: entry.prompt, text: entry.text, tags: entry.tags)
    }
}
 
extension Journal: JournalRoutes {

    func creatNewEntry(from viewModel: JournalEntryEditor.ViewModel) {
        
        let entry = JournalEntry(date: viewModel.date, mood: viewModel.mood, title: viewModel.title, prompt: viewModel.prompt, text: viewModel.text, tags: viewModel.tags)
        archiver.create(entry: entry)
        
        updateEntries()
    }
    
    func updateEntry(id: any Equatable, from viewModel: JournalEntryEditor.ViewModel) {

        let entry = JournalEntry(date: viewModel.date, mood: viewModel.mood, title: viewModel.title, prompt: viewModel.prompt, text: viewModel.text, tags: viewModel.tags)
        try? archiver.save(entry: entry)
        
        updateEntries()
    }

    func deleteEntry(id: any Equatable) {
        
        archiver.deleteEntry(for: id)
        updateEntries()
    }
    
}
