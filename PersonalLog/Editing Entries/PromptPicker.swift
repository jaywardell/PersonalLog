//
//  PromptPicker.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/8/22.
//

import SwiftUI

struct PromptPicker: View {
    
    let initialPhrase: String
    let prompt: String = "Pick a Topic"
    let message: String = "You can write about anything you want, but if you want some ideas, here's a list of journaling prompts:"
    let phrases: [String]
    let clearButtonTitle: String = "Write about Anything"
    let doneButtonTitle: String = "Write About This"
    
    @State private var selectedPhrase: String
    @Environment(\.dismiss) var dismiss

    let phraseWasChanged: (String)->()

    init(initialPhrase: String,
         phraseWasChanged: @escaping (String)->()) {
        self.initialPhrase = initialPhrase
        self.phraseWasChanged = phraseWasChanged

        self.phrases = WritingPrompts(firstPrompt: initialPhrase).prompts
        _selectedPhrase = .init(initialValue: initialPhrase)
    }

    var body: some View {
        NavigationStack {
            VStack {
                if !message.isEmpty {
                    HStack {
                        Text(message)
                            .font(.subheadline)
                            .foregroundColor(Color(uiColor: .secondaryLabel))
                            .padding()
                        Spacer()
                    }
                }
                
                List {
                    ForEach(phrases, id: \.self) { phrase in
                        HStack(alignment: .top) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                                    .opacity(phrase == selectedPhrase ? 1 : 0)

                            Text(phrase)
                                .font(.body)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(uiColor: .systemBackground))
                            .onTapGesture(count: 2) { self.chooseAndDismiss(phrase)
                            }
                            .onTapGesture { userTapped(phrase) }
                    }
                }
                .listStyle(.plain)
                
                HStack {
                    clearButton
                    Spacer()
                    doneButton
                }
                .padding()
            }
            .navigationTitle(prompt)
        }
    }
    
    private var clearButton: some View {
        Button(clearButtonTitle) {
            phraseWasChanged("")
            dismiss()
        }
    }


    private var doneButton: some View {
        Button(doneButtonTitle) {
            phraseWasChanged(selectedPhrase)
            dismiss()
        }
        .buttonStyle(.borderedProminent)
        .disabled(selectedPhrase.isEmpty)
    }

private func chooseAndDismiss(_ phrase: String) {
    phraseWasChanged(phrase)
    dismiss()
}

    private func userTapped(_ phrase: String) {
        selectedPhrase = phrase
    }

}

struct PromptPicker_Previews: PreviewProvider {
    static var previews: some View {
        PromptPicker(initialPhrase: "", phraseWasChanged: { _ in })
    }
}
