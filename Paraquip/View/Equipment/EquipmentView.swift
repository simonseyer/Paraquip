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
    @Environment(\.locale) var locale: Locale

    @State private var showingEditEquipment = false
    @State private var logCheck: Check?
    @State private var showingManual = false

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()

    @FetchRequest
    private var checkLog: FetchedResults<Check>

    init(equipment: Equipment) {
        self.equipment = equipment
        _checkLog = FetchRequest<Check>(sortDescriptors: [SortDescriptor(\.date, order: .reverse)],
                                        predicate: NSPredicate(format: "%K == %@", #keyPath(Check.equipment), equipment))
    }

    var body: some View {
        VStack(alignment: .leading) {
            EquipmentHeaderView(brandName: equipment.brandName,
                            icon: equipment.icon,
                            showManualAction: { showingManual.toggle() }) {
                HStack {
                    PillLabel(LocalizedStringKey(equipment.localizedType))
                    if let size = equipment.size {
                        PillLabel("Size \(size)")
                    }
                }
            }

            List {
                NextCheckCell(urgency: equipment.checkUrgency) {
                    logCheck = Check.create(context: managedObjectContext)
                }
                ForEach(checkLog) { log in
                    TimelineViewCell(logEntry: log) {
                        logCheck = log
                    }
                }
                if let purchaseLog = equipment.purchaseLog {
                    TimelineViewCell(logEntry: purchaseLog) {
                        logCheck = purchaseLog
                    }
                }
            }
            .listStyle(.insetGrouped)
            .toolbar {
                Button("Edit") {
                    showingEditEquipment = true
                }
            }
            .navigationTitle(equipment.equipmentName)
            .sheet(isPresented: $showingEditEquipment) {
                NavigationView {
                    EditEquipmentView(equipment: equipment, locale: locale)
                }
            }
            .sheet(item: $logCheck, onDismiss: {
                managedObjectContext.rollback()
            }) { check in
                NavigationView {
                    if check.isTemporary {
                        LogCheckView(check: check)
                            .navigationTitle(check.isPurchase ? "Purchase" : "Check")
                            .toolbar {
                                ToolbarItem(placement: .cancellationAction) {
                                    Button("Cancel") {
                                        managedObjectContext.delete(check)
                                        try! managedObjectContext.save()
                                        logCheck = nil
                                    }
                                }
                                ToolbarItem(placement: .confirmationAction) {
                                    Button("Log") {
                                        equipment.addToCheckLog(check)
                                        try! managedObjectContext.save()
                                        logCheck = nil
                                    }
                                }
                            }
                    } else {
                        LogCheckView(check: check)
                            .navigationTitle(check.isPurchase ? "Purchase" : "Check")
                            .toolbar {
                                ToolbarItem(placement: .cancellationAction) {
                                    Button("Delete") {
                                        managedObjectContext.delete(check)
                                        try! managedObjectContext.save()
                                        logCheck = nil
                                    }
                                }
                                ToolbarItem(placement: .confirmationAction) {
                                    Button("Save") {
                                        try! managedObjectContext.save()
                                        logCheck = nil
                                    }
                                }
                            }
                    }
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

    static var previews: some View {
        ForEach(CoreData.fakeProfile.allEquipment) { equipment in
            NavigationView {
                EquipmentView(equipment: equipment)
            }
        }
        .environment(\.locale, .init(identifier: "de"))
        .environment(\.managedObjectContext, CoreData.previewContext)
    }
}
