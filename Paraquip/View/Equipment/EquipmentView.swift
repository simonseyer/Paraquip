//
//  EquipmentView.swift
//  Paraquip
//
//  Created by Simon Seyer on 18.04.21.
//

import SwiftUI
import CoreData

struct EquipmentView: View {

    @ObservedObject var equipment: Equipment
    @Environment(\.managedObjectContext) var managedObjectContext

    @State private var showingEditEquipment = false
    @State private var showingLogCheck = false
    @State private var showingManual = false

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("by \(equipment.brandName)")
                            .font(.headline)
                        Button(action: {
                            showingManual.toggle()
                        }) {
                            Image(systemName: "book.fill")
                        }
                    }
                    HStack {
                        PillLabel(LocalizedStringKey(equipment.localizedType))
                        if let size = equipment.size {
                            PillLabel("Size \(size)")
                        }
                    }
                    .padding([.top, .bottom], 10)
                }
                Spacer()
                if let icon = equipment.icon {
                    icon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                }
            }
            .padding([.leading, .trailing])

            List {
                if equipment.timeline.isEmpty {
                    Text("No check logged")
                        .foregroundColor(Color(UIColor.systemGray))
                } else {
                    ForEach(equipment.timeline) { entry in
                        TimelineViewCell(timelineEntry: entry) {
                            showingLogCheck = true
                        }
                        .deleteDisabled(!entry.isCheck)
                    }
                    .onDelete(perform: { indexSet in
                        for index in indexSet {
                            if case .check(let check) = equipment.timeline[index] {
                                managedObjectContext.delete(check)
                            }
                        }
                        try! managedObjectContext.save()
                    })
                }
            }
            .listStyle(InsetGroupedListStyle())
            .toolbar {
                Button("Edit") {
                    showingEditEquipment = true
                }
            }
            .navigationTitle(equipment.equipmentName)
            .sheet(isPresented: $showingEditEquipment) {
                NavigationView {
                    EditEquipmentView(equipment: equipment)
                }
            }
            .sheet(isPresented: $showingLogCheck) {
                LogCheckView() { date in
                    if let checkDate = date {
                        let check = Check.create(context: managedObjectContext, date: checkDate)
                        equipment.addToCheckLog(check)
                        try! managedObjectContext.save()
                    }
                    showingLogCheck = false
                }
            }
            .sheet(isPresented: $showingManual) {
                if let manual = equipment.manual {
                    NavigationView {
                        ManualView(manual: manual.data!, deleteManual: {
                            managedObjectContext.delete(manual)
                            try! managedObjectContext.save()
                        })
                    }
                } else {
                    DocumentPicker() { url in
                        do {
                            let data = try Data(contentsOf: url)
                            let manual = Manual(context: managedObjectContext)
                            manual.data = data
                            equipment.manual = manual
                            try managedObjectContext.save()
                        } catch {
                            // TODO: error handling
                            print(error)
                        }
                    }
                }
            }
        }
    }
}

struct EquipmentView_Previews: PreviewProvider {

    static let persistentContainer = NSPersistentContainer.fake(name: "Model")

    static var equipments: [Equipment] {
        persistentContainer.fakeProfile().equipment!.allObjects as! [Equipment]
    }

    static var previews: some View {
        Group {
            NavigationView {
                EquipmentView(equipment: equipments[0])
            }

            NavigationView {
                EquipmentView(equipment: equipments[1])
            }
        }
        .environment(\.locale, .init(identifier: "de"))
        .environment(\.managedObjectContext, persistentContainer.viewContext)
    }
}
