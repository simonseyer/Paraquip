//
//  EditProfileView.swift
//  EditProfileView
//
//  Created by Simon Seyer on 26.08.21.
//

import SwiftUI
import CoreData

struct EditProfileView: View {

    @ObservedObject var profile: Profile
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) var managedObjectContext

    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.brand),
        SortDescriptor(\.name)
    ])
    private var allEquipment: FetchedResults<Equipment>

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $profile.profileName)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Profile.Icon.allCases) { icon in
                            IconSelectionView(
                                icon: icon,
                                isSelected: icon == profile.profileIcon)
                                .onTapGesture {
                                    profile.profileIcon = icon
                                }
                        }
                    }
                }
            } footer: {
                Text("icon_attribution")
            }

            if !allEquipment.isEmpty {
                Section(header: Text("Equipment")) {
                    ForEach(allEquipment, id: \.id) { equipment in
                        Button(action: {
                            if profile.equipment?.contains(equipment) ?? false {
                                profile.removeFromEquipment(equipment)
                            } else {
                                profile.addToEquipment(equipment)
                            }
                        }) {
                            HStack {
                                Text(equipment.brandName)
                                    .foregroundColor(.secondary)
                                Text(equipment.equipmentName)
                                Spacer()
                                if profile.equipment?.contains(equipment) ?? false {
                                    Image(systemName: "checkmark")
                                        .font(.system(.body).weight(.medium))
                                        .foregroundColor(.accentColor)
                                }}
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
        }
        .navigationTitle(profile.profileName.isEmpty ? NSLocalizedString("New Set", comment: "") : profile.profileName)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    managedObjectContext.rollback()
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    try! managedObjectContext.save()
                    dismiss()
                }
                .disabled(profile.profileName.isEmpty)
            }
        }
    }
}

struct EdiProfileView_Previews: PreviewProvider {

    static var previews: some View {
        NavigationView {
            EditProfileView(profile: CoreData.fakeProfile)
                .environment(\.managedObjectContext, CoreData.previewContext)
        }
    }
}

struct IconSelectionView: View {

    let icon: Profile.Icon
    let isSelected: Bool

    var body: some View {
        Image(icon.rawValue)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding(12)
            .frame(width: 50, height: 50)
            .background(
                isSelected ? Color.accentColor :
                    Color(UIColor.systemGray5)
            )
            .cornerRadius(10)
    }
}
