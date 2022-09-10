//
//  ProfileListView.swift
//  ProfileListView
//
//  Created by Simon Seyer on 26.08.21.
//

import SwiftUI
import CoreData

struct ProfileListView: View {

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)])
    private var profiles: FetchedResults<Profile>

    @State private var editProfileOperation: Operation<Profile>?
    @State private var isDeletingProfile = false
    @State private var deleteProfile: Profile?

    @Environment(\.managedObjectContext) var managedObjectContext

    var body: some View {
        List {
            Section {
                ForEach(profiles) { profile in
                    NavigationLink {
                        ProfileView(profile: profile)
                    } label: {
                        HStack {
                            Image(systemName: profile.profileIcon.systemName)
                                .resizable()
                                .fontWeight(.medium)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 26, height: 26)
                                .padding(.trailing, 8)
                            Text(profile.profileName)
                        }
                    }
                    .padding([.top, .bottom], 6)
                    .swipeActions {
                        Button {
                            editProfileOperation = Operation(editing: profile,
                                                             withParentContext: managedObjectContext)
                        } label: {
                            Label("Edit", systemImage: "pencil")
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
                NavigationLink {
                    ProfileView(profile: nil)
                } label: {
                    HStack {
                        Image(systemName: "tray.full.fill")
                            .resizable()
                            .fontWeight(.medium)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .padding(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 11))
                        Text("All Equipment")
                    }
                }
            } footer: {
                Text("set_footer")
            }
        }
        .navigationTitle("All Sets")
        .sheet(item: $editProfileOperation) { operation in
            NavigationView {
                EditProfileView(profile: operation.object)
                    .environment(\.managedObjectContext, operation.childContext)
                    .onDisappear {
                        try? managedObjectContext.save()
                    }
            }
        }
        .confirmationDialog(Text("Delete set"), isPresented: $isDeletingProfile, presenting: deleteProfile) { profile in
            Button("Delete", role: .destructive) {
                withAnimation {
                    managedObjectContext.delete(profile)
                    try! managedObjectContext.save()
                }
            }
            Button("Delete with equipment", role: .destructive) {
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
        NavigationView {
            ProfileListView()
                .environment(\.managedObjectContext, CoreData.previewContext)
        }
    }
}
