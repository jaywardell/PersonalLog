//
//  JournalEntryEditor.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/4/22.
//

import SwiftUI



struct JournalEntryEditor: View {
    
    final class ViewModel: ObservableObject {
        
        @Published var date: Date?
        
        // tends to be an emoji, only 1 character long
        @Published var mood = ""
        
        // empty by default
        @Published var title = ""
        
        // empty by default
        @Published var prompt = ""
        
        // empty for new entries
        @Published var text = ""
        
        @Published var tags = [String]()
        
//        let cancel: ()->()
        let save: (ViewModel)->()
        
        init(date: Date? = nil,
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
        
        // there's no point in saving a journal entry if it doesn't either record a mood or have text
        var hasGoodData: Bool {
            !mood.isEmpty || !text.isEmpty
        }
    }
    
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
    
    var body: some View {
        NavigationView {
            VStack {
                if let date = viewModel.date {
                    HStack {
                        Spacer()
                        Text(date, style: .date)
                        Text(date, style: .time)
                    }
                    .font(.caption)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
                    .padding(.horizontal)
                }
                
                HStack {
                    Button(moodButtonTitle) {
                        showEmojiPicker = true
                    }
                    .opacity(viewModel.mood.isEmpty ? 0.25 : 1)
                    .font(.largeTitle)
                    
                    TextField("Title (optional)", text: $viewModel.title)
                        .font(.headline)
                        .focused($focusedField, equals: .title)
                    Spacer()
                }
                .padding(.horizontal)

                HStack {
                    Button(action : {
                        showTagsList = true
                    }) {
                        Text(tagsButtonTitle)
                            .font(.caption)
                            .multilineTextAlignment(.leading)
                    }
                    .accentColor(Color(uiColor: viewModel.tags.isEmpty ? .placeholderText : .label))
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.horizontal)

                // only make the prompts picker available if the suer hasn't already started to write OR if she's chosen a prompt already
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
                    .padding(.horizontal)
                    .padding(.horizontal)
                    .padding(.top)
                }
                
                                
                TextEditor(text: $viewModel.text)
                    .font(.system(.body, design: .serif))
                    .padding(.horizontal)
                    .focused($focusedField, equals: .text)
            }
            .padding()
            .navigationTitle("")
            .navigationBarItems(leading: cancelButton, trailing: saveButton)
            .onAppear { self.focusedField = .text }
            .sheet(isPresented: $showEmojiPicker) {
                EmojiPicker(prompt: "How do you feel?", selected: viewModel.mood) { viewModel.mood = $0 }
            }
            .sheet(isPresented: $showTagsList) {
                TagsListView(prompt: "Tags", tags: viewModel.tags) { viewModel.tags = $0 }
            }
            .sheet(isPresented: $showPromptsList) {
                PhrasesPicker(
                    prompt: "Pick a Topic",
                    message: "You can write about anything you want, but if you want some ideas, here's a list of journaling prompts:",
                    phrases: Self.Prompts,
                    initialPhrase: viewModel.prompt,
                    doneButtonTitle: "Write about This",
                    clearButtonTitle: "Write about Anything") { prompt in
                    viewModel.prompt = prompt
                }
            }
        }
    }
    
    static let Prompts = [
    "How has the day gone so far?",
    "What do you plan to do with your day?",
    "What are you grateful for today?"
    ]
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
        .disabled(!viewModel.hasGoodData)
    }
}

// MARK: - JournalEntryView.ViewModel: Convenience Initializers
fileprivate extension JournalEntryEditor.ViewModel {
    static var empty: Self {
        .init(mood: "", title: "", prompt: "", text: "", tags: [], save: { _ in })
    }
    
    static var thorough: Self {
        .init(date: Date(), mood: "😆", title: "A Fun Day", prompt: "What was today like?", text: "It was awesome! We swam and fished and danced and played and talked and talked and talked and talked and talked", tags: ["fun", "delightful", "great weather", "awesome", "wonderful", "terrific"], save: { _ in })
    }

}

// MARK: - Preview

struct JournalEntryView_Previews: PreviewProvider {
    static var previews: some View {
        JournalEntryEditor(viewModel: .empty)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Empty")

        JournalEntryEditor(viewModel: .thorough)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Everything Filled Out")
    }
}
