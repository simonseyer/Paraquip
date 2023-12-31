//
//  CoreDataOperation.swift
//  Paraquip
//
//  Created by Simon Seyer on 28.05.22.
//

import Foundation
import CoreData

struct Operation<Object: NSManagedObject>: Identifiable {

    let childContext: NSManagedObjectContext
    let object: Object

    var id: NSManagedObjectID {
        object.objectID
    }

    init(editing editObject: Object, withParentContext parentContext: NSManagedObjectContext) {
        childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        childContext.parent = parentContext
        object = childContext.object(with: editObject.objectID) as! Object
    }

    init(withParentContext parentContext: NSManagedObjectContext, create: (NSManagedObjectContext) -> Object) {
        childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        childContext.parent = parentContext
        object = create(childContext)
    }

    func object<T: NSManagedObject>(for object: T) -> T {
        return childContext.object(with: object.objectID) as! T
    }
}
