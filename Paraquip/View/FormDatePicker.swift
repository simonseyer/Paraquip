//
//  FormDatePicker.swift
//  Paraquip
//
//  Created by Simon Seyer on 15.05.21.
//

import SwiftUI

struct FormDatePicker: View {

    let label: LocalizedStringKey

    @Binding var date: Date?

    @State private var datePickerShown: Bool = false
    @State private var selectedDate: Date

    @Environment(\.locale) private var locale

    init(label: LocalizedStringKey, date: Binding<Date?>) {
        self.label = label
        self._date = date
        self._selectedDate = State(initialValue: date.wrappedValue ?? Date())

    }

    var body: some View {
        Group {
            Button(action: {
                date = selectedDate
                withAnimation {
                    datePickerShown.toggle()
                }
            }) {
                HStack {
                    Text(label)
                    Spacer()
                    if date != nil {
                        Text(selectedDate, style: .date)
                        Button(action: deselectDate) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .font(.system(size: 15))
                        }
                    } else {
                        Text(label)
                            .foregroundColor(Color(UIColor.placeholderText))
                    }
                }
            }
            .foregroundColor(.primary)

            if datePickerShown {
                HStack {
                    DatePicker("",
                               selection: $selectedDate,
                               displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                }
            }
        }
        .onChange(of: selectedDate) { value in
            date = value
        }
        .onChange(of: date) { value in
            if let date = value {
                selectedDate = date
            } else {
                deselectDate()
            }
        }
    }

    private func deselectDate() {
        date = nil
        withAnimation {
            datePickerShown = false
        }
    }
}

struct FormDatePicker_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            FormDatePicker(label: "No date", date: .constant(nil))
        }
        Form {
            FormDatePicker(label: "Some date", date: .constant(Date()))
        }
    }
}
