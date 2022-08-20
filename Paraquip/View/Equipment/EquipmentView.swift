//
//  EquipmentView.swift
//  Paraquip
//
//  Created by Simon Seyer on 18.04.21.
//

import SwiftUI
import CoreData
import QuickLook

struct EquipmentView: View {

    @ObservedObject var equipment: Equipment
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.locale) var locale: Locale

    @State private var editEquipmentOperation: Operation<Equipment>?
    @State private var editLogEntryOperation: Operation<LogEntry>?
    @State private var createLogEntryOperation: Operation<LogEntry>?
    @State private var previewedManual: URL? = nil
    @State private var showingManualPicker = false

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()

    @FetchRequest
    private var checkLog: FetchedResults<LogEntry>

    init(equipment: Equipment) {
        self.equipment = equipment
        _checkLog = FetchRequest<LogEntry>(sortDescriptors: [SortDescriptor(\.date, order: .reverse)],
                                           predicate: NSPredicate(format: "%K == %@", #keyPath(LogEntry.equipment), equipment))
    }

    var body: some View {
        VStack(alignment: .leading) {
            EquipmentHeaderView(brandName: equipment.brandName,
                                icon: equipment.icon) {
                HStack {
                    PillLabel(equipment.equipmentType.localizedName)
                    if let size = equipment.size {
                        PillLabel("Size \(size)")
                    }
                }
            }

            List {
                Section {
                    NextCheckCell(urgency: equipment.checkUrgency) {
                        let operation = Operation<LogEntry>(withParentContext: managedObjectContext)
                        operation.object(for: equipment).addToCheckLog(operation.object)
                        createLogEntryOperation = operation
                    }
                    ForEach(checkLog) { logEntry in
                        LogEntryCell(logEntry: logEntry)
                            .swipeActions {
                                swipeButton(for: logEntry)
                            }
                    }
                    if let purchaseLog = equipment.purchaseLog {
                        LogEntryCell(logEntry: purchaseLog)
                            .swipeActions {
                                swipeButton(for: purchaseLog)
                            }
                    }
                }
                Section {
                    HStack {
                        Text("Manual")
                        Spacer()
                        Button(action: {
                            if let manual = equipment.manualAttachment {
                                previewedManual = manual.fileURL
                            } else {
                                showingManualPicker = true
                            }
                        }) {
                            Image(systemName: equipment.manualAttachment != nil ? "book.fill" : "book")
                        }
                        .buttonStyle(.bordered)
                    }
                    .swipeActions {
                        if equipment.manualAttachment != nil {
                            Button(role: .destructive) {
                                equipment.manualAttachment = nil
                                try? managedObjectContext.save()
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .labelStyle(.titleOnly)
                }
            }
        }
        .listStyle(.insetGrouped)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button("Edit") {
                    editEquipmentOperation = Operation(editing: equipment,
                                                       withParentContext: managedObjectContext)
                }
            }
        }
        .navigationTitle(equipment.equipmentName)
        .sheet(item: $editEquipmentOperation) { operation in
            NavigationView {
                EditEquipmentView(equipment: operation.object, locale: locale)
                    .environment(\.managedObjectContext, operation.childContext)
                    .onDisappear {
                        try? managedObjectContext.save()
                    }
            }
        }
        .sheet(item: $editLogEntryOperation) { operation in
            NavigationView {
                LogEntryView(logEntry: operation.object, mode: .edit)
                    .environment(\.managedObjectContext, operation.childContext)
                    .onDisappear {
                        try? managedObjectContext.save()
                    }
            }
        }
        .sheet(item: $createLogEntryOperation) { operation in
            NavigationView {
                LogEntryView(logEntry: operation.object, mode: .create)
                    .environment(\.managedObjectContext, operation.childContext)
                    .onDisappear {
                        try? managedObjectContext.save()
                    }
            }
        }
        .quickLookPreview($previewedManual)
        .sheet(isPresented: $showingManualPicker) {
            DocumentPicker(contentTypes: [.pdf]) { url in
                let attachment = Attachment.create(fileURL: url,
                                                   context: managedObjectContext)
                equipment.manualAttachment = attachment
                try? managedObjectContext.save()
            }

        }
    }

    func swipeButton(for logEntry: LogEntry) -> some View {
        return Group {
            Button {
                editLogEntryOperation = Operation(editing: logEntry,
                                                  withParentContext: managedObjectContext)
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)

            Button(role: .destructive) {
                withAnimation {
                    managedObjectContext.delete(logEntry)
                    try? managedObjectContext.save()
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .labelStyle(.titleOnly)
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
