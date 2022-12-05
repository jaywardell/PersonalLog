//
//  TagsListView.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/4/22.
//

import SwiftUI

struct TagsListView: View {
    
    let prompt: String
    let startingTags: [String]
    @State private var tags: [String]
    
    let showCancelButton: Bool

    let tagsWereChanged: ([String])->()

    @State private var presentNewTagPrompt = false
    @State private var newTag = ""
    @Environment(\.dismiss) var dismiss

    init(prompt: String, tags: [String], showCancelButton: Bool = true,  tagsWereChanged: @escaping ([String])->()) {
        self.prompt = prompt
        self.startingTags = tags
        self.showCancelButton = showCancelButton
        self.tagsWereChanged = tagsWereChanged

        _tags = .init(initialValue: tags)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag)
                            .font(.body)
                    }
                    .onDelete { indexSet in
                        self.tags.remove(atOffsets: indexSet)
                    }
                    
                    Button(action: userTappedAddButton) {
                        Image(systemName: "plus")
                            .font(.body)
                            .bold()
                    }
                }
                .listStyle(.plain)
                
                HStack {
                    Spacer()
                    doneButton
                }
                .padding()
            }
            .navigationTitle(prompt)
            .navigationBarItems(leading: cancelButton)
            .alert("New Tag", isPresented: $presentNewTagPrompt, actions: {
                // Any view other than Button would be ignored
                TextField("new tag", text: $newTag)
            }, message: {
                // Any view other than Text would be ignored
                Text("enter the name of the new tag")
            })
            .onChange(of: presentNewTagPrompt, perform: newTagPromptWasPresented)

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
        Button("Done") {
            tagsWereChanged(tags)
            dismiss()
        }
        .buttonStyle(.borderedProminent)
        .disabled(startingTags == tags)
    }

    private func userTappedAddButton() {
        presentNewTagPrompt = true
    }
    
    private func newTagPromptWasPresented(_ presented: Bool) {
        guard !presented else { return }
        guard !newTag.isEmpty else { return }
        
        withAnimation {
            tags.append(newTag)
        }
        
        
        newTag = ""
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
