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
                    .font(.title)
                    .fontWeight(.semibold)
                Spacer()
            }
        }
        .listRowBackground(Color.accentColor.opacity(0.25))
    }
}

#Preview {
    List {
        AddEquipmentButton {}
    }
}
