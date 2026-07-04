//
//  ShoppingListRepository.swift
//  ShoppingList
//
//  Created by Marcus Buexenstein on 8/6/25.
//

import Foundation

/// Protocol defining the contract for a shopping list repository.
/// Provides asynchronous CRUD operations for ShoppingItem entities.
public protocol ShoppingListRepository: Sendable {
    /// Adds a new shopping item to the repository.
    /// - Parameter item: The ShoppingItem to add.
    func add(_ item: ShoppingItem) async throws

    /// Updates an existing shopping item in the repository.
    /// - Parameter item: The ShoppingItem to update.
    func update(_ item: ShoppingItem) async throws

    /// Deletes a shopping item from the repository.
    /// - Parameter item: The ShoppingItem to delete.
    func delete(_ item: ShoppingItem) async throws

    /// Retrieves all shopping items matching the given criteria.
    /// - Parameters:
    ///   - includeBought: Whether to include bought items.
    ///   - searchQuery: Optional search string to filter items.
    ///   - sortDescending: Whether to sort items by updatedAt in descending order.
    /// - Returns: An array of ShoppingItem objects matching the criteria.
    func getAllItems(
        includeBought: Bool,
        searchQuery: String?,
        sortDescending: Bool
    ) async throws -> [ShoppingItem]
}
