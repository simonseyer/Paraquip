//
//  ParaquipWidget.swift
//  ParaquipWidget
//
//  Created by Simon Seyer on 28.08.23.
//

import WidgetKit
import SwiftUI
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()

    lazy var persistentContainer: NSPersistentContainer = {
        let storeURL = AppGroup.paraquip.containerURL.appendingPathComponent("Model.sqlite")
        let container = NSPersistentContainer(name: "Model")
        container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: storeURL)]
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
}

struct Provider: AppIntentTimelineProvider {

    let coreData = CoreDataStack.shared

    func placeholder(in context: Context) -> SimpleEntry {
        let context = coreData.persistentContainer.newBackgroundContext()
        return SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), equipment: [Equipment.create(type: .paraglider, context: context)])
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let context =  coreData.persistentContainer.newBackgroundContext()
        return SimpleEntry(date: Date(), configuration: configuration, equipment: [Equipment.create(type: .paraglider, context: context)])
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        let currentDate = Date()
        let request = NSFetchRequest<Equipment>(entityName: "Equipment")
        do {
            let result = try coreData.viewContext.fetch(request)

            for equipment in result {


                let entry = SimpleEntry(date: currentDate, configuration: configuration, equipment: [equipment])
                entries.append(entry)
            }
        } catch {
            print(error)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let equipment: [Equipment]
}

struct ParaquipWidgetEntryView : View {
    var entry: Provider.Entry

    let checks = [
        EquipmentCheck(equipmentName: "Explorer 2", equipmentType: .paraglider, date: Date()),
        EquipmentCheck(equipmentName: "Verso 3", equipmentType: .harness, date: Date()),
        EquipmentCheck(equipmentName: "Neon XQ", equipmentType: .reserve, date: Date()),
    ]


    var body: some View {
        VStack(alignment: .leading) {
            Text("Next Checks")
                .font(.caption)
                .foregroundStyle(.secondary)
            VStack {
                ForEach(entry.equipment) { equipment in
                    EquipmentCheckCell(check: .init(equipmentName: equipment.equipmentName, equipmentType: equipment.equipmentType, date: equipment.nextCheck ?? .now))
                }
            }


        }
    }
}

struct ParaquipWidget: Widget {
    let kind: String = "ParaquipWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            ParaquipWidgetEntryView(entry: entry)
                .containerBackground(.accent.gradient, for: .widget)
        }
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .systemSmall) {
    ParaquipWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley, equipment: [CoreData.fakeProfile.paraglider!])
    SimpleEntry(date: .now, configuration: .starEyes, equipment: [CoreData.fakeProfile.paraglider!])
}
