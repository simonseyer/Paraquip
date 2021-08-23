//
//  ProfileView.swift
//  Paraquip
//
//  Created by Simon Seyer on 09.04.21.
//

import SwiftUI

struct ProfileView: View {

    @ObservedObject var viewModel: ProfileViewModel
    @State private var newEquipment: AnyEquipment?
    @State private var editMode: EditMode = .inactive

    @Binding var selectedEquipment: UUID?

    var body: some View {
        Group {
            if viewModel.profile.equipment.isEmpty {
                VStack {
                    Image("icon")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 120)

                    Text("profile_empty_text")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 250)
                        .padding()
                }
            } else {
                List {
                    ForEach(viewModel.profile.equipment, id: \.id) { equipment in
                        NavigationLink(destination: EquipmentView(viewModel: viewModel.viewModel(for: equipment)),
                                       tag: equipment.id,
                                       selection: $selectedEquipment) {
                            EquipmentRow(equipment: equipment)
                        }
                    }
                    .onDelete(perform: { indexSet in
                        viewModel.removeEquipment(atOffsets: indexSet)
                        if viewModel.profile.equipment.isEmpty {
                            withAnimation {
                                editMode = .inactive
                            }
                        }
                    })
                }
                .listStyle(InsetGroupedListStyle())
                .environment(\.editMode, $editMode)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(editMode == .inactive ? "Edit" : "Done") {
                            withAnimation {
                                editMode.toggle()
                            }
                        }
                        .animation(.none)
                    }
                }
            }
        }
        .navigationTitle(viewModel.profile.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu(content: {
                    Button(action: {
                        newEquipment = AnyEquipment(Paraglider())
                    }) {
                        Text("Paraglider")
                    }
                    Button(action: {
                        newEquipment = AnyEquipment(Harness())
                    }) {
                        Text("Harness")
                    }
                    Button(action: {
                        newEquipment = AnyEquipment(Reserve())
                    }) {
                        Text("Reserve")
                    }
                },
                label: {
                    Image(systemName: "plus")

                })
            }
        }
        .sheet(item: $newEquipment) { equipment in
            NavigationView {
                EditEquipmentView(viewModel: viewModel.editViewModel(for: equipment.wrappedValue)) {
                    newEquipment = nil
                }
            }
        }
    }
}

struct AnyEquipment: Identifiable {
    
    let wrappedValue: Equipment

    var id: UUID { wrappedValue.id }

    init(_ equipment: Equipment) {
        self.wrappedValue = equipment
    }
}

struct ProfileView_Previews: PreviewProvider {

    private static let viewModel = ProfileViewModel.fake()

    static var previews: some View {
        Group {
            NavigationView {
                ProfileView(viewModel: viewModel, selectedEquipment: .constant(nil))
            }

            NavigationView {
                ProfileView(viewModel: ProfileViewModel.fake(profile: Profile(name: "Empty")), selectedEquipment: .constant(nil))
            }
        }
        .environment(\.locale, .init(identifier: "de"))
    }
}
