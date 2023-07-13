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
    @State private var deleteEquipment: Equipment?
    @State private var isDeletingEquipment = false
    @State private var isShowingWeightView = false
    @State private var isAddingEquipment = false
    @State private var addEquipmentType: Equipment.EquipmentType?
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.locale) var locale: Locale

    @FetchRequest
    private var equipment: FetchedResults<Equipment>

    @FetchRequest
    private var allEquipment: FetchedResults<Equipment>

    private var title: String {
        profile?.profileName ?? LocalizedString("All Equipment")
    }

    init(profile: Profile?) {
        self.profile = profile
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
                }
            } else {
                AddEquipmentButton {
                    addEquipment(type: type)
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
                    }
                }
            } header: {
                ProfileSectionHeader(equipmentType: type)
            }
        } else {
            EmptyView()
        }
    }

    var body: some View {
        List {
            if profile != nil {
                singleSection(.paraglider)
                singleSection(.harness)
            } else {
                listSection(.paraglider)
                listSection(.harness)
            }
            listSection(.reserve)
            listSection(.gear)
        }
        .listStyle(.insetGrouped)
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                if profile != nil {
                    Button {
                        isShowingWeightView = true
                    } label: {
                        Label("Weight Check", systemImage: "scalemass.fill")
                    }
                }
            }
            ToolbarItem(placement: .primaryAction) {
                AddEquipmentMenu(canEditProfile: profile != nil) { type in
                    addEquipment(type: type)
                } onEditProfile: {
                    editProfile()
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
        .confirmationDialog("Add equipment", isPresented: $isAddingEquipment, presenting: $addEquipmentType) { equipmentType in
            let type = equipmentType.wrappedValue!
            let typeName = LocalizedString(type.localizedNameString)
            Button("Add existing \(typeName)") {
                editProfile()
            }
            Button("Create new \(typeName)") {
                createEquipment(type: type)
            }
        }
        .confirmationDialog(Text("Delete equipment"), isPresented: $isDeletingEquipment, presenting: deleteEquipment) { equipment in
            Button("Delete", role: .destructive) {
                withAnimation {
                    managedObjectContext.delete(equipment)
                    try! managedObjectContext.save()
                }
            }
            Button("Remove from set") {
                withAnimation {
                    profile?.removeFromEquipment(equipment)
                    try! managedObjectContext.save()
                }
            }
            Button("Cancel", role: .cancel) {}
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

    func addEquipment(type: Equipment.EquipmentType) {
        let filteredEquipment = allEquipment.filter { $0.equipmentType == type }
        guard profile != nil, !filteredEquipment.isEmpty else {
            createEquipment(type: type)
            return
        }
        addEquipmentType = type
        isAddingEquipment = true
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
        deleteEquipment = equipment
        isDeletingEquipment = true
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
                ProfileView(profile: CoreData.fakeProfile)
            }

            NavigationStack {
                ProfileView(profile: Profile.create(context: .preview, name: "Empty"))
            }
            .previewDisplayName("Empty Profile")
            
            NavigationStack {
                ProfileView(profile: nil)
            }
            .previewDisplayName("All Equipment")
        }
        .environment(\.locale, .init(identifier: "de"))
        .environment(\.managedObjectContext, .preview)
    }
}
