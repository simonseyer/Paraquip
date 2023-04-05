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

    @State private var editLogEntryOperation: Operation<LogEntry>?
    @State private var editEquipmentOperation: Operation<Equipment>?
    @State private var deleteLogEntry: LogEntry?
    @State private var isDeletingLogEntry = false
    @State private var isDeletingManual = false
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
                if equipment.isCheckable || equipment.purchaseLog != nil || !checkLog.isEmpty {
                    Section {
                        if equipment.isCheckable {
                            NextCheckCell(urgency: equipment.checkUrgency) {
                                let operation = Operation<LogEntry>(withParentContext: managedObjectContext)
                                operation.object(for: equipment).addToCheckLog(operation.object)
                                editLogEntryOperation = operation
                            }
                        }
                        ForEach(checkLog) { logEntry in
                            LogEntryCell(logEntry: logEntry)
                                .swipeActions {
                                    swipeButton(for: logEntry)
                                }
                                .labelStyle(.titleOnly)
                        }
                        
                        if let purchaseLog = equipment.purchaseLog {
                            LogEntryCell(logEntry: purchaseLog)
                                .swipeActions {
                                    swipeButton(for: purchaseLog)
                                }
                                .labelStyle(.titleOnly)
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
                            Button {
                                isDeletingManual = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                        }
                    }
                    .labelStyle(.titleOnly)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(equipment.equipmentName)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    editEquipmentOperation = Operation(editing: equipment,
                                                     withParentContext: managedObjectContext)
                }) {
                    Label("Edit", systemImage: "slider.vertical.3")
                }
            }
        }
        .sheet(item: $editLogEntryOperation) { operation in
            NavigationView {
                LogEntryView(logEntry: operation.object)
                    .environment(\.managedObjectContext, operation.childContext)
            }
        }
        .sheet(item: $editEquipmentOperation) { operation in
            NavigationView {
                EditEquipmentView(equipment: operation.object, locale: locale)
                    .environment(\.managedObjectContext, operation.childContext)
            }
        }
        .quickLookPreview($previewedManual)
        .sheet(isPresented: $showingManualPicker) {
            DocumentPicker(contentTypes: [.pdf]) { url in
                withAnimation {
                    let attachment = Attachment.create(fileURL: url,
                                                       context: managedObjectContext)
                    equipment.manualAttachment = attachment
                    try? managedObjectContext.save()
                }
            }

        }
        .confirmationDialog(Text("Delete log entry"), isPresented: $isDeletingLogEntry, presenting: deleteLogEntry) { logEntry in
            Button("Delete", role: .destructive) {
                withAnimation {
                    managedObjectContext.delete(logEntry)
                    try! managedObjectContext.save()
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog(Text("Delete manual"), isPresented: $isDeletingManual) {
            Button("Delete", role: .destructive) {
                withAnimation {
                    equipment.manualAttachment = nil
                    try? managedObjectContext.save()
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    func swipeButton(for logEntry: LogEntry) -> some View {
        return Group {
            Button {
                editLogEntryOperation = Operation(editing: logEntry,
                                                  withParentContext: managedObjectContext)
            } label: {
                Label("Edit", systemImage: "slider.vertical.3")
            }
            .tint(.blue)
            
            Button {
                deleteLogEntry = logEntry
                isDeletingLogEntry = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .tint(.red)
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
            .previewDisplayName(equipment.equipmentName)
        }
        .environment(\.locale, .init(identifier: "de"))
        .environment(\.managedObjectContext, CoreData.previewContext)
    }
}
