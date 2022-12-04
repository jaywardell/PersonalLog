//
//  JournalEntryView.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/4/22.
//

import SwiftUI



struct JournalEntryView: View {
    
    final class ViewModel: ObservableObject {
        
        // tends to be an emoji, cannot be more than 3 characters long
        @Published var mood = ""
        
        // empty by default
        @Published var title = ""
        
        // empty by default
        @Published var prompt = ""
        
        // empty for new entries
        @Published var text = ""
        
        let cancel: ()->()
        let save: ()->()
        
        init(mood: String,
             title: String,
             prompt: String,
             text: String,
            cancel: @escaping ()->(),
            save: @escaping ()->()) {
            self.cancel = cancel
            self.save = save
        }
    }
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        NavigationView {
            Text("Hello World")
                .navigationTitle("")
                .navigationBarItems(leading: cancelButton, trailing: saveButton)
        }
    }
}

// MARK: - JournalEntryView: Component Views

extension JournalEntryView {
    
    private var cancelButton: some View {
        Button(action: viewModel.cancel) {
            Text("Cancel")
        }
    }

    private var saveButton: some View {
        Button(action: viewModel.save) {
            Text("Save")
        }
    }
}

// MARK: - JournalEntryView.ViewModel: Convenience Initializers
fileprivate extension JournalEntryView.ViewModel {
    static var empty: Self {
        .init(mood: "", title: "", prompt: "", text: "", cancel: {}, save: {})
    }
}

// MARK: - Preview

struct JournalEntryView_Previews: PreviewProvider {
    static var previews: some View {
        JournalEntryView(viewModel: .empty)
            .previewLayout(.sizeThatFits)
    }
}
