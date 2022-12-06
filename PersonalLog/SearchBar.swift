//
//  SearchBar.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/6/22.
//
// mostly lifted from https://www.appcoda.com/swiftui-search-bar/

import SwiftUI

struct SearchBar: View {
    
    let searchWasUpdated: (String)->()
    
    @State private var text: String = ""

    @State private var isEditing = false

    var body: some View {
        HStack {

            TextField("Search ...", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)

                        if isEditing {
                            Button(action: {
                                self.text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .padding(.horizontal, 10)
                .onTapGesture {
                    self.isEditing = true
                }

            if isEditing {
                Button(action: {
                    self.isEditing = false
                    self.text = ""

                }) {
                    Text("Cancel")
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
//                .animation(.default)
            }
        }
        .onChange(of: text, perform: searchWasUpdated)
//        .background(Color.green)
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar() {_ in }
    }
}
