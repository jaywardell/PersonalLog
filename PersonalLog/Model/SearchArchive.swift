//
//  SearchArchive.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/6/22.
//

import Foundation

final class SearchArchive {
    
    let path: URL
    
    private var index: [String: Set<Date>]
    
    private let q = DispatchQueue(label: "SearchArchive", qos: .background)
    
    private static var defaultPath: URL! {
        
        try! FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appending(component: "index.json")
    }
    
    init(path: URL? = nil) {
        self.path = path ?? Self.defaultPath
               
        self.index = [:]

        
        loadArchive()
    }
    
    var isEmpty: Bool {
        index.isEmpty
    }
    
    /// indexes the entry passed in so that it can be found in a search using dates(for:)
    func index(_ entry: JournalEntry) {
        
        updateIndex(with: entry)
        
        archiveIndex()
    }

    
    /// returns a list of dates that match the given search string
    /// a date matches if it represents a journal entry that contains that string
    /// or if it represents a day on which a journal entry containing that string
    /// was entered
    ///
    /// NOTE: if a journal entry is altered,
    /// the index may list certain words as still matching even though they don't anymore
    func dates(for searchString: String) -> Set<Date> {
        let words = searchString
            .localizedLowercase
            .components(separatedBy: .whitespacesAndNewlines)
            .map { $0.trimmingCharacters(in: .punctuationCharacters) }
            .filter { !$0.isEmpty }
                
        // get all indexed dates that match any of the given words
        let allMatches = words.compactMap { index[$0] }.reduce([], +)
        var out = Set(allMatches)
        
        // filter out any dates that aren't indexed for ALL words
        for date in allMatches {
            for word in words {
                if nil == index[word] ||                    // word must have been indexed
                    false == index[word]?.contains(date) {  // for the given date
                    out.remove(date)
                }
            }
        }
        
        return out
    }
    
    private func updateIndex(with entry: JournalEntry) {
        let words = words(in: entry)
    
        for word in words {
            word.forAllPrefixes {
                var datesForWord = index[$0, default: []]
                datesForWord.insert(entry.date)
                datesForWord.insert(Calendar.current.startOfDay(for: entry.date))
                index[$0] = datesForWord
            }
        }
    }

    func rebuildIndex(from directory: URL) {
        q.async { [weak self] in
            guard let contents = try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) else { return }
            let decoder = JSONDecoder()
            
            for path in contents {
                if let data = try? Data(contentsOf: path),
                   let entry = try? decoder.decode(JournalEntry.self, from: data) {
                    self?.updateIndex(with: entry)
                }
            }
            
            self?.archiveIndex()
        }
    }
    
    private func words(in entry: JournalEntry) -> [String] {
        
        [
            entry.mood,
            entry.title,
            entry.prompt,
            entry.text,
            entry.tags.joined(separator: " ")
        ]
            .flatMap { $0.components(separatedBy: .whitespacesAndNewlines) }
            .map { $0.trimmingCharacters(in: .punctuationCharacters)}
            .filter { !$0.isEmpty }
            .map(\.localizedLowercase)
    }
    
    private func loadArchive() {
        let saved = try? Data(contentsOf: self.path)
        if let saved = saved {
            do {
                let decoder = JSONDecoder()
                let retrieved = try decoder.decode([String: Set<Date>].self, from: saved)
                self.index = retrieved
            }
            catch {
                print("Error loading search index from \(self.path): \(error)")
            }
        }
    }

    private func archiveIndex() {
        q.async { [index, path] in
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(index)
                try data.write(to: path)
            }
            catch {
                print("Error writing search index to \(path): \(error)")
            }
        }
    }

}


fileprivate extension String {
    func forAllPrefixes(_ callback: (String)->()) {
        var this = ""
        for i in self {
            this += "\(i)"
            callback(this)
        }
    }
}
