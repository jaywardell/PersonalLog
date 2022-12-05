//
//  JournalArchiver.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/4/22.
//

import Foundation

final class JournalArchiver {
    
    let directory: URL
    
    private static var defaultDirectory: URL! {
        
        try! FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
    }
    
    init(directory: URL? = nil) {
        self.directory = directory ?? Self.defaultDirectory
    }
        
    private var entries: [Date]!
    
    func allEntries() -> [some Equatable] {
        if let entryNames = entries { return entryNames }
        
        let fm = FileManager()
        guard let contents = try? fm.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) else { return [Date]() }
        
        self.entries = contents
            .map(\.lastPathComponent)
            .compactMap(Double.init)
            .map(Date.init(timeIntervalSinceReferenceDate:))
            .sorted()
        
        return self.entries
    }
    
    func journalEntry(for id: some Equatable) -> JournalEntry? {
        guard let date = id as? Date,
              let path = path(for: date) else { return nil }
        
        let decoder = JSONDecoder()
        guard let data = try? Data(contentsOf: path) else { return nil }
        let out = try? decoder.decode(JournalEntry.self, from: data)
        return out
    }
    
    func save(entry: JournalEntry) {
        guard let path = path(for: entry) else { return }
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(entry)
            
            try data.write(to: path)

            if !entries.contains(entry.date) {
                entries.append(entry.date)
                entries.sort()
            }
        }
        catch {
            print("error saving \(entry) to \(path): \(error)")
        }
    }

    func deleteEntry(for id: any Equatable) {
        guard let date = id as? Date,
              let path = path(for: date),
              let index = entries.firstIndex(of: date)
        else { return }
        
        do {
            // remove from entries first, so user will see the entry disappear
            entries.remove(at: index)

            // now ensure that it's removed from disk
            let fm = FileManager()
            try fm.removeItem(at: path)
        }
        catch {
            print("error deleting entry with id \(date) at \(path): \(error)")
        }
    }
    
    private func path(for entry: JournalEntry) -> URL? {
        path(for: entry.date)
    }
    
    private func path(for date: Date) -> URL? {
        let name = String(date.timeIntervalSinceReferenceDate)
        return path(for: name)
    }
          
    private func path(for name: String) -> URL {
        directory.appending(component: name)
    }
}
