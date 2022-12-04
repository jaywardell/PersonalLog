//
//  TagsListView.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/4/22.
//

import SwiftUI

struct TagsListView: View {
    
    let prompt: String
    let tags: [String]
    
    let showCancelButton: Bool

    let tagsWereChanged: ([String])->()
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List(tags, id: \.self) { tag in
                Text(tag)
                    .font(.body)
            }
            .listStyle(.plain)
            .navigationTitle(prompt)
            .navigationBarItems(leading: cancelButton, trailing: doneButton)
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
    

    private var doneButton: some View {
        Button("Choose") {
            tagsWereChanged(tags)
            dismiss()
        }
        .buttonStyle(.borderedProminent)
    }

}

struct TagsListView_Previews: PreviewProvider {
    static var previews: some View {
        TagsListView(prompt: "Tags", tags: [], showCancelButton: true) {_ in }
            .previewDisplayName("Empty")
        TagsListView(prompt: "Tags", tags: ["fun", "delightful", "great weather", "awesome", "wonderful", "terrific"], showCancelButton: true) {_ in }
            .previewDisplayName("Lots")
    }
}
