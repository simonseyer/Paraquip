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

    @State private var editProfile: Profile?
    @State private var deleteProfile: Profile?
    @State private var showingDeleteAlert = false
    @State private var selectedProfile: UUID?

    @Environment(\.managedObjectContext) var managedObjectContext

    var body: some View {
        List {
            ForEach(profiles) { profile in
                NavigationLink(tag: profile.id!, selection: $selectedProfile) {
                    ProfileView(profileModel: profile)
                } label: {
                    HStack {
                        Image(profile.profileIcon.rawValue)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.accentColor)
                            .frame(width: 35, height: 35)
                            .padding(.trailing, 8)

                        Text(profile.profileName)
                    }
                }
                .padding([.top, .bottom])
                .swipeActions {
                    Button {
                        editProfile = profile
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.blue)

                    Button {
                        deleteProfile = profile
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .tint(.red)
                }
            }
        }
        .onAppear {
            if profiles.count == 1, let profile = profiles.first {
                selectedProfile = profile.id!
            }
        }
        .navigationTitle("All Sets")
        .sheet(item: $editProfile) { profile in
            NavigationView {
                EditProfileView(profile: profile)
            }
        }
        .alert("Delete set", isPresented: $showingDeleteAlert, presenting: deleteProfile) { selectedProfile in
            Button(role: .destructive) {
                // TODO: fix deletion animation
                managedObjectContext.delete(selectedProfile)
                try! managedObjectContext.save()
            } label: {
                Text("Delete \(selectedProfile.name ?? "")")
            }
            Button("Cancel", role: .cancel) { }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    editProfile = Profile.create(context: managedObjectContext)
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
