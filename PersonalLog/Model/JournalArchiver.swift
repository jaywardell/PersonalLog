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
        
    private var entryNames: [Date]!
    
    func allEntries() -> [Date] {
        if let entryNames = entryNames { return entryNames }
        
        let fm = FileManager()
        guard let contents = try? fm.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) else { return [] }
        
        self.entryNames = contents
            .map(\.lastPathComponent)
            .compactMap(Double.init)
            .map(Date.init(timeIntervalSinceReferenceDate:))
            .sorted()
        
        return self.entryNames
    }
    
    func journalEntry(for date: Date) -> JournalEntry? {
        guard let path = path(for: date) else { return nil }
        
        let decoder = JSONDecoder()
        guard let data = try? Data(contentsOf: path) else { return nil }
        let out = try? decoder.decode(JournalEntry.self, from: data)
        return out
    }
    
    func save(entry: JournalEntry) {
        guard let path = path(for: entry) else { return }
        
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(entry)
            
            try data.write(to: path)

            if !entryNames.contains(entry.date) {
                entryNames.append(entry.date)
                entryNames.sort()
            }
        }
        catch {
            print("error saving \(entry) to \(path): \(error)")
        }
    }

    func deleteEntry(for date: Date) {
        guard let path = path(for: date) else { return }
        
        do {
            let fm = FileManager()
            try fm.removeItem(at: path)

            if let index = entryNames.firstIndex(of: date) {
                entryNames.remove(at: index)
            }
        }
        catch {
            print("error deleting entry with id \(date) at \(path)")
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
