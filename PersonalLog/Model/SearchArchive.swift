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
    
    /// indexes the entry passed in so that it can be found in a search using dates(for:)
    func index(_ entry: JournalEntry) {
        
        let words = words(in: entry)
    
        for word in words {
            word.forAllPrefixes {
                var datesForWord = index[$0, default: []]
                datesForWord.insert(entry.date)
                datesForWord.insert(Calendar.current.startOfDay(for: entry.date))
                index[$0] = datesForWord
            }
        }
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(index)
            try data.write(to: path)
        }
        catch {
            print("Error writing search index to \(path): \(error)")
        }
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
                if false == index[word]?.contains(date) {
                    out.remove(date)
                }
            }
        }
        
        return out
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
