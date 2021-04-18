//
//  ProfileView.swift
//  Paraquip
//
//  Created by Simon Seyer on 09.04.21.
//

import SwiftUI

struct ProfileView: View {

    @EnvironmentObject var store: ProfileStore
    @State private var showingAddEquipment = false

    var body: some View {
        List {
            ForEach(store.profile.paragliders) { paraglider in
                HStack {
                    NavigationLink(destination: EquipmentView(equipmentId: paraglider.id)) {
                        paraglider.icon
                            .resizable()
                            .scaledToFit()

                            .frame(width: 60, height: 80, alignment: .center)
                            .padding([.trailing])

                        VStack(alignment: .leading) {
                            Text(paraglider.name)
                                .font(.headline)
                            Spacer()
                            HStack {
                                Image(systemName: "arrow.up.left.and.arrow.down.right")
                                    .foregroundColor(.gray)
                                Text(paraglider.size)
                            }

                            HStack {
                                Image(systemName: "text.badge.checkmark")
                                    .foregroundColor(Color(UIColor.systemGray))
                                Text(paraglider.formattedCheckInterval)
                            }
                        }.padding([.top, .bottom])
                    }
                }
            }
            .onDelete(perform: { indexSet in
                store.removeParaglider(atOffsets: indexSet)
            })
        }
        .listStyle(PlainListStyle())
        .navigationTitle(store.profile.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddEquipment = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddEquipment) {
            NavigationView {
                AddEquipmentView(isPresented: $showingAddEquipment)
            }
        }
    }
}

extension Equipment {
    var icon: Image {
        switch brand {
        case "Gin":
            return Image("gin-gliders")
        case "U-Turn":
            return Image("u-turn")
        default:
            return Image("gin-gliders")
        }
    }

    var formattedCheckInterval: String {
        if Calendar.current.isDate(Date(), inSameDayAs: nextCheck) ||
            nextCheck < Date() {
            return "Now"
        }

        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        formatter.allowedUnits = [.month, .day]
        formatter.includesTimeRemainingPhrase = true

        return formatter.string(from: Date(), to: nextCheck) ?? "???"
    }
}

struct ProfileView_Previews: PreviewProvider {

    private static let profileStore = ProfileStore(profile: Profile.fake())

    static var previews: some View {
        NavigationView {
            ProfileView()
                .environmentObject(profileStore)
        }
    }
}
