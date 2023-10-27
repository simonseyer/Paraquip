//
//  BatchedUndoManager.swift
//  Paraquip
//
//  Created by Simon Seyer on 27.10.23.
//

import Foundation
import Observation
import OSLog

@Observable
class BatchedUndoManager: @unchecked Sendable {
    let undoManager = UndoManager()
    private(set) var canUndo = false
    private(set) var canRedo = false

    private var isEditingInProgress = false
    private var endEditingTask: Task<Void, any Error>?

    private static let logger = Logger(category: "BatchedUndoManager")

    func beginEditing() {
        if !undoManager.isUndoing && !undoManager.isRedoing && !isEditingInProgress {
            Self.logger.debug("Begin undo grouping")
            undoManager.beginUndoGrouping()
            isEditingInProgress = true
            updateUndoState()
        }

        endEditingTask?.cancel()
        endEditingTask = Task {
            try await Task.sleep(for: .milliseconds(500))
            endEditing()
        }
    }

    func endEditing() {
        endEditingTask?.cancel()
        guard isEditingInProgress else {
            return
        }

        Self.logger.debug("End undo grouping")
        undoManager.endUndoGrouping()
        isEditingInProgress = false
        updateUndoState()
    }

    func undo() {
        endEditing()
        undoManager.undo()
        updateUndoState()
    }

    func redo() {
        undoManager.redo()
        updateUndoState()
    }

    func reset() {
        endEditing()
        undoManager.removeAllActions()
        updateUndoState()
    }

    private func updateUndoState() {
        canUndo = undoManager.canUndo
        canRedo = undoManager.canRedo
    }
}
