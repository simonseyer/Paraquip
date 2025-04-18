//
//  EditEquipmentContentView.swift
//  Paraquip
//
//  Created by Simon Seyer on 18.04.21.
//

import SwiftUI
import CoreData
import Combine

extension NumberFormatter {
    func string(from doubleValue: Double) -> String? {
        return string(from: NSNumber(value: doubleValue))
    }

    func value(from string: String) -> Double? {
        return number(from: string)?.doubleValue
    }
}

fileprivate struct LogDateCell: View {

    @ObservedObject var logEntry: LogEntry

    var body: some View {
        HStack {
            if !logEntry.logEntryAttachments.isEmpty {
                Image(systemName: "paperclip")
            }
            Text(logEntry.logEntryDate, format: Date.FormatStyle(date: .abbreviated, time: .omitted))
        }
        .foregroundColor(.secondary)
    }
}

struct EditEquipmentView: View {

    enum Field {
        case brand
        case name
        case size
        case weight
        case purchaseDate
        case minimumWeight
        case maximumWeight
        case minimumRecommendedWeight
        case maximumRecommendedWeight
        case projectedArea
    }

    @ObservedObject var equipment: Equipment
    @State private var undoManager = BatchedUndoManager()

    @Environment(\.managedObjectContext) private var managedObjectContext

    @State private var editLogEntryOperation: Operation<LogEntry>?
    @State private var showingManualPicker = false
    @State private var previewedManual: URL? = nil
    @State private var isShowingRecommendedWeightRange = false
    @State private var isShowingValidationAlert = false
    @State private var isShowingDeleteEquipment = false
    @State private var validationAlertMessage: LocalizedStringKey?
    @State private var editingSubscription: AnyCancellable?
    @State private var recommendedWeightRangeUndoHandler = UndoHandler<Bool>()
    @FocusState private var focusedField: Field?

    private var isMaxWeightValid: Bool {
        equipment.maxWeightValue ?? .greatestFiniteMagnitude >= equipment.minWeightValue ?? 0
    }

    private var isRecommendedWeightValid: Bool {
        let min = equipment.minWeightValue ?? 0
        let max = equipment.maxWeightValue ?? .greatestFiniteMagnitude
        let minRecommended = equipment.minRecommendedWeightValue ?? min
        let maxRecommended = equipment.maxRecommendedWeightValue ?? max
        return minRecommended >= min && maxRecommended >= minRecommended && maxRecommended <= max
    }

    private var weightRangeFormat: FloatingPointFormatStyle<Double> {
        .number.precision(.fractionLength(0))
    }

    private var formattedMinWeight: String {
        equipment.minWeightValue?.formatted(weightRangeFormat) ?? ""
    }

    private var formattedMaxWeight: String {
        equipment.maxWeightValue?.formatted(weightRangeFormat) ?? ""
    }

    private var clearLabel: some View {
        Label("Clear", systemImage: "xmark.circle")
            #if os(visionOS)
            .labelStyle(.titleOnly)
            #else
            .labelStyle(.iconOnly)
            #endif
    }

