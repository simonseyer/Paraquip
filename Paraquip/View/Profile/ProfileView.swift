//
//  ProfileView.swift
//  Paraquip
//
//  Created by Simon Seyer on 09.04.21.
//

import SwiftUI
import CoreData

struct ProfileView: View {

    @ObservedObject var profileModel: Profile
    @State private var newEquipment: Equipment?
    @Environment(\.managedObjectContext) var managedObjectContext

    private let equipmentFetchRequest: FetchRequest<Equipment>
    private var equipments: FetchedResults<Equipment> {
        equipmentFetchRequest.wrappedValue
    }

    init(profileModel: Profile) {
        self.profileModel = profileModel
        self.equipmentFetchRequest = FetchRequest(
            sortDescriptors: [
                SortDescriptor(\.name)
            ],
            predicate: .init(format: "ANY profiles.id == %@", profileModel.uuid)
        )
    }

    var body: some View {
        Group {
            if equipments.isEmpty {
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
                List{
                    ForEach(equipments) { equipment in
                        NavigationLink(destination: EquipmentView(equipment: equipment)) {
                            EquipmentRow(equipment: equipment)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            managedObjectContext.delete(equipments[index])
                        }
                        try! managedObjectContext.save()
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(profileModel.name ?? "")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu(content: {
                    Button(action: {
                        newEquipment = Paraglider.create(context: managedObjectContext)
                        profileModel.addToEquipment(newEquipment!)
                    }) {
                        Text("Paraglider")
                    }
                    Button(action: {
                        newEquipment = Harness.create(context: managedObjectContext)
                        profileModel.addToEquipment(newEquipment!)
                    }) {
                        Text("Harness")
                    }
                    Button(action: {
                        newEquipment = Reserve.create(context: managedObjectContext)
                        profileModel.addToEquipment(newEquipment!)
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
                EditEquipmentView(equipment: equipment)
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {

    static let persistentContainer = NSPersistentContainer.fake(name: "Model")

    static var previews: some View {
        Group {
            NavigationView {
                ProfileView(profileModel: persistentContainer.fakeProfile())
            }

            NavigationView {
                ProfileView(profileModel: Profile.create(context: persistentContainer.viewContext))
            }
        }
        .environment(\.locale, .init(identifier: "de"))
        .environment(\.managedObjectContext, persistentContainer.viewContext)
    }
}
