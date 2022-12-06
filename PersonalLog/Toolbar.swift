//
//  TopBar.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/6/22.
//

import SwiftUI

struct Toolbar: View {
    
    let searchButtonTapped: ()->()
    let calendarButtonTapped: ()->()
    let addButtonTapped: ()->()
    
    var body: some View {
        HStack{
            
            Button(action: searchButtonTapped) {
                Image(systemName: "magnifyingglass")
                    .font(.title)
            }
            .padding(.leading)

            Button(action: calendarButtonTapped) {
                Image(systemName: "calendar")
                    .font(.title)
            }
            .padding(.leading)

            Spacer()
            
            Button(action: addButtonTapped) {
                Image(systemName: "plus")
                    .font(.largeTitle)
                    .bold()
                    .padding()
            }
            .buttonStyle(AddButtonStyle())
        }
        .padding(.horizontal)
    }
}


fileprivate struct AddButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(!configuration.isPressed ? Color(uiColor: .systemBackground) : .accentColor)
            .background(Circle().foregroundColor(configuration.isPressed ?
                                            Color(uiColor: .systemBackground) :
                                                Color.accentColor
                                                ))
    }
}
