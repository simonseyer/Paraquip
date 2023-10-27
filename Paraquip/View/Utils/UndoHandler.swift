//
//  UndoHandler.swift
//  Paraquip
//
//  Created by Simon Seyer on 03.10.23.
//

import Foundation
import SwiftUI

class UndoHandler<Value: Equatable> {
    var binding: Binding<Value>?
    weak var undoManger: UndoManager?
    private var lastUndo: Value?

    func registerUndo(from oldValue: Value, to newValue: Value) {
        // Prevent the undo action from registering as an undo itself
        if lastUndo == newValue {
            return
        }
        undoManger?.registerUndo(withTarget: self) { handler in
            handler.registerUndo(from: newValue, to: oldValue)
            handler.lastUndo = oldValue
            handler.binding?.wrappedValue = oldValue
        }
    }
}
