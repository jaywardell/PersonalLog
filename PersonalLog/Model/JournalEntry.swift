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

}

extension JournalEntry: Codable {}
