//
//  PhrasesPicker.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/4/22.
//

import SwiftUI

struct PhrasesPicker: View {
    
    let prompt: String
    let message: String
    let initialPhrase: String
    let phrases: [String]
    
    let doneButtonTitle: String
    let clearButtonTitle: String

    let showCancelButton: Bool

    let phraseWasChanged: (String)->()

    @State private var selectedPhrase: String
    @Environment(\.dismiss) var dismiss

    init(prompt: String,
         message: String = "",
         phrases: [String],
         initialPhrase: String,
         doneButtonTitle: String = "Done",
         clearButtonTitle: String,
         showCancelButton: Bool = true,
         phraseWasChanged: @escaping (String)->()) {
        self.prompt = prompt
        self.message = message
        self.phrases = phrases
        self.initialPhrase = initialPhrase
        self.showCancelButton = showCancelButton
        self.doneButtonTitle = doneButtonTitle
        self.clearButtonTitle = clearButtonTitle
        self.phraseWasChanged = phraseWasChanged

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
                        HStack {
                            Text(phrase)
                                .font(.body)
                            Spacer()
                            if phrase == selectedPhrase {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .frame(maxWidth: .infinity)
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
            .navigationBarItems(leading: cancelButton)
        }
    }
    
    @ViewBuilder private var cancelButton: some View {
        if showCancelButton {
            Button("Cancel") {
                dismiss()
            }
        }
        else {
            EmptyView()
        }
    }
    
    @ViewBuilder private var clearButton: some View {
        if !clearButtonTitle.isEmpty {
            Button(clearButtonTitle) {
                phraseWasChanged("")
                dismiss()
            }
            .disabled(selectedPhrase == "")
        }
        else {
            EmptyView()
        }
    }


    private var doneButton: some View {
        Button("Write About This") {
            phraseWasChanged(selectedPhrase)
            dismiss()
        }
        .buttonStyle(.borderedProminent)
        .disabled(selectedPhrase == initialPhrase)
    }
    
    private func userTapped(_ phrase: String) {
        selectedPhrase = phrase
    }
    
    private func chooseAndDismiss(_ phrase: String) {
        phraseWasChanged(phrase)
        dismiss()
    }

}

struct PhrasesPicker_Previews: PreviewProvider {
    static var previews: some View {
        PhrasesPicker(prompt: "Some Phrases", message: "some wordy stuff", phrases: ["How's the weather?", "What time is it?", "Where am I going?"], initialPhrase: "What time is it?", doneButtonTitle: "Choose Me", clearButtonTitle: "Clear", showCancelButton: true) {_ in }
    }
}
