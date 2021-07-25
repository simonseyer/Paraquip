//
//  LogCheckView.swift
//  Paraquip
//
//  Created by Simon Seyer on 27.06.21.
//

import SwiftUI

struct LogCheckView: View {

    @State private var date = Date()

    let completion: (Date?) -> Void

    var body: some View {
        VStack {
            DatePicker("", selection: $date, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())

            Button(action: { completion(date) }) {
                Text( "Log check")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.accentColor))
                    .foregroundColor(.white)
            }
            .buttonStyle(PlainButtonStyle())

            Button("Cancel") { completion(nil) }
                .padding()
        }
        .padding()
        .navigationTitle("Log check")
    }
}

struct LogCheckView_Previews: PreviewProvider {
    static var previews: some View {
        LogCheckView() { _ in }
    }
}
