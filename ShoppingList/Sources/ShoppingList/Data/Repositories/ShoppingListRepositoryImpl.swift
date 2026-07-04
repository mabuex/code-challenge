//
//  ShoppingListRepositoryImpl.swift
//  ShoppingList
//
//  Created by Marcus Buexenstein on 8/6/25.
//

import Foundation
import SwiftData

/// Concrete implementation of the ShoppingListRepository protocol.
/// Handles CRUD operations for ShoppingItem entities using a SwiftData ModelContext.
/// All methods are isolated to the main actor for thread safety.
@MainActor
public final class ShoppingListRepositoryImpl: ShoppingListRepository {
    /// The SwiftData context used for data persistence.
    private let context: ModelContext
    
    /// Initializes the repository with a given ModelContext.
    /// - Parameter context: The SwiftData context to use.
    public init(context: ModelContext) {
        self.context = context
    }
    
    /// Adds a new shopping item to the context and saves changes.
    /// - Parameter item: The ShoppingItem to add.
    public func add(_ item: ShoppingItem) async throws {
        context.insert(item)
        try context.save()
    }
    
    /// Updates an existing shopping item, marks it as needing sync, and saves changes.
    /// - Parameter item: The ShoppingItem to update.
    public func update(_ item: ShoppingItem) async throws {
        item.updatedAt = Date()
        item.needsSync = true
        try context.save()
    }
    
    /// Soft deletes a shopping item by marking it as deleted and saves changes.
    /// - Parameter item: The ShoppingItem to delete.
    public func delete(_ item: ShoppingItem) async throws {
        // Soft delete the item by setting isDeleted to true; sync will manage actual deletion.
        item.isDeleted = true
        try context.save()
    }
    
    /// Retrieves all shopping items matching the given criteria.
    /// - Parameters:
    ///   - includeBought: Whether to include bought items.
    ///   - searchQuery: Optional search string to filter items by name or note.
    ///   - sortDescending: Whether to sort items by updatedAt in descending order.
    /// - Returns: An array of ShoppingItem objects matching the criteria.
    public func getAllItems(
        includeBought: Bool,
        searchQuery: String?,
        sortDescending: Bool
    ) async throws -> [ShoppingItem] {
        var predicate: Predicate<ShoppingItem>? = nil
        
        // Build predicate based on search query and includeBought flag.
        if let search = searchQuery?.lowercased(), !search.isEmpty {
            if includeBought {
                predicate = #Predicate {
                    $0.name.localizedStandardContains(search) ||
                    ($0.note?.localizedStandardContains(search) ?? false) &&
                    !$0.isDeleted
                }
            } else {
                predicate = #Predicate {
                    !$0.isBought &&
                    $0.name.localizedStandardContains(search) ||
                    ($0.note?.localizedStandardContains(search) ?? false) &&
                    !$0.isDeleted
                }
            }
        } else if !includeBought {
            predicate = #Predicate { !$0.isBought && !$0.isDeleted }
        } else {
            predicate = #Predicate { !$0.isDeleted }
        }
        
        // Set up fetch descriptor with predicate and sorting.
        let descriptor = FetchDescriptor<ShoppingItem>(
            predicate: predicate,
            sortBy: [
                SortDescriptor(\.updatedAt, order: sortDescending ? .reverse : .forward)
            ]
        )
        
        // Fetch and return items from the context.
        return try context.fetch(descriptor)
    }
}
