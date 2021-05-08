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
        List {
            ForEach(store.profile.equipment, id: \.id) { equipment in
                NavigationLink(destination: EquipmentView(equipmentId: equipment.id)) {
                    HStack {
                        equipment.icon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 80, alignment: .center)
                            .padding([.trailing])
                        
                        VStack(alignment: .leading) {
                            Text(equipment.name)
                                .font(.headline)
                            Spacer()
                            HStack {
                                Image(systemName: "text.badge.checkmark")
                                
                                Text(equipment.formattedCheckInterval)
                                
                            }.foregroundColor(equipment.checkIntervalColor)
                        }.padding([.top, .bottom])
                    }
                }
            }
            .onDelete(perform: { indexSet in
                store.removeEquipment(atOffsets: indexSet)
            })
        }
        .listStyle(PlainListStyle())
        .navigationTitle(store.profile.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
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
        if checkUrgency == .now {
            return "Now"
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
    }
}
