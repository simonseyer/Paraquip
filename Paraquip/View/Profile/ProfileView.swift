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
    @State private var showWeightView = false
    @State private var showAddEquipmentSheet = false
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
    func singleSection(type: Equipment.EquipmentType) -> some View {
        let filteredEquipment = equipment.first { $0.equipmentType == type }
        Section {
            if let equipment = filteredEquipment {
                EquipmentRow(equipment: equipment) {
                    editEquipmentOperation = .init(editing: equipment,
                                                   withParentContext: managedObjectContext)
                } onDelete: {
                    deleteEquipment = equipment
                    isDeletingEquipment = true
                }
            } else {
                Button(action: {
                    addEquipment(type: type)
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "plus")
                        Spacer()
                    }
                }
                .frame(height: 50)
                .font(.title)
                .listRowBackground(Color.accentColor.opacity(0.25))
            }
        } header: {
            ProfileSectionHeader(equipmentType: type)
        }
    }

    @ViewBuilder
    func listSection(type: Equipment.EquipmentType) -> some View {
        let filteredEquipment = equipment.filter { $0.equipmentType == type }
        if !filteredEquipment.isEmpty {
            Section {
                ForEach(filteredEquipment) { equipment in
                    EquipmentRow(equipment: equipment) {
                        editEquipmentOperation = .init(editing: equipment,
                                                       withParentContext: managedObjectContext)
                    } onDelete: {
                        deleteEquipment = equipment
                        isDeletingEquipment = true
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
                singleSection(type: .paraglider)
                singleSection(type: .harness)
            } else {
                listSection(type: .paraglider)
                listSection(type: .harness)
            }
            listSection(type: .reserve)
            listSection(type: .gear)
        }
        .defaultBackground()
        .listStyle(.insetGrouped)
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                if profile != nil {
                    Button {
                        showWeightView = true
                    } label: {
                        Image(systemName: "scalemass.fill")
                    }
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    ForEach([Equipment.EquipmentType.reserve, Equipment.EquipmentType.gear]) { type in
                        Button(action: {
                            addEquipment(type: type)
                        }) {
                            Label {
                                Text(type.localizedName)
                            } icon: {
                                type.iconImage
                            }
                        }
                    }
                    if profile != nil {
                        Divider()
                        Button(action: editProfile) {
                            Label("Edit", systemImage: "slider.vertical.3")
                        }
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(item: $editEquipmentOperation) { operation in
            NavigationView {
                EditEquipmentView(equipment: operation.object, locale: locale)
                    .environment(\.managedObjectContext, operation.childContext)
            }
        }
        .sheet(item: $editProfileOperation) { operation in
            NavigationView {
                EditProfileView(profile: operation.object)
                    .environment(\.managedObjectContext, operation.childContext)
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
        .interactiveDismissDisabled(true)
        .sheet(isPresented: $showWeightView) {
            NavigationView {
                if let profile {
                    ProfileWeightView(profile: profile)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Close") {
                                    showWeightView = false
                                }
                            }
                        }
                }
            }
        }
        .confirmationDialog("Add equipment", isPresented: $showAddEquipmentSheet, presenting: $addEquipmentType) { equipmentType in
            let type = equipmentType.wrappedValue!
            let typeName = LocalizedString(type.localizedNameString)
            Button("Add existing \(typeName)") {
                editProfile()
            }
            Button("Create new \(typeName)") {
                createEquipment(type: type)
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
        showAddEquipmentSheet = true
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

    func editProfile() {
        guard let profile else { return }
        editProfileOperation = Operation(editing: profile,
                                         withParentContext: managedObjectContext)
    }
}

struct ProfileView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            NavigationView {
                ProfileView(profile: CoreData.fakeProfile)
            }

            NavigationView {
                ProfileView(profile: Profile.create(context: CoreData.previewContext, name: "Empty"))
            }
            .previewDisplayName("Empty Profile")
            
            NavigationView {
                ProfileView(profile: nil)
            }
            .previewDisplayName("All Equipment")
        }
        .environment(\.locale, .init(identifier: "de"))
        .environment(\.managedObjectContext, CoreData.previewContext)
    }
}
