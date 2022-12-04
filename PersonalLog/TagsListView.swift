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
    
    var body: some View {
        NavigationStack {
            List(tags, id: \.self) { tag in
                Text(tag)
                    .font(.body)
            }
            .listStyle(.plain)
            .navigationTitle(prompt)
        }
    }
}

struct TagsListView_Previews: PreviewProvider {
    static var previews: some View {
        TagsListView(prompt: "Tags", tags: [])
            .previewDisplayName("Empty")
        TagsListView(prompt: "Tags", tags: ["fun", "delightful", "great weather", "awesome", "wonderful", "terrific"])
            .previewDisplayName("Lots")
    }
}
