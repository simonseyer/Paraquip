//
//  SetView.swift
//  SetView
//
//  Created by Simon Seyer on 26.08.21.
//

import SwiftUI
import CoreData

struct SetView: View {

    @Binding var presentedEquipment: EquipmentModel?

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)])
    private var profiles: FetchedResults<ProfileModel>

    @State private var editSet: ProfileModel?
    @State private var deleteSet: ProfileModel?
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
                        editSet = profile
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.blue)

                    Button {
                        deleteSet = profile
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
        .sheet(item: $editSet) { profile in
            NavigationView {
                EditSetView(set: profile)
            }
        }
        .sheet(item: $presentedEquipment) { equipment in
            NavigationView {
                EquipmentView(equipment: equipment)
            }
        }
        .alert("Delete set", isPresented: $showingDeleteAlert, presenting: deleteSet) { selectedSet in
            Button(role: .destructive) {
                withAnimation {
                    managedObjectContext.delete(selectedSet)
                    try? managedObjectContext.save()
                }
            } label: {
                Text("Delete \(selectedSet.name ?? "")")
            }
            Button("Cancel", role: .cancel) { }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    editSet = ProfileModel.create(context: managedObjectContext)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}


struct MainView_Previews: PreviewProvider {

    static let persistentContainer = NSPersistentContainer.fake(name: "Model")

    static var previews: some View {
        NavigationView {
            SetView(presentedEquipment: .constant(nil))
                .environment(\.managedObjectContext, persistentContainer.viewContext)
        }
    }
}
