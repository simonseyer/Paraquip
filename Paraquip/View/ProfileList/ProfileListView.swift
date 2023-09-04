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

@MainActor
extension String {
    fileprivate var deviceSpecificIcon: String {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return self.replacingOccurrences(of: ".fill", with: "")
        } else {
            return self
        }
    }
}

struct ProfileListView: View {

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)])
    private var profiles: FetchedResults<Profile>

    @AppStorage("lastSelectedProfileId") private var lastSelectedProfileId: String?

    @State private var editProfileOperation: Operation<Profile>?
    @State private var isDeletingProfile = false
    @State private var deleteProfile: Profile?

    @Binding var selectedProfile: ProfileSelection?

    @Environment(\.managedObjectContext) var managedObjectContext

    var body: some View {
        List(selection: $selectedProfile) {
            Section {
                ForEach(profiles) { profile in
                    NavigationLink(value: ProfileSelection.profile(profile)) {
                        HStack {
                            Image(systemName: profile.profileIcon.systemName.deviceSpecificIcon)
                                .font(.title3)
                            Text(profile.profileName)
                        }
                    }
                    .swipeActions {
                        Button {
                            editProfileOperation = Operation(editing: profile,
                                                             withParentContext: managedObjectContext)
                        } label: {
                            Label("Edit", systemImage: "slider.vertical.3")
                        }
                        .tint(.blue)

                        Button {
                            deleteProfile = profile
                            isDeletingProfile = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                    }
                    .labelStyle(.titleOnly)
                }
                NavigationLink(value: ProfileSelection.allEquipment)  {
                    HStack {
                        Image(systemName: "tray.full.fill".deviceSpecificIcon)
                            .font(.title3)
                        Text("All Equipment")
                    }
                }
            } footer: {
                Text("set_footer")
            }
        }
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
        .onChange(of: selectedProfile) { selection in
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
        .confirmationDialog(Text("Delete set"), isPresented: $isDeletingProfile, presenting: deleteProfile) { profile in
            Button("Delete set", role: .destructive) {
                withAnimation {
                    managedObjectContext.delete(profile)
                    try! managedObjectContext.save()
                }
            }
            Button("Delete set & equipment", role: .destructive) {
                withAnimation {
                    profile.allEquipment.forEach {
                        managedObjectContext.delete($0)
                    }
                    managedObjectContext.delete(profile)
                    try! managedObjectContext.save()
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .interactiveDismissDisabled(true)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    editProfileOperation = Operation(withParentContext: managedObjectContext)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {

    static var previews: some View {
        NavigationStack {
            ProfileListView(selectedProfile: .constant(.none))
                .environment(\.managedObjectContext, .preview)
        }
    }
}
