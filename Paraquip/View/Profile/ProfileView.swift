//
//  ProfileView.swift
//  Paraquip
//
//  Created by Simon Seyer on 09.04.21.
//

import SwiftUI
import CoreData

struct ProfileView: View {

    let profile: Profile?
    @State private var editEquipmentOperation: Operation<Equipment>?
    @State private var editProfileOperation: Operation<Profile>?
    @State private var isShowingWeightView = false
    @State private var addEquipmentType: Equipment.EquipmentType?
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.locale) var locale: Locale

    @Binding var selectedEquipment: Equipment?

    @FetchRequest
    private var equipment: FetchedResults<Equipment>

    @FetchRequest
    private var allEquipment: FetchedResults<Equipment>

    private var title: String {
        profile?.profileName ?? LocalizedString("All Equipment")
    }

    init(profile: Profile?, selectedEquipment: Binding<Equipment?>) {
        self.profile = profile
        self._selectedEquipment = selectedEquipment
        _equipment = FetchRequest(
            previewEntity: Equipment.previewEntity,
            sortDescriptors: Equipment.defaultSortDescriptors(),
            predicate: profile?.equipmentPredicate
        )
        _allEquipment = FetchRequest(
            previewEntity: Equipment.previewEntity,
            sortDescriptors: Equipment.defaultSortDescriptors()
        )
    }

    @ViewBuilder
    func singleSection(_ type: Equipment.EquipmentType) -> some View {
        Section {
            if let equipment = profile?.singleEquipment(of: type) {
                EquipmentRow(equipment: equipment) {
                    editEquipment(equipment)
                } onDelete: {
                    deleteEquipment(equipment)
                } onRemoveFromSet: {
                    removeEquipmentFromSet(equipment)
                }
            } else {
                AddEquipmentButton {
                    createEquipment(type: type)
                }
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
        if !filteredEquipment.isEmpty {
            Section {
                ForEach(filteredEquipment) { equipment in
                    EquipmentRow(equipment: equipment) {
                        editEquipment(equipment)
                    } onDelete: {
                        deleteEquipment(equipment)
                    } onRemoveFromSet: {
                        removeEquipmentFromSet(equipment)
                    }
                }
            } header: {
                ProfileSectionHeader(equipmentType: type)
            }
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    func footerSection() -> some View {
        Section {
            EmptyView()
        } footer: {
            HStack {
                Spacer()
                EditProfileMenu(canEditProfile: profile != nil) { type in
                    createEquipment(type: type)
                } onEditProfile: {
                    editProfile()
                }
                Spacer()
            }
        }
    }

    var body: some View {
        List(selection: $selectedEquipment) {
            if profile != nil {
                singleSection(.paraglider)
                singleSection(.harness)
            } else {
                listSection(.paraglider)
                listSection(.harness)
            }
            listSection(.reserve)
            listSection(.gear)
            footerSection()
        }
        .listStyle(.insetGrouped)
        .environment(\.defaultMinListRowHeight, 10)
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                if profile != nil {
                    Button {
                        isShowingWeightView = true
                    } label: {
                        Label("Weight Check", systemImage: "scalemass.fill".deviceSpecificIcon)
                    }
                }
            }
        }
        .sheet(item: $editEquipmentOperation) { operation in
            NavigationStack {
                EditEquipmentView(equipment: operation.object)
                    .environment(\.managedObjectContext, operation.childContext)
            }
        }
        .sheet(item: $editProfileOperation) { operation in
            NavigationStack {
                EditProfileView(profile: operation.object)
                    .environment(\.managedObjectContext, operation.childContext)
            }
        }
        .sheet(isPresented: $isShowingWeightView) {
            NavigationStack {
                if let profile {
                    ProfileWeightView(profile: profile)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Close") {
                                    isShowingWeightView = false
                                }
                            }
                        }
                }
            }
        }
    }

    func createEquipment(type: Equipment.EquipmentType) {
        let operation: Operation<Equipment> = Operation(withParentContext: managedObjectContext) { context in
            Equipment.create(type: type, context: context)
        }
        if let profile {
            operation.object(for: profile).addToEquipment(operation.object)
        }
        editEquipmentOperation = operation
    }

    func editEquipment(_ equipment: Equipment) {
        editEquipmentOperation = .init(editing: equipment,
                                       withParentContext: managedObjectContext)
    }

    func deleteEquipment(_ equipment: Equipment) {
        withAnimation {
            managedObjectContext.delete(equipment)
            try! managedObjectContext.save()
        }
    }

    func removeEquipmentFromSet(_ equipment: Equipment) {
        withAnimation {
            profile?.removeFromEquipment(equipment)
            try! managedObjectContext.save()
        }
    }

    func editProfile() {
        guard let profile else { return }
        editProfileOperation = Operation(editing: profile,
                                         withParentContext: managedObjectContext)
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
                ProfileView(profile: nil, selectedEquipment: .constant(nil))
            }
            .previewDisplayName("All Equipment")
        }
        .environment(\.locale, .init(identifier: "de"))
        .environment(\.managedObjectContext, .preview)
    }
}
