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
    
    private var idToDate: [UUID:String] = [:]
    
    func allEntries() -> [UUID] {
    
        let fm = FileManager()
        guard let contents = try? fm.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) else { return [] }
        
        let dates = contents.map(\.lastPathComponent).compactMap(Double.init).sorted()
        
        var out = [UUID]()
        var lookup = [UUID:String]()
        for date in dates {
            let id = UUID()
            lookup[id] = String(date)
            out.append(id)
        }
        self.idToDate = lookup
        
        return out
    }
    
    func journalEntry(for id: UUID) -> JournalEntry? {
        guard let name = idToDate[id] else { return nil }
        
        let path = path(for: name)
        
        let decoder = JSONDecoder()
        guard let data = try? Data(contentsOf: path) else { return nil }
        let out = try? decoder.decode(JournalEntry.self, from: data)
        return out
    }
    
    func save(entry: JournalEntry) {
        
        let name = String(entry.date.timeIntervalSinceReferenceDate)
        let path = path(for: name)
        
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(entry)
            
            try data.write(to: path)
        }
        catch {
            print("error saving \(entry) to \(path): \(error)")
        }
    }

    func deleteEntry(for id: UUID) {
        guard let name = idToDate[id] else { return }
        let path = path(for: name)

        let fm = FileManager()
        
        do {
            try fm.removeItem(at: path)
        }
        catch {
            print("error deleting entry with id \(id) at \(path)")
        }
    }
    
    private func path(for name: String) -> URL {
        directory.appending(component: name)
    }
}
