//
//  EmojiSelectionView.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/4/22.
//

import SwiftUI

struct EmojiSelectionView: View {
    
    let allowableEmoji = Array("😀😃😄😁😆🥹😅😂🤣🥲☺️😊😇🙂🙃😉😌😍🥰😘😗😙😚😋😛😝😜🤪🤨🧐🤓😎🥸🤩🥳😏😒😞😔😟😕🙁☹️😣😖😫😩🥺😢😭😤😠😡🤬🤯😳🥵🥶😶‍🌫️😱")
    
    let emojiWasSelected: (String) -> ()
    
    var vGridLayout = [ GridItem(.adaptive(minimum: 50)) ]

    @State private var selectedEmoji: String.Element?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: vGridLayout, content: {
                    ForEach(allowableEmoji, id: \.self) { emoji in
                        Text(String(emoji))
                            .background(RoundedRectangle(cornerRadius: 4).foregroundColor(backgroundColor(for: emoji)))
                            .onTapGesture { userTapped(emoji) }
                    }
                })
                .font(.largeTitle)
            }
            .navigationTitle("How do you feel?")
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
            emojiWasSelected(String(selectedEmoji!))
            dismiss()
        }
        .disabled(selectedEmoji == nil)
        .buttonStyle(.borderedProminent)
    }
}

struct EmojiSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiSelectionView() { _ in }
    }
}