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
}

struct ProfileListView: View {

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)])
    private var profiles: FetchedResults<Profile>

    @AppStorage("lastSelectedProfileId") private var lastSelectedProfileId: String?

    @State private var editProfileOperation: Operation<Profile>?

    @Binding var selectedProfile: ProfileSelection?
    @Binding var showNotificationSettings: Bool

    @Environment(\.managedObjectContext) var managedObjectContext

    var body: some View {
        List(selection: $selectedProfile) {
            ForEach(profiles) { profile in
                NavigationLink(value: ProfileSelection.profile(profile)) {
                    Label(profile.profileName,
                          systemImage: profile.profileIcon.systemName.removingFill)
                }
            }
            NavigationLink(value: ProfileSelection.allEquipment)  {
                Label("All Equipment",
                      systemImage: "tray.full")
            }
            Button {
                editProfileOperation = Operation(withParentContext: managedObjectContext)
            } label: {
                Label("Create new set", systemImage: "plus.circle")
            }
            if case .profile(let profile) = selectedProfile {
                DeletionObserverView(object: profile) {
                    self.selectedProfile = nil
                }
            }
        }
        .foregroundStyle(.primary)
        .navigationTitle("Sets")
        .onAppear {
            if selectedProfile == nil {
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
        .onChange(of: selectedProfile) { _, selection in
            if case let .profile(profile) = selection {
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
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        editProfileOperation = Operation(withParentContext: managedObjectContext)
                    } label: {
                        Label("Create new set", systemImage: "plus")
                    }
                    Button {
                        showNotificationSettings = true
                    } label: {
                        Label("Set up notifications", systemImage: "bell.fill".deviceSpecificIcon)
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {

    static var previews: some View {
        NavigationStack {
            ProfileListView(selectedProfile: .constant(.none),
                            showNotificationSettings: .constant(false))
                .environment(\.managedObjectContext, .preview)
        }
    }
}
