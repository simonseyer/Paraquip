//
//  ProfileView.swift
//  Paraquip
//
//  Created by Simon Seyer on 09.04.21.
//

import SwiftUI
import CoreData

extension Optional<ProfileSelection> {
    var equipmentPredicate: NSPredicate {
        switch self {
        case .none:
            NSPredicate(value: false)
        case .profile(let profile):
            profile.equipmentPredicate
        case .allEquipment:
            NSPredicate(value: true)
        }
    }
}

struct ProfileView: View {
    let selectedProfile: ProfileSelection?
    @Binding var selectedEquipment: Equipment?

    @Environment(\.managedObjectContext) private var managedObjectContext
    @State private var editProfileOperation: Operation<Profile>?
    // Double empty space important to avoid glitchy animation
    @State private var navigationTitle: String = " "

    @FetchRequest
    private var equipment: FetchedResults<Equipment>

    private var profile: Profile? {
        selectedProfile?.profile
    }

    private var isSpecificProfile: Bool {
        if case .profile(_) = selectedProfile { true } else { false }
    }

    init(selectedProfile: ProfileSelection?, selectedEquipment: Binding<Equipment?>) {
        self.selectedProfile = selectedProfile
        self._selectedEquipment = selectedEquipment
        _equipment = FetchRequest(
            previewEntity: Equipment.previewEntity,
            sortDescriptors: Equipment.defaultSortDescriptors(),
            predicate: selectedProfile.equipmentPredicate
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
            if selectedProfile != nil {
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
        }
        .navigationTitle(navigationTitle)
        .listStyle(.insetGrouped)
        .onChange(of: selectedProfile, initial: true) {
            if selectedProfile == nil {
                // Double empty space important to avoid glitchy animation
                navigationTitle = " "
            } else {
                navigationTitle = profile?.profileName ?? String(localized: "All Equipment")
            }
            if let profile, let selectedEquipment, !profile.contains(selectedEquipment) {
                self.selectedEquipment = nil
            }
        }
        .toolbar {
            ToolbarItem {
                #if os(iOS)
                Button("Edit") {
                    editProfile()
                }
                // Hiding instead of removing button to avoid glitchy animation on iOS
                .opacity(isSpecificProfile ? 1 : 0)
                .animation(.none, value: isSpecificProfile)
                #else
                if isSpecificProfile {
                    Button {
                        editProfile()
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                }
                #endif
            }
        }
        .sheet(item: $editProfileOperation) { operation in
            NavigationStack {
                EditProfileView(profile: operation.object)
                    .environment(\.managedObjectContext, operation.childContext)
            }
        }
        .overlay {
            if selectedProfile == nil {
                ContentUnavailableView("Select an equipment set",
                                       systemImage: "tray.full.fill")
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
        ProfileView(selectedProfile: .profile(CoreData.fakeProfile), 
                    selectedEquipment: .constant(nil))
    }
    .environment(\.managedObjectContext, .preview)
}

#Preview("Empty Profile") {
    NavigationStack {
        ProfileView(selectedProfile: .profile(.create(context: .preview, name: "Empty")), 
                    selectedEquipment: .constant(nil))
    }
    .environment(\.managedObjectContext, .preview)
}

#Preview("All Equipment") {
    NavigationStack {
        ProfileView(selectedProfile: .allEquipment, 
                    selectedEquipment: .constant(nil))
    }
    .environment(\.managedObjectContext, .preview)
}

#Preview("No selection") {
    NavigationStack {
        ProfileView(selectedProfile: nil,
                    selectedEquipment: .constant(nil))
    }
    .environment(\.managedObjectContext, .preview)
}
