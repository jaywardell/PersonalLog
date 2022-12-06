//
//  TopBar.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/6/22.
//

import SwiftUI

struct Toolbar: View {
    
    let calendarButtonTapped: ()->()
    let tagsButtonTapped: ()->()
    let addButtonTapped: ()->()
    
    var body: some View {
        HStack{
            
            Button(action: tagsButtonTapped) {
                Image(systemName: "magnifyingglass")
                    .font(.title)
            }
            .padding(.leading)

            Button(action: calendarButtonTapped) {
                Image(systemName: "calendar")
                    .font(.title)
            }
            .padding(.leading)

            Button(action: tagsButtonTapped) {
                Image(systemName: "tag")
                    .font(.title)
            }
            .padding(.leading)

            Spacer()
            
            Button(action: addButtonTapped) {
                Image(systemName: "plus")
                    .font(.largeTitle)
                    .bold()
            }
        }
        .padding(.horizontal)
    }
}
