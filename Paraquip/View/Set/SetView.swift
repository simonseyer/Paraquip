//
//  SetView.swift
//  SetView
//
//  Created by Simon Seyer on 26.08.21.
//

import SwiftUI

struct SetView: View {

    @ObservedObject var viewModel: SetViewModel

    @State private var editSet: Profile.Description?
    @State private var deleteSet: Profile.Description?
    @State private var presentedEquipment: Equipment?
    @State private var showingDeleteAlert = false
    @State private var selectedProfile: UUID?

    init(viewModel: SetViewModel) {
        self.viewModel = viewModel
        _selectedProfile = State(initialValue: viewModel.primaryProfile.id)
    }

    var body: some View {
        List {
            ForEach(viewModel.profiles) { profile in
                // TODO: implement selectedEquipment

                NavigationLink(tag: profile.id, selection: $selectedProfile) {
                    ProfileView(viewModel: viewModel.viewModel(for: profile))
                } label: {
                    HStack {
                        Image(profile.icon.rawValue)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.accentColor)
                            .frame(width: 35, height: 35)
                            .padding(.trailing, 8)

                        Text(profile.name)
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

        .navigationTitle("All Sets")
        .sheet(item: $editSet) { profile in
            NavigationView {
                EditSetView(viewModel: viewModel.editSetViewModel(for: profile))
            }
        }
//        .sheet(item: $presentedEquipment) { equipment in
//            NavigationView {
//                EditSetView(viewModel: viewModel.editSetViewModel(for: profile))
//            }
//        }
        .alert("Delete set", isPresented: $showingDeleteAlert, presenting: deleteSet) { selectedSet in
            Button(role: .destructive) {
                withAnimation {
                    viewModel.delete(profile: selectedSet)
                }
            } label: {
                Text("Delete \(selectedSet.name)")
            }
            Button("Cancel", role: .cancel) { }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    editSet = .init()
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
            SetView(viewModel: SetViewModel(store: FakeAppStore()))
        }
    }
}
