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
        if ProcessInfo.isPreview {
            _allEquipment = SectionedFetchRequest(
                entity: NSEntityDescription.entity(forEntityName: "Equipment", in: CoreData.previewContext)!,
                sectionIdentifier: \Equipment.type,
                sortDescriptors: [
                    NSSortDescriptor(key: "type", ascending: true),
                    NSSortDescriptor(key: "brand", ascending: true),
                    NSSortDescriptor(key: "name", ascending: true)
                ]
            )
        } else {
            _allEquipment = SectionedFetchRequest(
                sectionIdentifier: \Equipment.type,
                sortDescriptors: [
                    SortDescriptor(\Equipment.type),
                    SortDescriptor(\.brand),
                    SortDescriptor(\.name)
                ]
            )
        }
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
        .navigationTitle(profile.profileName.isEmpty ? NSLocalizedString("New Set", comment: "") : profile.profileName)
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
        .defaultBackground()
    }
}

struct EditProfileView_Previews: PreviewProvider {

    static var previews: some View {
        NavigationView {
            EditProfileView(profile: CoreData.fakeProfile)
                .environment(\.managedObjectContext, CoreData.previewContext)
        }
    }
}
