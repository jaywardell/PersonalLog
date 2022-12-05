//
//  JournalEntry.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/4/22.
//

import Foundation

struct JournalEntry {
    
    let id: UUID
    
    let date: Date
    let mood: String
    let title: String
    let prompt: String
    let text: String
    let tags: [String]
}

extension JournalEntry: Codable {}
