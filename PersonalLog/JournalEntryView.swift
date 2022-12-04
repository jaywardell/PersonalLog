//
//  JournalEntryView.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/4/22.
//

import SwiftUI



struct JournalEntryView: View {
    
    final class ViewModel: ObservableObject {
        @Published var mood = "" // tends to be an emoji, cannot be more than 3 characters long
        @Published var title = ""
        @Published var prompt = ""
        @Published var text = ""
        
        let cancel: ()->()
        let save: ()->()
        
        init(cancel: @escaping ()->(), save: @escaping ()->()) {
            self.cancel = cancel
            self.save = save
        }
        
        fileprivate convenience init() {
            self.init(cancel: {}, save: {})
        }
    }
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            HStack {
                Button(action: viewModel.cancel) {
                    Text("Cancel")
                }
                Spacer()
                Button(action: viewModel.save) {
                    Text("Save")
                }
            }
            Spacer()
        }
        .padding()
    }
}

struct JournalEntryView_Previews: PreviewProvider {
    static var previews: some View {
        JournalEntryView(viewModel: .init())
            .previewLayout(.sizeThatFits)
    }
}
