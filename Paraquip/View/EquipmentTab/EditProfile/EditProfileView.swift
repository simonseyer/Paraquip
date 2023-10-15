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
    
    @State private var isDeletingProfile = false

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
                HStack {
                    Text("Name")
                    Spacer()
                    TextField("", text: $profile.profileName)
                        .multilineTextAlignment(.trailing)
                }
                Picker("Icon", selection: $profile.profileIcon) {
                    ForEach(Profile.Icon.allCases) { icon in
                        Image(systemName: icon.systemName)
                            .tag(icon)
                            #if os(iOS)
                            .symbolVariant(.fill)
                            #endif
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

            if !profile.isInserted {
                Section("Set") {
                    Button(role: .destructive) {
                        isDeletingProfile = true
                    } label: {
                        Label("Delete set",
                              systemImage: "trash")
                        .foregroundStyle(.red)
                    }
                    .confirmationDialog(Text("Delete set"), isPresented: $isDeletingProfile) {
                        Button("Delete", role: .destructive) {
                            withAnimation {
                                managedObjectContext.delete(profile)
                                try! managedObjectContext.save()
                            }
                        }
                        Button("Delete with equipment", role: .destructive) {
                            withAnimation {
                                profile.allEquipment.forEach {
                                    managedObjectContext.delete($0)
                                }
                                managedObjectContext.delete(profile)
                                try! managedObjectContext.save()
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Set")
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

#Preview {
    NavigationStack {
        EditProfileView(profile: CoreData.fakeProfile)
            .environment(\.managedObjectContext, .preview)
    }
}
