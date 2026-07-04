//
//  InMemoryModelContainer.swift
//  ShoppingList
//
//  Created by Marcus Buexenstein on 8/6/25.
//

import SwiftData
import ShoppingList
import Foundation

enum InMemoryModelContainer {
    static func create() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: ShoppingItem.self, configurations: config
        )
        
        return DispatchQueue.main.sync {
            container.mainContext
        }
    }
}
