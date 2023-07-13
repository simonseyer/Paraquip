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
    @Environment(\.managedObjectContext) private var managedObjectContext

    @SectionedFetchRequest
    private var allEquipment: SectionedFetchResults<Int16, Equipment>
    
    init(profile: Profile) {
        self.profile = profile
        _allEquipment = SectionedFetchRequest(
            previewEntity: Equipment.previewEntity,
            sectionIdentifier: \Equipment.type,
            sortDescriptors: Equipment.defaultSortDescriptors()
        )
    }

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
            }

            ForEach(allEquipment) { section in
                Section {
                    ForEach(section) { equipment in
                        EquipmentSelectionRow(
                            profile: profile,
                            equipment: equipment
                        )
                    }
                } header: {
                    ProfileSectionHeader(equipmentType: section.id)
                }
            }
        }
        .navigationTitle(profile.profileName.isEmpty ? LocalizedString("New Set") : profile.profileName)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
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

struct EditProfileView_Previews: PreviewProvider {

    static var previews: some View {
        NavigationStack {
            EditProfileView(profile: CoreData.fakeProfile)
                .environment(\.managedObjectContext, .preview)
        }
    }
}
