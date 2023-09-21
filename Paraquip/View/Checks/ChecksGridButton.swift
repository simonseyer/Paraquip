//
//  ChecksGridButton.swift
//  Paraquip
//
//  Created by Simon Seyer on 21.09.23.
//

import SwiftUI

struct ChecksGridButton: View {

    @ObservedObject var equipment: Equipment
    var logAction: (LogMenu.Action) -> Void

    @State private var isCheckLogPresented = false

    var body: some View {
        Button(action: {
            isCheckLogPresented = true
        }) {
            Label {
                Text(equipment.equipmentName)
                    .lineLimit(1)
                Spacer()
            } icon: {
                equipment.checkUrgency.icon
                    .frame(width: 25, height: 25)
                    .background(
                        Circle()
                            .fill(equipment.checkUrgency.color)
                    )
                    #if os(iOS)
                    .foregroundStyle(.white)
                    #endif
            }
        }
        .foregroundStyle(.primary)
        .buttonStyle(.bordered)
        .popover(isPresented: $isCheckLogPresented) {
            LogMenu(equipment: equipment) { action in
                isCheckLogPresented = false
                logAction(action)
            }
        }
    }
}

#Preview {
    ChecksGridButton(equipment: CoreData.fakeProfile.paraglider!) {_ in }
        #if os(visionOS)
        .glassBackgroundEffect()
        #endif
}
