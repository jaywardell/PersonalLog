//
//  TopBar.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/6/22.
//

import SwiftUI

struct Toolbar: View {
    
    let calendarButtonTapped: ()->()
    let addButtonTapped: ()->()
    
    var body: some View {
        VStack {
            Divider()
            
            HStack{
                
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
                .scaleEffect(x: 2.3, y: 2.3)
                .buttonStyle(AddButtonStyle())
                .padding(.trailing)

            }
            .padding(.horizontal)
        }
    }
}


fileprivate struct AddButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(!configuration.isPressed ? Color(uiColor: .systemBackground) : .accentColor)
            .background(
                Circle()
                    .foregroundStyle(configuration.isPressed ?
                                     Color(uiColor: .systemBackground).gradient :
                                        Color.accentColor.gradient
                                    )
                    .shadow(radius: 1)
            )
    }
}
