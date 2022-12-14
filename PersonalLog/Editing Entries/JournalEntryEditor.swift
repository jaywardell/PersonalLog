//
//  JournalEntryEditor.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/4/22.
//

import SwiftUI



struct JournalEntryEditor: View {
    
    final class ViewModel: ObservableObject {
        
        @Published var date: Date
        
        // tends to be an emoji, only 1 character long
        @Published var mood = ""
        
        // empty by default
        @Published var title = ""
        
        // empty by default
        @Published var prompt = ""
        
        // empty for new entries
        @Published var text = ""
        
        @Published var tags = [String]()
        
        let save: (ViewModel)->()
        
        init(date: Date,
            mood: String,
             title: String,
             prompt: String,
             text: String,
             tags: [String],
            save: @escaping (ViewModel)->()) {
            self.date = date
            self.mood = mood
            self.title = title
            self.prompt = prompt
            self.text = text
            self.tags = tags
            self.save = save
        }
        
        convenience init(_ save: @escaping (ViewModel)->()) {
            self.init(date: Date(), mood: "", title: "", prompt: "", text: "", tags: [], save: save)
        }
        
        // there's no point in saving a journal entry if it doesn't either record a mood or have text
        var hasGoodData: Bool {
            !mood.isEmpty || !text.isEmpty
        }
    }
    
    let prompt: String
    @ObservedObject var viewModel: ViewModel
    
    enum FocusField: Hashable { case title, text }

    @FocusState private var focusedField: FocusField?

    @State private var showEmojiPicker = false
    @State private var showTagsList = false
    @State private var showPromptsList = false

    @Environment(\.dismiss) var dismiss

    private var moodButtonTitle: String {
        viewModel.mood.isEmpty ? "🫥" : viewModel.mood
    }

    private var tagsButtonTitle: String {
        "tags: " + viewModel.tags.joined(separator: ", ")
    }

    private var promptsButtonTitle: String {
        viewModel.prompt.isEmpty ? "what can I write about?" : viewModel.prompt
    }
    
    private var moodButtonSpacer: some View {
        Text(" ").font(.caption)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack(alignment: .top) {
                    VStack {
                        moodButtonSpacer
                        Button(moodButtonTitle) {
                            showEmojiPicker = true
                        }
                        .opacity(viewModel.mood.isEmpty ? 0.25 : 1)
                        .font(.largeTitle)
                    }
                    .padding(.trailing)

                    VStack {
                        if let date = viewModel.date {
                            HStack {
                                Spacer()
                                Text(date, style: .date)
                                Text(date, style: .time)
                            }
                            .font(.caption)
                            .foregroundColor(Color(uiColor: .secondaryLabel))
                        }
                        
                        HStack {
                            
                            TextField("Title (optional)", text: $viewModel.title)
                                .font(.headline)
                                .focused($focusedField, equals: .title)
                            Spacer()
                        }

                        HStack {
                            Button(action : {
                                showTagsList = true
                            }) {
                                HStack(alignment: .top) {
                                    Image(systemName: "tag")
                                    Text(tagsButtonTitle)
                                        .multilineTextAlignment(.leading)
                                }
                                .font(.caption)
                            }
                            .accentColor(Color(uiColor: viewModel.tags.isEmpty ? .placeholderText : .label))
                            Spacer()
                        }

                        // only make the prompts picker available if the user hasn't already started to write OR if she's chosen a prompt already
                        if !viewModel.prompt.isEmpty || viewModel.text.isEmpty {
                            
                            HStack {
                                Button(action : {
                                    showPromptsList = true
                                }) {
                                    Text(promptsButtonTitle)
                                        .font(.subheadline)
                                        .foregroundColor(viewModel.prompt.isEmpty ? Color(uiColor: .placeholderText) : Color(uiColor: .secondaryLabel))
                                        .multilineTextAlignment(.leading)
                                }
                                .accentColor(Color(uiColor: viewModel.tags.isEmpty ? .placeholderText : .label))
                                Spacer()
                            }
                            .padding(.top)
                        }
                    }
                }
                TextEditor(text: $viewModel.text)
                    .font(.system(.body, design: .default))
                    .focused($focusedField, equals: .text)
            }
            .padding()
            .navigationTitle(prompt)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: cancelButton, trailing: saveButton)
            .onAppear { self.focusedField = .text }
            .sheet(isPresented: $showEmojiPicker) {
                EmojiPicker(prompt: "How do you feel?", selected: viewModel.mood) { viewModel.mood = $0 }
            }
            .sheet(isPresented: $showTagsList) {
                TagsListView(prompt: "Edit Tags", tags: viewModel.tags) { viewModel.tags = $0 }
            }
            .sheet(isPresented: $showPromptsList) {
                PromptPicker(initialPhrase: viewModel.prompt) { viewModel.prompt = $0
                }
            }
        }
    }
}

// MARK: - JournalEntryView: Component Views

extension JournalEntryEditor {
    
    private var cancelButton: some View {
        Button(action: { dismiss() }) {
            Text("Cancel")
        }
    }

    private var saveButton: some View {
        Button(action: { viewModel.save(viewModel); dismiss() }) {
            Text("Save")
        }
        .buttonStyle(.borderedProminent)
        .disabled(!viewModel.hasGoodData)
    }
}

// MARK: - JournalEntryView.ViewModel: Convenience Initializers
fileprivate extension JournalEntryEditor.ViewModel {
    static var empty: Self {
        .init(date: Date(), mood: "", title: "", prompt: "", text: "", tags: [], save: { _ in })
    }
    
    static var thorough: Self {
        .init(date: Date(), mood: "😆", title: "A Fun Day", prompt: "What was today like?", text: "It was awesome! We swam and fished and danced and played and talked and talked and talked and talked and talked", tags: ["fun", "delightful", "great weather", "awesome", "wonderful", "terrific"], save: { _ in })
    }

}

// MARK: - Preview

struct JournalEntryView_Previews: PreviewProvider {
    static var previews: some View {
        JournalEntryEditor(prompt: "New Entry", viewModel: .empty)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Empty")

        JournalEntryEditor(prompt: "Edit Entry", viewModel: .thorough)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Everything Filled Out")
    }
}
