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

    @Environment(\.managedObjectContext) private var managedObjectContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) var locale: Locale

    @State private var editLogEntryOperation: Operation<LogEntry>?
    @State private var showingManualPicker = false
    @State private var isShowingRecommendedWeightRange: Bool
    @State private var weight: String = ""
    @State private var minWeight: String = ""
    @State private var maxWeight: String = ""
    @State private var minRecommendedWeight: String = ""
    @State private var maxRecommendedWeight: String = ""
    @State private var projectedArea: String = ""
    @FocusState private var focusedField: Field?

    private let initialFocusedField: Field?
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
        let type = LocalizedString(equipment.equipmentType.localizedNameString)
        if !equipment.brandName.isEmpty {
            return Text("\(equipment.brandName) \(type)")
        } else {
            return Text(type)
        }
    }

    init(equipment: Equipment, locale: Locale, focusedField: Field? = nil) {
        self.equipment = equipment
        self.initialFocusedField = focusedField

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

        if let weightRange = equipment.recommendedWeightRangeMeasurement {
            let minValue = weightRange.lowerBound.converted(to: locale.weightUnit).value
            let maxValue = weightRange.upperBound.converted(to: locale.weightUnit).value
            _minRecommendedWeight = State(initialValue: weightRangeFormatter.string(from: minValue) ?? "")
            _maxRecommendedWeight = State(initialValue: weightRangeFormatter.string(from: maxValue) ?? "")
            _isShowingRecommendedWeightRange = .init(initialValue: true)
        } else {
            _isShowingRecommendedWeightRange = .init(initialValue: false)
        }
        
        if let projectedArea = equipment.projectedAreaMeasurement {
            let value = projectedArea.converted(to: .squareMeters).value
            _projectedArea = State(initialValue: weightFormatter.string(from: value) ?? "")
        }
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
                .labelStyle(.titleOnly)
            }
            if equipment is Paraglider || equipment is Reserve {
                Section {
                    if equipment is Paraglider {
                        HStack {
                            Text("Minimum")
                            Spacer()
                            TextField("", text: $minWeight)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: .minimumWeight)
                                .submitLabel(.next)
                                .onSubmit { focusedField = .maximumWeight }
                            Text(weightUnitText)
                                .foregroundColor(.secondary)
                        }
                    }
                    HStack {
                        Text("Maximum")
                        Spacer()
                        TextField("", text: $maxWeight)
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
                        Text(weightUnitText)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Weight range")
                } footer: {
                    if equipment is Paraglider && !isShowingRecommendedWeightRange {
                        Button("\(Image(systemName: "plus")) Recommended weight range") {
                            withAnimation {
                                isShowingRecommendedWeightRange.toggle()
                            }
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.accentColor)
                    }
                }
            }
            if isShowingRecommendedWeightRange {
                Section {
                    HStack {
                        Text("Minimum")
                        Spacer()
                        TextField("\(minWeight)", text: $minRecommendedWeight)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .minimumRecommendedWeight)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .maximumRecommendedWeight }
                        Text(weightUnitText)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Maximum")
                        Spacer()
                        TextField("\(maxWeight)", text: $maxRecommendedWeight)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .maximumRecommendedWeight)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .projectedArea }
                        Text(weightUnitText)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    HStack {
                        Text("Recommended weight range")
                        Button("\(Image(systemName: "minus.circle.fill"))") {
                            withAnimation {
                                minRecommendedWeight = ""
                                maxRecommendedWeight = ""
                                isShowingRecommendedWeightRange.toggle()
                            }
                        }.buttonStyle(.plain)
                    }
                }
            }
            if equipment is Paraglider {
                Section(header: Text("Specifications")) {
                    HStack {
                        Text("Projected area")
                        Spacer()
                        TextField("", text: $projectedArea)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .projectedArea)
                        Text("m²")
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

                    let minRecommendedWeight = weightRangeFormatter.value(from: minRecommendedWeight)
                    let maxRecommendedWeight = weightRangeFormatter.value(from: maxRecommendedWeight)
                    if let minRecommendedWeight, let maxRecommendedWeight, maxRecommendedWeight >= minRecommendedWeight {
                        let minMeasurement = Measurement<UnitMass>(value: minRecommendedWeight, unit: locale.weightUnit)
                        let maxMeasurement = Measurement<UnitMass>(value: maxRecommendedWeight, unit: locale.weightUnit)
                        equipment.recommendedWeightRangeMeasurement = minMeasurement...maxMeasurement
                    } else {
                        equipment.recommendedWeightRangeMeasurement = nil
                    }
                    
                    if let weight = weightFormatter.value(from: projectedArea) {
                        equipment.projectedAreaMeasurement = .init(value: weight, unit: .squareMeters)
                    } else {
                        equipment.projectedAreaMeasurement = nil
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
        .onAppear {
            if let initialFocusedField {
                focusedField = initialFocusedField
            } else if equipment.isInserted {
                focusedField = .brand
            }
        }
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
