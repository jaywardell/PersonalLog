//
//  TopBar.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/6/22.
//

import SwiftUI

struct Toolbar: View {
    
    let addButtonTapped: ()->()
    
    var body: some View {
        HStack{
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

struct TopBar_Previews: PreviewProvider {
    static var previews: some View {
        Toolbar() {}
    }
}
