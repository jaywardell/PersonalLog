//
//  Routes.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/4/22.
//

import Foundation

final class Routes: ObservableObject {
    
    @Published var entryIDs: [UUID] = []

    let archiver = JournalArchiver(directory: JournalArchiver.defaultDirectory)
    
    init() {
        updateEntries()
    }
    
    private func updateEntries() {
        entryIDs = archiver.allEntries()
    }
}

extension Routes: JournalRoutes {

    func entryViewModelForCell(id: UUID) -> JournalEntryCell.ViewModel {
        let entry = archiver.journalEntry(for: id)!
        return JournalEntryCell.ViewModel(date: entry.date, mood: entry.mood, title: entry.title, text: entry.text, tags: entry.tags)
    }
    
    
    func entryViewModelForEditing(id: UUID) -> JournalViewController.ViewModel {
        let entry = archiver.journalEntry(for: id)!
        return JournalViewController.ViewModel(date: entry.date, mood: entry.mood, title: entry.title, prompt: entry.prompt, text: entry.text, tags: entry.tags)
    }

    func creatNewEntry(from viewModel: JournalEntryEditor.ViewModel) {
        
        let entry = JournalEntry(date: viewModel.date, mood: viewModel.mood, title: viewModel.title, prompt: viewModel.prompt, text: viewModel.text, tags: viewModel.tags)
        archiver.save(entry: entry)
        
        updateEntries()
    }
    
    func updateEntry(id: UUID, from viewModel: JournalEntryEditor.ViewModel) {

        let entry = JournalEntry(date: viewModel.date, mood: viewModel.mood, title: viewModel.title, prompt: viewModel.prompt, text: viewModel.text, tags: viewModel.tags)
        archiver.save(entry: entry)
        
        updateEntries()
    }

    func deleteEntry(id: UUID) {
        
        archiver.deleteEntry(for: id)
        updateEntries()
    }
    
}
