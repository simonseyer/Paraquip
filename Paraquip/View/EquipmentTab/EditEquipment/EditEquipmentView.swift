//
//  EditEquipmentView.swift
//  Paraquip
//
//  Created by Simon Seyer on 02.10.23.
//

import SwiftUI

struct EditEquipmentView: View {

    let profile: Profile?
    let equipment: Equipment?

    @Environment(\.managedObjectContext) private var managedObjectContext

    var body: some View {
        if let equipment {
            EditEquipmentContentView(equipment: equipment)
        } else {
            if profile?.allEquipment.isEmpty ?? false {
                ContentUnavailableView("Create an equipment first", systemImage: "backpack.fill")
            } else {
                ContentUnavailableView("Select an equipment",
                                       systemImage: "backpack.fill")
            }
        }
    }
}

#Preview {
    EditEquipmentView(profile: CoreData.fakeProfile,
                      equipment: CoreData.fakeProfile.paraglider)
        .environment(\.managedObjectContext, CoreData.previewContext)
}
