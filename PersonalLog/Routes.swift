//
//  Routes.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/4/22.
//

import Foundation

final class Routes: ObservableObject {
    
    var entryIDs: [UUID] {
        (0...10).map { _ in UUID() }
    }
    
    func entryViewModelForCell(id: UUID) -> JournalEntryCell.ViewModel {
        JournalEntryCell.ViewModel(date: Date(), mood: "😍", title: "Hello", text: "Something really cool happened", tags: [])
    }
    
    
    func entryViewModelForEditing(id: UUID) -> JournalViewController.ViewModel {
        JournalViewController.ViewModel(date: Date(), mood: "😚", title: "Something", prompt: "", text: "Something else", tags: ["hello"])
    }

    func creatNewEntry(from viewModel: JournalEntryEditor.ViewModel) {
        print(viewModel.text)
    }
    
    func updateEntry(id: UUID, from viewModel: JournalEntryEditor.ViewModel) {
        print(id, viewModel.text)
    }

}

extension Routes: JournalRoutes {
    
}
