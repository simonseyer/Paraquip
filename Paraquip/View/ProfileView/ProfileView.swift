//
//  ProfileView.swift
//  Paraquip
//
//  Created by Simon Seyer on 09.04.21.
//

import SwiftUI

struct ProfileView: View {

    @EnvironmentObject var store: ProfileStore
    @State private var newEquipment: AnyEquipment?

    var body: some View {
        Group {
            if store.profile.equipment.isEmpty {
                VStack {
                    Image(systemName: "paperplane")
                        .font(.system(size: 80))

                    Text("Add your first equipment by tapping the + in the top right")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 250)
                        .padding()
                }
            } else {
                List {
                    ForEach(store.profile.equipment, id: \.id) { equipment in
                        NavigationLink(destination: EquipmentView(equipmentId: equipment.id)) {
                            EquipmentRow(equipment: equipment)
                        }
                    }
                    .onDelete(perform: { indexSet in
                        store.removeEquipment(atOffsets: indexSet)
                    })
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle(store.profile.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
                    .disabled(store.profile.equipment.isEmpty)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu(content: {
                    Button(action: {
                        newEquipment = AnyEquipment(Paraglider.new())
                    }) {
                        Text("Paraglider")
                    }
                    Button(action: {
                        newEquipment = AnyEquipment(Reserve.new())
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
                EditEquipmentView(equipment: equipment.wrappedValue) {
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

enum CheckUrgency {
    case now, soon, later
}

extension Equipment {

    var icon: Image? {
        guard let logo = brand.id else {
            return nil
        }
        return Image(logo)
    }

    var formattedCheckInterval: String {
        if checkUrgency == .now {
            return "Check now"
        }

        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        formatter.allowedUnits = [.month, .day]
        formatter.includesTimeRemainingPhrase = true

        return formatter.string(from: Date(), to: nextCheck) ?? "???"
    }

    var checkUrgency: CheckUrgency {
        let months = Calendar.current.dateComponents([.month], from: Date(), to: nextCheck).month ?? 0

        if Calendar.current.isDateInToday(nextCheck) ||
            nextCheck < Date() {
            return .now
        } else if months == 0 {
            return .soon
        } else {
            return .later
        }
    }

    var checkIntervalColor: Color {
        switch checkUrgency {
        case .now:
            return Color(UIColor.systemRed)
        case .soon:
            return Color(UIColor.systemOrange)
        case .later:
            return Color(UIColor.systemGray)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {

    private static let profileStore = ProfileStore(profile: Profile.fake())

    static var previews: some View {
        NavigationView {
            ProfileView()
                .environmentObject(profileStore)
        }

        NavigationView {
            ProfileView()
                .environmentObject(ProfileStore(profile: Profile(name: "Empty")))
        }
    }
}
