//
//  Routes.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/4/22.
//

import Foundation

final class Routes: ObservableObject {
    
    @Published var entryIDs: [any Equatable] = []

    let archiver = JournalArchiver()
    
    init() {
        updateEntries()
    }
    
    private func updateEntries() {
        entryIDs = archiver.allEntries()
    }
}

extension Routes: JournalRoutes {

    var days: [Date] { archiver.allDays() }
    
    func entries(for date: Date) -> [any Equatable] {
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

    func creatNewEntry(from viewModel: JournalEntryEditor.ViewModel) {
        
        let entry = JournalEntry(date: viewModel.date, mood: viewModel.mood, title: viewModel.title, prompt: viewModel.prompt, text: viewModel.text, tags: viewModel.tags)
        archiver.save(entry: entry)
        
        updateEntries()
    }
    
    func updateEntry(id: any Equatable, from viewModel: JournalEntryEditor.ViewModel) {

        let entry = JournalEntry(date: viewModel.date, mood: viewModel.mood, title: viewModel.title, prompt: viewModel.prompt, text: viewModel.text, tags: viewModel.tags)
        archiver.save(entry: entry)
        
        updateEntries()
    }

    func deleteEntry(id: any Equatable) {
        
        archiver.deleteEntry(for: id)
        updateEntries()
    }
    
}
