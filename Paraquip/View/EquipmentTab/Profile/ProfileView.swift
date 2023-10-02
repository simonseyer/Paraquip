//
//  ProfileView.swift
//  Paraquip
//
//  Created by Simon Seyer on 09.04.21.
//

import SwiftUI
import CoreData

struct ProfileView: View {

    @ObservedObject var profile: Profile
    @Binding var selectedEquipment: Equipment?

    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var editProfileOperation: Operation<Profile>?

    var body: some View {
        ProfileContentView(predicate: profile.equipmentPredicate,
                           selectedEquipment: $selectedEquipment,
                           didCreateEquipment: { equipment in
            profile.addToEquipment(equipment)
        })
        .navigationTitle(profile.profileName)
        .onChange(of: profile) {
            if let selectedEquipment, !(profile.contains(selectedEquipment)) {
                self.selectedEquipment = nil
            }
        }
        .toolbar {
            ToolbarItem {
                Button {
                    editProfile()
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                #if os(iOS)
                .labelStyle(.titleOnly)
                #endif
            }
        }
        .sheet(item: $editProfileOperation) { operation in
            NavigationStack {
                EditProfileView(profile: operation.object)
                    .environment(\.managedObjectContext, operation.childContext)
            }
        }
    }

    func editProfile() {
        editProfileOperation = Operation(editing: profile,
                                         withParentContext: managedObjectContext)
    }

}

struct AllEquipmentProfileView: View {
    @Binding var selectedEquipment: Equipment?

    var body: some View {
        ProfileContentView(predicate: nil,
                           selectedEquipment: $selectedEquipment)
        .navigationTitle("All Equipment")
    }
}

private struct ProfileContentView: View {
    @Binding var selectedEquipment: Equipment?
    let didCreateEquipment: (Equipment) -> Void

    @Environment(\.managedObjectContext) var managedObjectContext

    @FetchRequest
    private var equipment: FetchedResults<Equipment>

    private var isSpecificProfile: Bool {
        equipment.nsPredicate != nil
    }

    init(predicate: NSPredicate?,
         selectedEquipment: Binding<Equipment?>,
         didCreateEquipment: @escaping (Equipment) -> Void = { _ in }) {
        self._selectedEquipment = selectedEquipment
        self.didCreateEquipment = didCreateEquipment
        _equipment = FetchRequest(
            previewEntity: Equipment.previewEntity,
            sortDescriptors: Equipment.defaultSortDescriptors(),
            predicate: predicate
        )
    }

    @ViewBuilder
    func singleSection(_ type: Equipment.EquipmentType) -> some View {
        let filteredEquipment = equipment.first {
            $0.equipmentType == type
        }
        Section {
            if let equipment = filteredEquipment {
                NavigationLink(value: equipment) {
                    EquipmentRow(equipment: equipment)
                }
            } else {
                Button {
                    createEquipment(type: type)
                } label: {
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
        } header: {
            ProfileSectionHeader(equipmentType: type)
        }
    }

    @ViewBuilder
    func listSection(_ type: Equipment.EquipmentType) -> some View {
        let filteredEquipment = equipment.filter {
            $0.equipmentType == type
        }
        Section {
            ForEach(filteredEquipment) { equipment in
                NavigationLink(value: equipment) {
                    EquipmentRow(equipment: equipment)
                }
            }
            Button {
                createEquipment(type: type)
            } label: {
                Label("Add \(type.localizedName)", systemImage: "plus")
            }
            .foregroundStyle(.primary)
        } header: {
            ProfileSectionHeader(equipmentType: type)
        }
    }

    var body: some View {
        List(selection: $selectedEquipment) {
            if isSpecificProfile {
                singleSection(.paraglider)
                singleSection(.harness)
            } else {
                listSection(.paraglider)
                listSection(.harness)
            }
            listSection(.reserve)
            listSection(.gear)
            if let selectedEquipment {
                DeletionObserverView(object: selectedEquipment) {
                    self.selectedEquipment = nil
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    func createEquipment(type: Equipment.EquipmentType) {
        withAnimation {
            let equipment = Equipment.create(type: type, context: managedObjectContext)
            didCreateEquipment(equipment)
            selectedEquipment = equipment
        }
    }
}

struct ProfileView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            NavigationStack {
                ProfileView(profile: CoreData.fakeProfile, selectedEquipment: .constant(nil))
            }

            NavigationStack {
                ProfileView(profile: Profile.create(context: .preview, name: "Empty"), selectedEquipment: .constant(nil))
            }
            .previewDisplayName("Empty Profile")

            NavigationStack {
                AllEquipmentProfileView(selectedEquipment: .constant(nil))
            }
            .previewDisplayName("All Equipment")
        }
        .environment(\.locale, .init(identifier: "de"))
        .environment(\.managedObjectContext, .preview)
    }
}
