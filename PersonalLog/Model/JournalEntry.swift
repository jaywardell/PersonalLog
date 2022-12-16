//
//  JournalEntry.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/4/22.
//

import Foundation

struct JournalEntry {
        
    let date: Date
    let mood: String
    let title: String
    let prompt: String
    let text: String
    let tags: [String]
    
    func allWords() -> [String] {
        
        [
            mood,
            title,
            prompt,
            text,
            tags.joined(separator: " ")
        ]
            .flatMap { $0.components(separatedBy: .whitespacesAndNewlines) }
            .map { $0.trimmingCharacters(in: .punctuationCharacters)}
            .filter { !$0.isEmpty }
            .map(\.localizedLowercase)
    }

    var summary: String {
        var out = ""
        out += DateFormatter.localizedString(from: date, dateStyle: .long, timeStyle: .short)

        if !mood.isEmpty { out += mood + "\n" }
        if !title.isEmpty { out += title + "\n" }
        if !mood.isEmpty || !title.isEmpty { out += "\n" }
        
        if !prompt.isEmpty { out += prompt + "\n\n" }
        
        if !text.isEmpty { out += text + "\n\n" }
        if !tags.isEmpty { out += "\n" + tags.joined(separator: ", ") + "\n\n" }
        
        return out
    }
    
}

extension JournalEntry: Codable {}
