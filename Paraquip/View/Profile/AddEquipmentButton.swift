//
//  AddEquipmentButton.swift
//  Paraquip
//
//  Created by Simon Seyer on 22.03.23.
//

import SwiftUI

struct AddEquipmentButton: View {

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Image(systemName: "plus")
                Spacer()
            }
        }
        .frame(height: 50)
        .font(.title)
        .listRowBackground(Color.accentColor.opacity(0.25))
    }
}

struct AddEquipmentButton_Previews: PreviewProvider {
    static var previews: some View {
        List {
            AddEquipmentButton {}
        }
    }
}
