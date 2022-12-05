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
    
    private var moodEmoji: some View {
        Text(viewModel.mood.isEmpty ? "😀" : viewModel.mood)
            .font(.title)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                moodEmoji
                    .opacity(viewModel.title.isEmpty && viewModel.text.isEmpty && !viewModel.mood.isEmpty ? 1 : 0)
                Spacer()
                Text(viewModel.date, style: .date)
                Text(viewModel.date, style: .time)
            }
            .font(.caption)
            .foregroundColor(Color(uiColor: .secondaryLabel))
            
            if !viewModel.title.isEmpty {
                HStack {
                    moodEmoji
                        .opacity(viewModel.mood.isEmpty ? 0 : 1)
                    Text(viewModel.title)
                        .font(.headline)
                }
            }
            
            if !viewModel.text.isEmpty {
                HStack(alignment: .top) {
                    moodEmoji
                        .opacity((viewModel.title.isEmpty && !viewModel.mood.isEmpty) ? 1 : 0)
                    Text(viewModel.text)
                }
            }

            if !viewModel.tags.isEmpty {
                HStack {
                    moodEmoji
                        .opacity(0)
                    Text(viewModel.tags.joined(separator: ", "))
                        .font(.caption2)
                }
            }
        }
    }
}

extension JournalEntryCell.ViewModel {
    static let exampleOne = JournalEntryCell.ViewModel(date: Date(), mood: "🥹", title: "just some thoughts", text: "I think that I just saw a giraffe swimming through the living room", tags: ["giraffes", "Africa", "wildlife"])
    
    static let exampleTwo = JournalEntryCell.ViewModel(date: Date(), mood: "🥹", title: "", text: "I think that I just saw a giraffe swimming through the living room. I think that I just saw a giraffe swimming through the living room. I think that I just saw a giraffe swimming through the living room", tags: ["giraffes", "Africa", "wildlife"])
    
    static let exampleThree = JournalEntryCell.ViewModel(date: Date(), mood: "", title: "", text: "I think that I just saw a giraffe swimming through the living room. I think that I just saw a giraffe swimming through the living room. I think that I just saw a giraffe swimming through the living room", tags: ["giraffes", "Africa", "wildlife"])
    
    static let exampleFour = JournalEntryCell.ViewModel(date: Date(), mood: "", title: "Wassup?!?!?!?", text: "I think that I just saw a giraffe swimming through the living room. I think that I just saw a giraffe swimming through the living room. I think that I just saw a giraffe swimming through the living room", tags: ["giraffes", "Africa", "wildlife"])
    
    static let exampleFive = JournalEntryCell.ViewModel(date: Date(), mood: "🥹", title: "", text: "", tags: [])
}

struct JournalEntryCell_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack {
                JournalEntryCell(viewModel: .exampleOne)
                JournalEntryCell(viewModel: .exampleTwo)
                JournalEntryCell(viewModel: .exampleFive)
                JournalEntryCell(viewModel: .exampleThree)
                JournalEntryCell(viewModel: .exampleFour)
            }
        }
    }
}
