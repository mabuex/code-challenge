//
//  FetchItemsUseCase.swift
//  ShoppingList
//
//  Created by Marcus Buexenstein on 8/6/25.
//

import Foundation

/// Use case responsible for fetching shopping items from the repository.
/// Isolated to an actor for thread safety.
public actor FetchItemsUseCase {
    /// The repository used to retrieve shopping items.
    private let repository: ShoppingListRepository

    /// Initializes the use case with a repository.
    /// - Parameter repository: The shopping list repository.
    public init(repository: ShoppingListRepository) {
        self.repository = repository
    }

    /// Executes the fetch operation to retrieve shopping items.
    /// - Parameters:
    ///   - includeBought: Whether to include bought items in the results.
    ///   - searchQuery: Optional search string to filter items.
    ///   - sortDescending: Whether to sort items by updatedAt in descending order.
    /// - Returns: An array of ShoppingItem objects matching the criteria.
    public func execute(
        includeBought: Bool,
        searchQuery: String?,
        sortDescending: Bool
    ) async throws -> [ShoppingItem] {
        return try await repository.getAllItems(
            includeBought: includeBought,
            searchQuery: searchQuery,
            sortDescending: sortDescending
        )
    }
}
