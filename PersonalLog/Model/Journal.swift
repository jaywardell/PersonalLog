//
//  Journal.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/4/22.
//

import Foundation

final class Journal: ObservableObject {
    
    var filterString: String = "" {
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
        if !filterString.isEmpty {
            let validDays = index.dates(for: filterString)
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
    
    func loadSummary() async -> String {
        var out = ""
        
        for day in days {
            let ids = entryIDs(for: day)
            for id in ids {
                let entry = archiver.journalEntry(for: id)!
                out += entry.summary + "\n\n\n"
            }
        }
        
        return out
    }
}

extension Journal: JournalData {
    
    func entryIDs(for date: Date) -> [any Equatable] {
        let ids = archiver.journalEntries(on: date)
        if !filterString.isEmpty {
            return index.filter(entriesWithIDs: ids, using: filterString, converter: archiver.date(forEntryWithID:))
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
    
    func indexPathForEntry(dated date: Date) -> IndexPath? {
        let start = Calendar.current.startOfDay(for: date)
        guard let section = days.firstIndex(of: start) else { return nil }
        
        let entriesForDay = entryIDs(for: start)
        let index = entriesForDay.firstIndex { id in
            archiver.journalEntry(for: id)?.date == date
        }
        guard let row = index else { return nil }
        
        return IndexPath(row: row, section: section)
    }
}
 
extension Journal: JournalManipulation {
    
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
        
        var date: Date = viewModel.date
        if TestingFlags.default.offsetDateForNewEntries { date = date.addingTimeInterval(24*3600) }
    
        return JournalEntry(date: date,
                            mood: viewModel.mood.trimmingCharacters(in: .whitespacesAndNewlines),
                            title: viewModel.title.trimmingCharacters(in: .whitespacesAndNewlines),
                            prompt: viewModel.prompt.trimmingCharacters(in: .whitespacesAndNewlines),
                            text: viewModel.text.trimmingCharacters(in: .whitespacesAndNewlines),
                            tags: viewModel.tags.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) })
    }
}
