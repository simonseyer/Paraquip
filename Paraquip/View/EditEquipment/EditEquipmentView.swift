//
//  EditEquipmentView.swift
//  Paraquip
//
//  Created by Simon Seyer on 18.04.21.
//

import SwiftUI
import CoreData

extension NumberFormatter {
    func string(from doubleValue: Double) -> String? {
        return string(from: NSNumber(value: doubleValue))
    }

    func value(from string: String) -> Double? {
        return number(from: string)?.doubleValue
    }
}

extension Locale {
    var weightUnit: UnitMass {
        measurementSystem == .metric ? .kilograms : .pounds
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
        case customBrand
        case name
        case weight
        case purchaseDate
        case minimumWeight
        case maximumWeight
    }

    @ObservedObject var equipment: Equipment

    @Environment(\.managedObjectContext) private var managedObjectContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) var locale: Locale

    @State private var editLogEntryOperation: Operation<LogEntry>?
    @State private var showingManualPicker = false
    @State private var weight: String = ""
    @State private var minWeight: String = ""
    @State private var maxWeight: String = ""
    @FocusState private var focusedField: Field?

    private let weightUnitText: String
    private let weightFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 1
        return formatter
    }()
    private let weightRangeFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    private var title: Text {
        let type = NSLocalizedString(equipment.equipmentType.localizedNameString, comment: "")
        if !equipment.brandName.isEmpty {
            return Text("\(equipment.brandName) \(type)")
        } else {
            return Text(type)
        }
    }

    init(equipment: Equipment, locale: Locale) {
        self.equipment = equipment

        let formatter = MeasurementFormatter()
        formatter.locale = locale
        formatter.unitStyle = .short
        weightUnitText = formatter.string(from: locale.weightUnit)

        if let equipmentWeight = equipment.weightMeasurement {
            let value = equipmentWeight.converted(to: locale.weightUnit).value
            _weight = State(initialValue: weightFormatter.string(from: value) ?? "")
        }
        
        if let weightRange = equipment.weightRangeMeasurement {
            let minValue = weightRange.lowerBound.converted(to: locale.weightUnit).value
            let maxValue = weightRange.upperBound.converted(to: locale.weightUnit).value
            _minWeight = State(initialValue: weightRangeFormatter.string(from: minValue) ?? "")
            _maxWeight = State(initialValue: weightRangeFormatter.string(from: maxValue) ?? "")
        }
    }

    var body: some View {
        Form {
            Section(header: Text("")) {
                AutocompletingTextField("Brand", text: $equipment.brandName, completions: Equipment.brandSuggestions)
                HStack {
                    Text("Name")
                    Spacer()
                    TextField("", text: $equipment.equipmentName)
                        .multilineTextAlignment(.trailing)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .name)
                }
                AutocompletingTextField("Size", text: $equipment.equipmentSize, completions: Equipment.sizeSuggestions)
                    .textInputAutocapitalization(.characters)
                HStack {
                    Text("Weight")
                    Spacer()
                    TextField("", text: $weight)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .weight)
                    Text(weightUnitText)
                        .foregroundColor(.secondary)
                }
                Button(action: {
                    if let logEntry = equipment.purchaseLog {
                        editLogEntryOperation = Operation(editing: logEntry,
                                                          withParentContext: managedObjectContext)
                    } else {
                        let operation = Operation<LogEntry>(withParentContext: managedObjectContext)
                        operation.object(for: equipment).purchaseLog = operation.object
                        editLogEntryOperation = operation
                    }
                }) {
                    LabeledContent("Purchase") {
                        if let purchaseLog = equipment.purchaseLog {
                            LogDateCell(logEntry: purchaseLog)
                        }
                    }.foregroundColor(.primary)
                }
                .swipeActions {
                    if equipment.purchaseLog != nil {
                        Button {
                            equipment.purchaseLog = nil
                        } label: {
                            Label("Clear", systemImage: "clear")
                        }
                    }
                }
            }
            if equipment is Paraglider || equipment is Reserve {
                Section(header: Text("Weight range")) {
                    if equipment is Paraglider {
                        HStack {
                            Text("Minimum weight")
                            Spacer()
                            TextField("", text: $minWeight)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: .minimumWeight)
                            Text(weightUnitText)
                                .foregroundColor(.secondary)
                        }
                    }
                    HStack {
                        Text("Maximum weight")
                        Spacer()
                        TextField("", text: $maxWeight)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .maximumWeight)
                        Text(weightUnitText)
                            .foregroundColor(.secondary)
                    }
                }
            }
            if equipment.isCheckable {
                Section(header: Text("Check cycle")) {
                    CheckCycleRow(checkCycle: $equipment.floatingCheckCycle)
                }
            }
            if equipment.isInserted {
                Section(header: Text("Next steps")) {
                    if equipment.isCheckable {
                        Button(action: {
                            if let logEntry = equipment.allChecks.first {
                                editLogEntryOperation = Operation(editing: logEntry,
                                                                  withParentContext: managedObjectContext)
                            } else {
                                let operation = Operation<LogEntry>(withParentContext: managedObjectContext)
                                operation.object(for: equipment).addToCheckLog(operation.object)
                                editLogEntryOperation = operation
                            }
                        }) {
                            HStack {
                                FormIcon(icon: Image(systemName: "checkmark.circle.fill"))
                                    .padding(.trailing, 8)
                                Text("Log last check")
                                Spacer()
                                if !equipment.allChecks.isEmpty {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color.green)
                                }
                            }
                            .foregroundColor(.primary)
                        }
                    }

                    Button(action: { showingManualPicker = true }) {
                        HStack {
                            FormIcon(icon: Image(systemName: "book.fill"))
                                .padding(.trailing, 8)
                            Text("Attach Manual")
                            Spacer()
                            if equipment.manualAttachment != nil {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color.green)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    focusedField = nil
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    if let weight = weightFormatter.value(from: weight) {
                        equipment.weightMeasurement = .init(value: weight, unit: locale.weightUnit)
                    } else {
                        equipment.weightMeasurement = nil
                    }

                    let minWeight = weightRangeFormatter.value(from: minWeight)
                    let maxWeight = weightRangeFormatter.value(from: maxWeight)
                    if let maxWeight {
                        let sanitizedMinWeight = minWeight ?? 0
                        let sanitizedMaxWeight = max(maxWeight, sanitizedMinWeight)

                        let minMeasurement = Measurement<UnitMass>(value: sanitizedMinWeight, unit: locale.weightUnit)
                        let maxMeasurement = Measurement<UnitMass>(value: sanitizedMaxWeight, unit: locale.weightUnit)
                        equipment.weightRangeMeasurement = minMeasurement...maxMeasurement
                    } else {
                        equipment.weightRangeMeasurement = nil
                    }

                    try! managedObjectContext.save()
                    dismiss()
                }
                .disabled(equipment.brandName.isEmpty || equipment.equipmentName.isEmpty)
            }
        }
        .sheet(item: $editLogEntryOperation) { operation in
            NavigationView {
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
        .defaultBackground()
    }
}

struct AddEquipmentView_Previews: PreviewProvider {

    static var locale: Locale = .init(identifier: "de")

    static var previews: some View {
        Group {
            NavigationView {
                EditEquipmentView(equipment: Paraglider.create(context: CoreData.previewContext), locale: locale)
            }
            ForEach(CoreData.fakeProfile.allEquipment) { equipment in
                NavigationView {
                    EditEquipmentView(equipment: equipment, locale: locale)
                }
            }
        }
        .environment(\.locale, locale)
        .environment(\.managedObjectContext, CoreData.previewContext)
    }
}
