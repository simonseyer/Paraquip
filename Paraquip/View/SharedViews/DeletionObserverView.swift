//
//  DeletionObserverView.swift
//  Paraquip
//
//  Created by Simon Seyer on 01.10.23.
//

import SwiftUI
import CoreData

struct DeletionObserverView: View {
    @ObservedObject var object: NSManagedObject
    let onDelete: () -> Void

    var body: some View {
        EmptyView()
            .onChange(of: object.isDeleted) {
                if object.isDeleted {
                    onDelete()
                }
            }
            .onChange(of: object.isFault) {
                // Handle case when new object get's deleted again
                if object.isFault {
                    onDelete()
                }
            }
    }
}


#Preview {
    DeletionObserverView(object: Equipment.create(context: CoreData.previewContext)) {
        print("Deleted")
    }
}
