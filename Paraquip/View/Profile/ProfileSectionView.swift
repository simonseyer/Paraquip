//
//  ProfileSectionView.swift
//  Paraquip
//
//  Created by Simon Seyer on 17.10.21.
//

import SwiftUI

struct ProfileSectionView: View {

    @Environment(\.managedObjectContext) var managedObjectContext

    let title: LocalizedStringKey
    let icon: String
    let equipment: [Equipment]

    var body: some View {
        if !equipment.isEmpty {
            Section {
                ForEach(equipment) { equipment in
                    NavigationLink {
                        EquipmentView(equipment: equipment)
                    } label: {
                        EquipmentRow(equipment: equipment)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        managedObjectContext.delete(equipment[index])
                    }
                    try! managedObjectContext.save()
                }
            } header: {
                HStack {
                    Image(icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.accentColor)
                        .frame(width: 25, height: 25)
                    Text(title)
                }
            }
        }
    }
}

struct ProfileSectionView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ProfileSectionView(title: "Paraglider", icon: "paraglider", equipment: CoreData.fakeProfile.paraglider)
        }
        .environment(\.managedObjectContext, CoreData.previewContext)
    }
}
