//
//  WritingPrompts.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/8/22.
//

import Foundation

struct WritingPrompts {
    
    let prompts: [String]
    
    init(firstPrompt: String) {
        if let path = Bundle.main.url(forResource: "prompts", withExtension: "txt"),
           let text = try? String(contentsOf: path) {
                        
            self.prompts = (firstPrompt.isEmpty ? [] : [firstPrompt]) +
            text.components(separatedBy: "\n")
                .filter { !$0.isEmpty }
                .filter { $0 != firstPrompt }
                .shuffled()
        }
        else {
            prompts = [
                "How has the day gone so far?",
                "What do you plan to do with your day?",
                "What are you grateful for today?"
            ]
        }
        
    }
}
