//
//  ShoppingListModelContainer.swift
//  ShoppingList
//
//  Created by Marcus Buexenstein on 8/6/25.
//

import SwiftData

/// Provides a shared instance of ModelContainer for the ShoppingList app.
/// This container manages the persistence layer for ShoppingItem entities.
public struct ShoppingListModelContainer {
    /// Shared singleton instance of ModelContainer, configured with the ShoppingItem schema.
    public static let shared: ModelContainer = {
        // Define the schema with the ShoppingItem entity.
        let schema = Schema([ShoppingItem.self])
        // Configure the container to persist data on disk (not in memory).
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            // Attempt to create and return the ModelContainer.
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            // Terminate the app if the container cannot be created.
            fatalError("Could not create ModelContainer")
        }
    }()
}
