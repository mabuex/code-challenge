//
//  DeleteItemUseCase.swift
//  ShoppingList
//
//  Created by Marcus Buexenstein on 8/6/25.
//

import Foundation

/// Use case responsible for deleting a shopping item.
/// Isolated to an actor for thread safety.
public actor DeleteItemUseCase {
    /// The repository used to manage shopping items.
    private let repository: ShoppingListRepository
    
    /// Initializes the use case with a repository.
    /// - Parameter repository: The shopping list repository.
    public init(repository: ShoppingListRepository) {
        self.repository = repository
    }
    
    /// Executes the delete item operation.
    /// - Parameter item: The ShoppingItem to delete.
    public func execute(item: ShoppingItem) async throws {
        try await repository.delete(item)
    }
}
