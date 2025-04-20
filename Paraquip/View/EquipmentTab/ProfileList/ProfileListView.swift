//
//  ProfileListView.swift
//  ProfileListView
//
//  Created by Simon Seyer on 26.08.21.
//

import SwiftUI
import CoreData

enum ProfileSelection: Hashable {
    case allEquipment
    case profile(Profile)

    var profile: Profile {
        return switch self {
        case .allEquipment:
            AllEquipmentProfile.shared
        case .profile(let profile):
            profile
        }
    }
}

struct ProfileListView: View {

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)])
    private var profiles: FetchedResults<Profile>

    @AppStorage("lastSelectedProfileId") private var lastSelectedProfileId: String?

    @State private var hasAppeared = false
    @State private var editProfileOperation: Operation<Profile>?

    @Binding var selectedProfile: ProfileSelection?

    @Environment(\.managedObjectContext) private var managedObjectContext

    var body: some View {
        List(selection: $selectedProfile) {
            ForEach(profiles) { profile in
                NavigationLink(value: ProfileSelection.profile(profile)) {
                    Label(profile.profileName,
                          systemImage: profile.profileIcon.systemName)
                }
            }
            NavigationLink(value: ProfileSelection.allEquipment)  {
                Label("All Equipment",
                      systemImage: "tray.full")
            }
            Button {
                editProfileOperation = Operation(withParentContext: managedObjectContext) {
                    Profile.create(context: $0)
                }
            } label: {
                Label("Create new set", systemImage: "plus.circle")
            }
        }
        .onReceive(profiles.publisher) { _ in
            if let selected = selectedProfile?.profile {
                if !selected.isAllEquipment && !profiles.contains(selected) {
                    selectedProfile = nil
                }
            }
        }
        .navigationTitle("Sets")
        .onAppear {
            if !hasAppeared {
                withAnimation(nil) {
                    // Prefer the last selected profile
                    if let profile = profiles.first(where: { $0.id?.uuidString == lastSelectedProfileId }) {
                        selectedProfile = .profile(profile)
                        // If there is none but only one profile, select it
                    } else if profiles.count == 1, let profile = profiles.first {
                        selectedProfile = .profile(profile)
                    }
                    // Else stay in the profile list
                }
            }
            hasAppeared = true
        }
        .onChange(of: selectedProfile) {  oldValue, newValue in
            if case let .profile(profile) = selectedProfile {
                lastSelectedProfileId = profile.id?.uuidString
            } else {
                lastSelectedProfileId = nil
            }
        }
        .sheet(item: $editProfileOperation) { operation in
            NavigationStack {
                EditProfileView(profile: operation.object)
                    .environment(\.managedObjectContext, operation.childContext)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileListView(selectedProfile: .constant(.none))
            .environment(\.managedObjectContext, .preview)
    }
}
