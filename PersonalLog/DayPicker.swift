//
//  DayPicker.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/6/22.
//

import SwiftUI

struct DayPicker: View {
    
    @State var selectedDates: Set<DateComponents> = []

    let dayWasChosen: (Date)->()
    
    var body: some View {
        VStack {
            Divider()
            MultiDatePicker("Pick a Day", selection: $selectedDates)
                .padding(.horizontal)
                .onChange(of: selectedDates) { newValue in
                    if let firstComponents = selectedDates.first,
                    let day = Calendar.current.date(from: firstComponents) {
                        dayWasChosen(day)
                    }
                    selectedDates = []
                }
                .padding(.bottom)
                .padding(.bottom)
        }
            .background(Color(uiColor: .secondarySystemBackground))
    }
}

struct DayPicker_Previews: PreviewProvider {
    static var previews: some View {
        DayPicker() { _ in }
    }
}
