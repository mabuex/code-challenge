//
//  UpdateItemUseCase.swift
//  ShoppingList
//
//  Created by Marcus Buexenstein on 8/6/25.
//

import Foundation

/// Use case responsible for updating an existing shopping item.
/// Isolated to an actor for thread safety.
public actor UpdateItemUseCase {
    /// The repository used to manage shopping items.
    private let repository: ShoppingListRepository

    /// Initializes the use case with a repository.
    /// - Parameter repository: The shopping list repository.
    public init(repository: ShoppingListRepository) {
        self.repository = repository
    }

    /// Executes the update item operation.
    /// - Parameter item: The ShoppingItem to update.
    public func execute(item: ShoppingItem) async throws {
        try await repository.update(item)
    }
}
