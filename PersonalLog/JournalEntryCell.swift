//
//  JournalEntryCell.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/4/22.
//

import SwiftUI

struct JournalEntryCell: View {
    
    struct ViewModel {
        
        let date: Date
        
        // tends to be an emoji, only 1 character long, can be empty
        let mood: String
        
        // empty by default
        let title: String
                
        // empty for new entries
        let text: String
        
        let tags: [String]
    }

    let viewModel: ViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Text(viewModel.date, style: .date)
                Text(viewModel.date, style: .time)
            }
            .font(.caption)
            .foregroundColor(Color(uiColor: .secondaryLabel))
            
            HStack {
                Text(viewModel.mood)
                    .font(.title)
                Text(viewModel.title)
                    .font(.headline)
            }
            
            HStack {
                Text(viewModel.mood)
                    .font(.title)
                    .opacity(0)
                Text(viewModel.text)
            }

            HStack {
                Text(viewModel.mood)
                    .font(.title)
                    .opacity(0)
                Text(viewModel.tags.joined(separator: ", "))
                    .font(.caption2)
            }
        }
        .padding()
    }
}

extension JournalEntryCell.ViewModel {
    static let exampleOne = JournalEntryCell.ViewModel(date: Date(), mood: "🥹", title: "just some thoughts", text: "I think that I just saw a giraffe swimming through the living room", tags: ["giraffes", "Africa", "wildlife"])
}

struct JournalEntryCell_Previews: PreviewProvider {
    static var previews: some View {
        JournalEntryCell(viewModel: .exampleOne)
    }
}
