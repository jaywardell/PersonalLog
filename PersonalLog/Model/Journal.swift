//
//  Journal.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/4/22.
//

import Foundation

final class Journal: ObservableObject {
    
    var searchString: String = "" {
        didSet {
            updateEntries()
        }
    }
    
    @Published var days: [Date] = []

    let archiver = JournalArchive()
    let index = SearchArchive()
    
    init() {
        updateEntries()
        
        verifyIndex()
    }
    
    private func updateEntries() {
        var matches = archiver.allDays()
        if !searchString.isEmpty {
            let validDays = index.dates(for: searchString)
            matches = matches.filter {
                validDays.contains($0)
            }
        }
        days = matches
    }
    
    private func verifyIndex() {
        if !archiver.allDays().isEmpty && index.isEmpty {
            index.rebuildIndex(from: archiver.directory)
        }
    }
}

extension Journal: JournalData {
    
    func entryIDs(for date: Date) -> [any Equatable] {
        var ids = archiver.journalEntries(on: date)
        if !searchString.isEmpty {
            let matches = index.dates(for: searchString)
            ids = ids.filter {
                guard let entry = archiver.journalEntry(for: $0) else { return false }
                
                // make sure that the indexer has indexed this entry for this date
                guard matches.contains(entry.date) else { return false }
                
                // and that the entry still contains the search string
                // i.e. it wasn't edited to remove the search string
                return index.entry(entry, matches: searchString)
            }
        }
        
        return ids
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
        
        let entry = entry(from: viewModel)
        archiver.create(entry: entry)
        
        updateEntries()
        
        index.index(entry)
    }
    
    func updateEntry(id: any Equatable, from viewModel: JournalEntryEditor.ViewModel) {

        let entry = entry(from: viewModel)
        try? archiver.save(entry: entry)
        
        updateEntries()
        
        index.index(entry)
    }

    func deleteEntry(id: any Equatable) {
        
        archiver.deleteEntry(for: id)
        updateEntries()
    }
    
    private func entry(from viewModel: JournalEntryEditor.ViewModel) -> JournalEntry {
        JournalEntry(date: viewModel.date - 24*3600,
                     mood: viewModel.mood.trimmingCharacters(in: .whitespacesAndNewlines),
                     title: viewModel.title.trimmingCharacters(in: .whitespacesAndNewlines),
                     prompt: viewModel.prompt.trimmingCharacters(in: .whitespacesAndNewlines),
                     text: viewModel.text.trimmingCharacters(in: .whitespacesAndNewlines),
                     tags: viewModel.tags.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) })
    }
    
}
