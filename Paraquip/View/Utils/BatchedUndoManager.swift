//
//  BatchedUndoManager.swift
//  Paraquip
//
//  Created by Simon Seyer on 27.10.23.
//

import Foundation
import Observation
import OSLog
import Combine

class BatchedUndoManager: @unchecked Sendable, ObservableObject {
    let undoManager = UndoManager()
    @Published private(set) var canUndo = false
    @Published private(set) var canRedo = false

    private var isEditingInProgress = false
    private var endEditingTask: Task<Void, any Error>?
    private var subscriptions: Set<AnyCancellable> = []

    private static let logger = Logger(category: "BatchedUndoManager")

    init() {
        undoManager.groupsByEvent = false

        NotificationCenter.default.publisher(for: .NSUndoManagerDidUndoChange, object: undoManager)
            .merge(with: NotificationCenter.default.publisher(for: .NSUndoManagerDidRedoChange, object: undoManager))
            .merge(with: NotificationCenter.default.publisher(for: .NSUndoManagerDidOpenUndoGroup, object: undoManager))
            .merge(with: NotificationCenter.default.publisher(for: .NSUndoManagerDidCloseUndoGroup, object: undoManager))
            .sink { [weak self] _ in
                self?.updateUndoState()
            }
            .store(in: &subscriptions)
    }

    func beginEditing() {
        if !undoManager.isUndoing && !undoManager.isRedoing && !isEditingInProgress {
            Self.logger.debug("Begin undo grouping")
            isEditingInProgress = true
            undoManager.beginUndoGrouping()
        }

        endEditingTask?.cancel()
        endEditingTask = Task {
            try await Task.sleep(for: .milliseconds(500))
            endEditing()
        }
    }

    private func endEditing() {
        endEditingTask?.cancel()
        guard isEditingInProgress else {
            return
        }

        Self.logger.debug("End undo grouping")
        undoManager.endUndoGrouping()
        isEditingInProgress = false
    }

    func undo() {
        endEditing()
        undoManager.undo()
    }

    func redo() {
        undoManager.redo()
    }

    func reset() {
        endEditing()
        undoManager.removeAllActions()
    }

    private func updateUndoState() {
        canUndo = undoManager.canUndo
        canRedo = undoManager.canRedo
    }
}
