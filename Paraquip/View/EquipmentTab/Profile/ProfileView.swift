//
//  ProfileView.swift
//  Paraquip
//
//  Created by Simon Seyer on 09.04.21.
//

import SwiftUI
import CoreData

struct ProfileView: View {

    let selectedProfile: ProfileSelection?
    @Binding var selectedEquipment: Equipment?

    var body: some View {
        if let selectedProfile {
            ProfileContentView(profile: selectedProfile.profile,
                               selectedEquipment: $selectedEquipment.animation())
        } else {
            ContentUnavailableView("Select an equipment set",
                                   systemImage: "tray.full.fill")
        }
    }
}

private struct ProfileContentView: View {
    let profile: Profile?
    @Binding var selectedEquipment: Equipment?

    @Environment(\.managedObjectContext) private var managedObjectContext
    @State private var editProfileOperation: Operation<Profile>?
    @State private var navigationTitle: String = "fu"

    @FetchRequest
    private var equipment: FetchedResults<Equipment>

    private var isSpecificProfile: Bool {
        equipment.nsPredicate != nil
    }

    init(profile: Profile?, selectedEquipment: Binding<Equipment?>) {
        self.profile = profile
        self._selectedEquipment = selectedEquipment
        _equipment = FetchRequest(
            previewEntity: Equipment.previewEntity,
            sortDescriptors: Equipment.defaultSortDescriptors(),
            predicate: profile?.equipmentPredicate
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
            section(.paraglider, single: isSpecificProfile)
            section(.harness, single: isSpecificProfile)
            section(.reserve, single: false)
            section(.gear, single: false)
            if let selectedEquipment {
                DeletionObserverView(object: selectedEquipment) {
                    self.selectedEquipment = nil
                }
            }
            if let profile {
                ProfileTitleView(profile: profile,
                                 navigationTitle: $navigationTitle)
            }
        }
        .navigationTitle(navigationTitle)
        .listStyle(.insetGrouped)
        .onChange(of: profile, initial: true) {
            navigationTitle = profile?.profileName ?? String(localized: "All Equipment")
            if let profile, let selectedEquipment, !profile.contains(selectedEquipment) {
                self.selectedEquipment = nil
            }
        }
        .toolbar {
            ToolbarItem {
                if isSpecificProfile {
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
            let equipment = Equipment.create(type: type, context: managedObjectContext)
            if let profile {
                profile.addToEquipment(equipment)
            }
            selectedEquipment = equipment
        }
    }

    private func editProfile() {
        guard let profile else { return }
        editProfileOperation = Operation(editing: profile,
                                         withParentContext: managedObjectContext)
    }
}

/// Observes the Profile to update the navigationTitle when the name changes
private struct ProfileTitleView: View {
    @ObservedObject var profile: Profile
    @Binding var navigationTitle: String

    var body: some View {
        EmptyView()
            .onChange(of: profile.profileName, initial: true) {
                navigationTitle = profile.profileName
            }
    }
}

#Preview {
    NavigationStack {
        ProfileContentView(profile: CoreData.fakeProfile, selectedEquipment: .constant(nil))
    }
    .environment(\.managedObjectContext, .preview)
}

#Preview("Empty Profile") {
    NavigationStack {
        ProfileContentView(profile: Profile.create(context: .preview, name: "Empty"), selectedEquipment: .constant(nil))
    }
    .environment(\.managedObjectContext, .preview)
}

#Preview("All Equipment") {
    NavigationStack {
        ProfileContentView(profile: nil, selectedEquipment: .constant(nil))
    }
    .environment(\.managedObjectContext, .preview)
}
