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
    
    var vGridLayout = [ GridItem(.adaptive(minimum: 50)) ]

    @State private var selectedEmoji: String.Element?
    @Environment(\.dismiss) var dismiss

    init(prompt: String = "", allowed: String = Self.faces, selected: String, emojiWasSelected: @escaping (String) -> ()) {
        self.prompt = prompt
        self.allowableEmoji = Array(allowed)
        self.emojiWasSelected = emojiWasSelected
        
        _selectedEmoji = .init(initialValue: selected.first)
    }
    
    var body: some View {
        NavigationStack {
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
            .navigationTitle(prompt)
            .navigationBarItems(leading: cancelButton, trailing: chooseButton)
        }
    }
    
    private func backgroundColor(for emoji: String.Element) -> Color {
        emoji == self.selectedEmoji ? Color.accentColor : Color.clear
    }
    
    private func userTapped(_ emoji: String.Element) {
        self.selectedEmoji = emoji == self.selectedEmoji ? nil : emoji
    }
    
    private var cancelButton: some View {
        Button("Cancel") {
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
        EmojiPicker(selected: "") { _ in }
    }
}
