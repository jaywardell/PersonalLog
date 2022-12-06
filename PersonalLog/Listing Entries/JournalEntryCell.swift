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
    
    @ViewBuilder private var moodEmoji: some View {
        if !viewModel.mood.isEmpty {
            Text(viewModel.mood.isEmpty ? "😀" : viewModel.mood)
                .opacity(viewModel.mood.isEmpty ? 0 : 1)
                .font(.largeTitle)
        }
    }
    
    var body: some View {
        
        VStack {
            
            HStack {
                Spacer()
                Text(viewModel.date, style: .time)
                    .font(.caption)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
            }

            HStack(alignment: .top) {
                
                moodEmoji
                    .grayscale(0.85)
                    .opacity(0.85)
                    .padding(.trailing)
                
                VStack(alignment: .leading, spacing: 5) {
                    if !viewModel.title.isEmpty {
                        Text(viewModel.title)
                            .font(.headline)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Text(viewModel.text)
                        .font(.system(.body, design: .default))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if !viewModel.tags.isEmpty {
                        HStack {
                            Image(systemName: "tag")
                            Text(viewModel.tags.joined(separator: ", "))
                        }
                        .font(.caption2)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top)
                    }
                }
                
            }
        }
//        .background(Color.yellow)
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
