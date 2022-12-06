//
//  JournalArchive.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/4/22.
//

import Foundation

final class JournalArchive {
    
    let directory: URL
    
    private static var defaultDirectory: URL! {
        
        try! FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appending(component: "entries")
    }
    
    init(directory: URL? = nil) {
        self.directory = directory ?? Self.defaultDirectory
        
        try! FileManager.default.createDirectory(at: self.directory, withIntermediateDirectories: true)
    }
        
    private var days: [Date]!
    private var entriesAtDates: [Date:[Date]]!
    
    func allDays() -> [Date] {
        if let days = self.days { return days }
        
        buildEntries()

        return self.days
    }
        
    private func buildEntries() {
        let fm = FileManager()
        guard let contents = try? fm.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) else {
            self.entriesAtDates = [:]
            self.days = []
            return
        }
        
        let foundEntries = contents
            .map(\.lastPathComponent)
            .compactMap(Double.init)
            .map(Date.init(timeIntervalSinceReferenceDate:))
            .sorted()
        
        self.days = Set(foundEntries.map { Calendar.current.startOfDay(for: $0) }).sorted()
        
        var sortedDates = [Date:[Date]]()
        for date in foundEntries {
            let day = Calendar.current.startOfDay(for: date)
            var list = sortedDates[day, default: []]
            list.append(date)
            sortedDates[day] = list
        }
        self.entriesAtDates = sortedDates
    }
    
    func journalEntries(on day: Date) -> [some Equatable] {
        entriesAtDates[day] ?? []
    }
    
    func journalEntry(for id: some Equatable) -> JournalEntry? {
        guard let date = id as? Date,
              let path = path(for: date) else { return nil }
        
        let decoder = JSONDecoder()
        guard let data = try? Data(contentsOf: path) else { return nil }
        let out = try? decoder.decode(JournalEntry.self, from: data)
        return out
    }
    
    func save(entry: JournalEntry) throws {
        guard let path = path(for: entry) else { return }
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(entry)
            
            try data.write(to: path)
        }
        catch {
            print("error saving \(entry) to \(path): \(error)")
            throw error
        }
    }

    func create(entry: JournalEntry) {
        
        do {
            try save(entry: entry)
            
            let day = Calendar.current.startOfDay(for: entry.date)
                
            var entriesForDay = entriesAtDates[day]
            entriesForDay?.append(entry.date)
            entriesAtDates[day] = entriesForDay?.sorted() // probably not necessary, but sort it to be safe
            
            if nil == entriesAtDates[day] {
                entriesAtDates[day] = [entry.date]
                days.append(day)
                days.sort()
            }
        }
        catch {
            // any error caught here was already logged in the save() method
        }
    }
    
    func deleteEntry(for id: any Equatable) {
        guard let date = id as? Date else { return }
        
        let startOfDay = Calendar.current.startOfDay(for: date)

        guard let path = path(for: date),
              let dayIndex = days.firstIndex(of: startOfDay),
              let innerIndex = entriesAtDates[startOfDay]?.firstIndex(of: date),
              var entriesForDay = entriesAtDates[startOfDay]
        else { return }
        
        do {
            entriesForDay.remove(at: innerIndex)
            entriesAtDates[startOfDay] = entriesForDay
            if entriesForDay.isEmpty {
                entriesAtDates.removeValue(forKey: startOfDay)
                days.remove(at: dayIndex)
            }
            
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
