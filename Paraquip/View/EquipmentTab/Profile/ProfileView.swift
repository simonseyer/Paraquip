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

    @Environment(\.managedObjectContext) private var managedObjectContext
    @State private var editProfileOperation: Operation<Profile>?

    @FetchRequest
    private var equipment: FetchedResults<Equipment>

    init(profile: Profile, selectedEquipment: Binding<Equipment?>) {
        self.profile = profile
        self._selectedEquipment = selectedEquipment
        _equipment = FetchRequest(
            previewEntity: Equipment.previewEntity,
            sortDescriptors: Equipment.defaultSortDescriptors(),
            predicate: profile.equipmentPredicate
        )
    }

    @ViewBuilder
    func section(_ type: Equipment.EquipmentType, single: Bool) -> some View {
        let filteredEquipment = equipment.filter {
            $0.equipmentType == type
        }
        Section {
            ForEach(filteredEquipment) { equipment in
                NavigationLink(value: equipment) {
                    EquipmentRow(equipment: equipment)
                }
            }
            if !single || filteredEquipment.isEmpty {
                Button {
                    createEquipment(type: type)
                } label: {
                    Label(type.localizedName, 
                          systemImage: "plus.circle")
                }
            }
        }
    }

    var body: some View {
        List(selection: $selectedEquipment) {
            section(.paraglider, single: !profile.isAllEquipment)
            section(.harness, single: !profile.isAllEquipment)
            section(.reserve, single: false)
            section(.gear, single: false)
        }
        .navigationTitle(profile.profileName)
        .listStyle(.insetGrouped)
        .onReceive(equipment.publisher) { _ in
            if let selected = selectedEquipment {
                if !(selected.isInserted || equipment.contains(selected)) {
                    selectedEquipment = nil
                }
            }
        }
        .toolbar {
            ToolbarItem {
                ToolbarButton(isHidden: profile.isAllEquipment) {
                    editProfile()
                } simpleLabel: {
                    Text("Edit")
                } complexLabel: {
                    Label("Edit", systemImage: "pencil")
                }
            }
        }
        .sheet(item: $editProfileOperation) { operation in
            NavigationStack {
                EditProfileView(profile: operation.object)
                    .environment(\.managedObjectContext, operation.childContext)
            }
        }
    }

    private func createEquipment(type: Equipment.EquipmentType) {
        withAnimation {
            let equipment = Equipment.create(type, context: managedObjectContext)
            if !profile.isAllEquipment {
                profile.addToEquipment(equipment)
            }
            selectedEquipment = equipment
        }
    }

    private func editProfile() {
        guard !profile.isAllEquipment else { return }
        editProfileOperation = Operation(editing: profile,
                                         withParentContext: managedObjectContext)
    }
}


#Preview {
    NavigationStack {
        ProfileView(profile: CoreData.fakeProfile,
                    selectedEquipment: .constant(nil))
    }
    .environment(\.managedObjectContext, .preview)
}

#Preview("Empty Profile") {
    NavigationStack {
        ProfileView(profile: .create(context: .preview, name: "Empty"),
                    selectedEquipment: .constant(nil))
    }
    .environment(\.managedObjectContext, .preview)
}

#Preview("All Equipment") {
    NavigationStack {
        ProfileView(profile: AllEquipmentProfile.shared,
                    selectedEquipment: .constant(nil))
    }
    .environment(\.managedObjectContext, .preview)
}