    var body: some View {
        Form {
            Section(header: Text("")) {
                AutocompletingTextField("Brand", text: $equipment.brandName, completions: Equipment.brandSuggestions)
                    .focused($focusedField, equals: .brand)
                HStack {
                    Text("Name")
                    Spacer()
                    TextField("", text: $equipment.equipmentName)
                        .multilineTextAlignment(.trailing)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .name)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .size }
                }
                AutocompletingTextField("Size", text: $equipment.equipmentSize, completions: Equipment.sizeSuggestions)
                    .textInputAutocapitalization(.characters)
                    .focused($focusedField, equals: .size)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .weight }
                HStack {
                    Text("Weight")
                    Spacer()
                    TextField("", value: $equipment.weightValue, format: .number.precision(.fractionLength(1...2)))
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .weight)
                    Text("kg")
                        .foregroundColor(.secondary)
                }
                Button(action: {
                    if let logEntry = equipment.purchaseLog {
                        editLogEntryOperation = Operation(editing: logEntry,
                                                          withParentContext: managedObjectContext)
                    } else {
                        let operation = Operation(withParentContext: managedObjectContext) {
                            LogEntry.create(context: $0)
                        }
                        operation.object(for: equipment).purchaseLog = operation.object
                        editLogEntryOperation = operation
                    }
                }) {
                    LabeledContent("Purchase") {
                        if let purchaseLog = equipment.purchaseLog {
                            LogDateCell(logEntry: purchaseLog)
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            Section {
                if let manual = equipment.manualAttachment {
                    Button {
                        previewedManual = manual.fileURL
                    } label: {
                        Label("Open manual", systemImage: "book")
                    }
                } else {
                    Button(action: {
                        showingManualPicker = true
                    }) {
                        Label("Add manual",
                              systemImage: "plus.circle")
                    }
                }
            } header: {
                HStack(spacing: 12) {
                    Text("Manual")
                    Button(action: {
                        withAnimation {
                            equipment.manualAttachment = nil
                        }
                    }) {
                        clearLabel
                    }
                    .controlSize(.mini)
                    .opacity(equipment.manualAttachment == nil ? 0 : 1)
                }
            }
            if [.paraglider, .reserve].contains(equipment.equipmentType) {
                Section {
                    if equipment.equipmentType == .paraglider {
                        HStack {
                            Text("Minimum")
                            Spacer()
                            TextField("", value: $equipment.minWeightValue, format: weightRangeFormat)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: .minimumWeight)
                                .submitLabel(.next)
                                .onSubmit { focusedField = .maximumWeight }
                            Text("kg")
                                .foregroundColor(.secondary)
                        }
                    }
                    HStack {
                        Text("Maximum")
                        Spacer()
                        TextField("", value: $equipment.maxWeightValue, format: weightRangeFormat)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .maximumWeight)
                            .submitLabel(.next)
                            .onSubmit {
                                if isShowingRecommendedWeightRange {
                                    focusedField = .minimumRecommendedWeight
                                } else {
                                    focusedField = .projectedArea
                                }
                            }
                        Text("kg")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    HStack {
                        Text("Weight range")
                        Spacer()
                        Button {
                            validationAlertMessage = "The maximum weight must be larger then the mimimum weight."
                            isShowingValidationAlert.toggle()
                        } label: {
                            Image(systemName: "exclamationmark.triangle")
                        }
                        .controlSize(.mini)
                        .foregroundStyle(.red)
                        .opacity(isMaxWeightValid ? 0 : 1)
                        .animation(.default, value: isMaxWeightValid)
                    }
                } footer: {
                    if equipment.equipmentType == .paraglider && !isShowingRecommendedWeightRange {
                        Button("\(Image(systemName: "plus")) Recommended weight range") {
                            withAnimation {
                                isShowingRecommendedWeightRange.toggle()
                            }
                        }
                        .controlSize(.small)
                    }
                }
            }
            if equipment.equipmentType == .paraglider && isShowingRecommendedWeightRange {
                Section {
                    HStack {
                        Text("Minimum")
                        Spacer()
                        TextField(formattedMinWeight, value: $equipment.minRecommendedWeightValue, format: weightRangeFormat)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .minimumRecommendedWeight)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .maximumRecommendedWeight }
                        Text("kg")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Maximum")
                        Spacer()
                        TextField(formattedMaxWeight, value: $equipment.maxRecommendedWeightValue, format: weightRangeFormat)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .maximumRecommendedWeight)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .projectedArea }
                        Text("kg")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    HStack(spacing: 12) {
                        Text("Recommended weight range")
                        Button {
                            withAnimation {
                                equipment.clearRecommendedWeightRange()
                                isShowingRecommendedWeightRange.toggle()
                            }
                        } label: {
                            clearLabel
                        }.controlSize(.mini)
                        Spacer()
                        Button("\(Image(systemName: "exclamationmark.triangle"))") {
                            validationAlertMessage = "The recommended weight range must lie within the certified weight range."
                            isShowingValidationAlert.toggle()
                        }
                        .controlSize(.mini)
                        .foregroundStyle(.red)
                        .opacity(isRecommendedWeightValid ? 0 : 1)
                        .animation(.default, value: isRecommendedWeightValid)
                    }
                }
            }
            if equipment.equipmentType == .paraglider {
                Section(header: Text("Specifications")) {
                    HStack {
                        Text("Projected area")
                        Spacer()
                        TextField("", value: $equipment.projectedAreaValue, format: .number.precision(.fractionLength(0)))
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .projectedArea)
                        Text("m²")
                            .foregroundColor(.secondary)
                    }
                }
            }
            Section(header: Text("Check cycle")) {
                CheckCycleRow(checkCycle: $equipment.floatingCheckCycle)
            }
            Button(role: .destructive) {
                isShowingDeleteEquipment = true
            } label: {
                Label("Delete equipment",
                      systemImage: "trash")
                .foregroundStyle(.red)
            }
            .confirmationDialog("Delete equipment", isPresented: $isShowingDeleteEquipment) {
                Button(role: .destructive) {
                    withAnimation {
                        managedObjectContext.delete(equipment)
                    }
                } label: {
                    Text("Delete")
                }
            }
        }
        #if os(iOS)
        .scrollDismissesKeyboard(.interactively)
        #endif
        .navigationTitle(Text(equipment.equipmentType.localizedName))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                ToolbarButton {
                    withAnimation {
                        undoManager.undo()
                    }
                } simpleLabel: {
                    Image(systemName: "arrow.uturn.backward")
                        .accessibilityLabel("Undo")
                } complexLabel: {
                    Label("Undo", systemImage: "arrow.uturn.backward")
                }
                .keyboardShortcut(KeyEquivalent("z"), modifiers: [.command])
                .disabled(!undoManager.canUndo)
            }
            ToolbarItem {
                ToolbarButton {
                    withAnimation {
                        undoManager.redo()
                    }
                } simpleLabel: {
                    Image(systemName: "arrow.uturn.forward")
                        .accessibilityLabel("Redo")
                } complexLabel: {
                    Label("Redo", systemImage: "arrow.uturn.forward")
                }
                .keyboardShortcut(KeyEquivalent("z"), modifiers: [.command, .shift])
                .disabled(!undoManager.canRedo)
            }
        }
        .sheet(item: $editLogEntryOperation) { operation in
            NavigationStack {
                LogEntryView(logEntry: operation.object)
                    .environment(\.managedObjectContext, operation.childContext)
            }
        }
        .sheet(isPresented: $showingManualPicker) {
            DocumentPicker(contentTypes: [.pdf]) { url in
                let attachment = Attachment.create(fileURL: url,
                                                   context: managedObjectContext)
                equipment.manualAttachment = attachment
            }
        }
        .quickLookPreview($previewedManual)
        .alert("Invalid weight range", isPresented: $isShowingValidationAlert, presenting: $validationAlertMessage) { _ in
            Button("Ok", role: .cancel) { }
        } message: { message in
            if let message = message.wrappedValue {
                Text(message)
            }
        }
        .onChange(of: isShowingRecommendedWeightRange) {  oldValue, newValue in
            recommendedWeightRangeUndoHandler.registerUndo(from: oldValue, to: newValue)
        }
        .onChange(of: equipment, initial: true) {
            isShowingRecommendedWeightRange = equipment.hasRecommendedWeightRange
            undoManager.reset()

            // Manually observe equipment to capture all changes
            editingSubscription = equipment.objectWillChange.sink {
                undoManager.beginEditing()
            }
        }
        .onAppear {
            recommendedWeightRangeUndoHandler.undoManger = undoManager.undoManager
            recommendedWeightRangeUndoHandler.binding = $isShowingRecommendedWeightRange
            managedObjectContext.undoManager = undoManager.undoManager
        }
        .onDisappear {
            undoManager.reset()
        }
    }

}

#Preview("New Paraglider") {
    NavigationStack {
        EditEquipmentView(equipment: Equipment.paraglider(context: .preview))
    }
}

#Preview("Paraglider") {
    NavigationStack {
        EditEquipmentView(equipment: CoreData.fakeProfile.paraglider!)
    }
    .environment(\.managedObjectContext, .preview)
}

#Preview("Harness") {
    NavigationStack {
        EditEquipmentView(equipment: CoreData.fakeProfile.singleEquipment(of: .harness)!)
    }
    .environment(\.managedObjectContext, .preview)
}

#Preview("Reserve") {
    NavigationStack {
        EditEquipmentView(equipment: CoreData.fakeProfile.singleEquipment(of: .reserve)!)
    }
    .environment(\.managedObjectContext, .preview)
}
