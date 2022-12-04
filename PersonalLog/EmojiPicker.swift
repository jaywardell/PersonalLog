//
//  EmojiSelectionView.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/4/22.
//

import SwiftUI

struct EmojiPicker: View {
    
    let prompt: String
    let allowableEmoji: [String.Element]
    let emojiWasSelected: (String) -> ()
    
    let showClearButton: Bool
    let showCancelButton: Bool

    var vGridLayout = [ GridItem(.adaptive(minimum: 50)) ]

    @State private var selectedEmoji: String.Element?
    @Environment(\.dismiss) var dismiss

    init(prompt: String = "",
         allowed: String = Self.faces,
         selected: String,
         showClearButton: Bool = true,
         showCancelButton: Bool = true,
         emojiWasSelected: @escaping (String) -> ()) {
        self.prompt = prompt
        self.allowableEmoji = Array(allowed)
        self.emojiWasSelected = emojiWasSelected
        self.showClearButton = showClearButton
        self.showCancelButton = showCancelButton
        
        _selectedEmoji = .init(initialValue: selected.first)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    LazyVGrid(columns: vGridLayout, content: {
                        ForEach(allowableEmoji, id: \.self) { emoji in
                            Text(String(emoji))
                                .background(RoundedRectangle(cornerRadius: 4).foregroundColor(backgroundColor(for: emoji)))
                                .onTapGesture(count: 2) { self.chooseAndDismiss(emoji)
                                }
                                .onTapGesture { userTapped(emoji) }
                        }
                    })
                    .font(.largeTitle)
                }
                HStack {
                    if showClearButton {
                        clearButton
                    }
                    Spacer()
                    chooseButton
                }
                .padding()
            }
            .navigationTitle(prompt)
            .navigationBarItems(leading: cancelButton)
        }
    }
    
    private func backgroundColor(for emoji: String.Element) -> Color {
        emoji == self.selectedEmoji ? Color.accentColor : Color.clear
    }
    
    private func userTapped(_ emoji: String.Element) {
        self.selectedEmoji = emoji == self.selectedEmoji ? nil : emoji
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
    
    private var clearButton: some View {
        Button("Clear") {
            emojiWasSelected("")
            dismiss()
        }
    }

    private var chooseButton: some View {
        Button("Choose") {
            chooseAndDismiss(selectedEmoji!)
        }
        .disabled(selectedEmoji == nil)
        .buttonStyle(.borderedProminent)
    }
    
    private func chooseAndDismiss(_ emoji: String.Element) {
        emojiWasSelected(String(emoji))
        dismiss()
    }
}

extension EmojiPicker {
    static let faces = "😀😃😄😁😆🥹😅😂🤣🥲☺️😊😇🙂🙃😉😌😍🥰😘😗😙😚😋😛😝😜🤪🤨🧐🤓😎🥸🤩🥳😏😒😞😔😟😕🙁☹️😣😖😫😩🥺😢😭😤😠😡🤬🤯😳🥵🥶😶‍🌫️😱😨😰😥😓🤗🤔🫣🤭🫢🫡🤫🫠🤥😶😐🫤😑😬🙄😯😦😧😮😲🥱😴🤤😪😮‍💨😵😵‍💫🤐🥴🤢🤮🤧😷🤒🤕🤑🤠😈👿👹👺🤡💩👻💀☠️👽👾🤖🎃😺😸😹😻😼😽🙀😿😾"
}

struct EmojiSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiPicker(selected: "", showClearButton: true, showCancelButton: true) { _ in }
    }
}
