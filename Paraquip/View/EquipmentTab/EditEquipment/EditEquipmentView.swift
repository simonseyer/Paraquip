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
    @Environment(\.undoManager) private var undoManager
    private let undoObserver = NotificationCenter.default.publisher(for: .NSUndoManagerDidCloseUndoGroup)

    @State private var canUndo = false
    @State private var canRedo = false

    var body: some View {
        Group {
            if let equipment {
                EditEquipmentContentView(equipment: equipment)
            } else {
                if profile?.allEquipment.isEmpty ?? false {
                    ContentUnavailableView("Create an equipment first", systemImage: "backpack.fill")
                } else {
                    ContentUnavailableView("Select an equipment",
                                           systemImage: "backpack.fill")
                }
            }
        }
        .onAppear {
            managedObjectContext.undoManager = undoManager
        }
        .onReceive(undoObserver) { _ in
            updateUndoState()
        }
        .toolbar {
            ToolbarItem {
                Button {
                    withAnimation {
                        undoManager?.undo()
                        updateUndoState()
                    }
                } label: {
                    Label("Undo", systemImage: "arrow.uturn.backward")
                }
                .keyboardShortcut(KeyEquivalent("z"), modifiers: [.command])
                .disabled(!canUndo)
            }
            ToolbarItem {
                Button {
                    withAnimation {
                        undoManager?.redo()
                        updateUndoState()
                    }
                } label: {
                    Label("Redo", systemImage: "arrow.uturn.forward")
                }
                .keyboardShortcut(KeyEquivalent("z"), modifiers: [.command, .shift])
                .disabled(!canRedo)
            }
        }
    }

    private func updateUndoState() {
        canUndo = undoManager?.canUndo ?? false
        canRedo = undoManager?.canRedo ?? false
    }
}

#Preview {
    EditEquipmentView(profile: CoreData.fakeProfile,
                      equipment: CoreData.fakeProfile.paraglider)
        .environment(\.managedObjectContext, CoreData.previewContext)
}
