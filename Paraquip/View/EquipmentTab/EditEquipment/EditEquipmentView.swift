//
//  EditEquipmentView.swift
//  Paraquip
//
//  Created by Simon Seyer on 02.10.23.
//

import SwiftUI

struct EditEquipmentView: View {

    let profile: Profile?
    let equipment: Equipment?

    @Environment(\.managedObjectContext) private var managedObjectContext

    @State private var undoManager = BatchedUndoManager()

    var body: some View {
        HStack {
            if let equipment {
                EditEquipmentContentView(equipment: equipment,
                                         undoManager: undoManager)
            } else {
                if profile?.allEquipment.isEmpty ?? false {
                    ContentUnavailableView("Create an equipment first", systemImage: "backpack.fill")
                } else {
                    ContentUnavailableView("Select an equipment",
                                           systemImage: "backpack.fill")
                }
            }
        }
        // Important to avoid layout glitches when opening edit view
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                ToolbarButton(isHidden: equipment == nil) {
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
                ToolbarButton(isHidden: equipment == nil) {
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
    }
}

#Preview {
    EditEquipmentView(profile: CoreData.fakeProfile,
                      equipment: CoreData.fakeProfile.paraglider)
        .environment(\.managedObjectContext, CoreData.previewContext)
}
