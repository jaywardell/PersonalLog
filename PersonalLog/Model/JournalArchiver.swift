//
//  JournalArchiver.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/4/22.
//

import Foundation

final class JournalArchiver {
    
    private var idToDate: [UUID:Date] = [:]
    
    func allEntries() -> [UUID] { [] }
    
    func journalEntry(for id: UUID) -> JournalEntry {
        JournalEntry(id: UUID(), date: Date(), mood: "", title: "", prompt: "", text: "", tags: [])
    }
    
    func save(entry: JournalEntry) {}
    func delete(entry: JournalEntry) {}

}
