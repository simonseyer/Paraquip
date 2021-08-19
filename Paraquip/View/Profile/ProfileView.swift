//
//  ProfileView.swift
//  Paraquip
//
//  Created by Simon Seyer on 09.04.21.
//

import SwiftUI

struct ProfileView: View {

    @EnvironmentObject var store: ProfileViewModel
    @State private var newEquipment: AnyEquipment?
    @State private var editMode: EditMode = .inactive

    @Binding var selectedEquipment: UUID?

    var body: some View {
        Group {
            if store.profile.equipment.isEmpty {
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
                    ForEach(store.profile.equipment, id: \.id) { equipment in
                        NavigationLink(destination: EquipmentView(viewModel: store.viewModel(for: equipment)),
                                       tag: equipment.id,
                                       selection: $selectedEquipment) {
                            EquipmentRow(equipment: equipment)
                        }
                    }
                    .onDelete(perform: { indexSet in
                        store.removeEquipment(atOffsets: indexSet)
                        if store.profile.equipment.isEmpty {
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
        .navigationTitle(store.profile.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu(content: {
                    Button(action: {
                        newEquipment = AnyEquipment(Paraglider.new())
                    }) {
                        Text("Paraglider")
                    }
                    Button(action: {
                        newEquipment = AnyEquipment(Harness.new())
                    }) {
                        Text("Harness")
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

extension Equipment {

    var icon: Image? {
        guard let logo = brand.id else {
            return nil
        }
        return Image(logo)
    }

    func formattedCheckInterval(locale: Locale = Locale.current) -> LocalizedStringKey {
        return Paraquip.formattedCheckInterval(date: nextCheck, urgency: checkUrgency, locale: locale)
    }
}

func formattedCheckInterval(date: Date, urgency: CheckUrgency, locale: Locale = Locale.current) -> LocalizedStringKey {
    if urgency == .now {
        return "Check now"
    }

    var calendar = Calendar.current
    calendar.locale = locale

    let formatter = DateComponentsFormatter()
    formatter.calendar = calendar
    formatter.unitsStyle = .full
    formatter.maximumUnitCount = 1
    formatter.allowedUnits = [.month, .day]
    formatter.includesTimeRemainingPhrase = true

    return "\(formatter.string(from: Date.now, to: date) ?? "???")"
}

extension CheckUrgency {
    var color: Color {
        switch self {
        case .now:
            return Color(UIColor.systemRed)
        case .soon:
            return Color(UIColor.systemOrange)
        case .later:
            return Color(UIColor.systemGreen)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {

    private static let profileStore = ProfileViewModel.fake()

    static var previews: some View {
        Group {
            NavigationView {
                ProfileView(selectedEquipment: .constant(nil))
                    .environmentObject(profileStore)
            }

            NavigationView {
                ProfileView(selectedEquipment: .constant(nil))
                    .environmentObject(ProfileViewModel.fake(profile: Profile(name: "Empty")))
            }
        }
        .environment(\.locale, .init(identifier: "de"))
    }
}
