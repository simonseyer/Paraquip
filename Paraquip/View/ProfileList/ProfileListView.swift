//
//  ProfileListView.swift
//  ProfileListView
//
//  Created by Simon Seyer on 26.08.21.
//

import SwiftUI
import CoreData

struct ProfileListView: View {

    // TODO: filter temporary objects to avoid flicker or wrap in super entity and add delayed
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)])
    private var profiles: FetchedResults<Profile>

    @State private var editProfile: Profile?
    @State private var isFirstAppearance = true

    @Environment(\.managedObjectContext) var managedObjectContext

    var body: some View {
        List {
            Section {
                ForEach(profiles) { profile in
                    NavigationLink {
                        ProfileView(profile: profile)
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
                            withAnimation {
                                managedObjectContext.delete(profile)
                                try! managedObjectContext.save()
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                    }
                    .labelStyle(.titleOnly)
                }
            } footer: {
                Text("set_footer")
            }
        }
        .navigationTitle("All Sets")
        .sheet(item: $editProfile) { profile in
            NavigationView {
                EditProfileView(profile: profile)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                managedObjectContext.rollback()
                                editProfile = nil
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                try! managedObjectContext.save()
                                editProfile = nil
                            }
                            .disabled(profile.profileName.isEmpty)
                        }
                    }
            }
        }
        .interactiveDismissDisabled(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    editProfile = Profile.create(context: managedObjectContext, name: "")
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
