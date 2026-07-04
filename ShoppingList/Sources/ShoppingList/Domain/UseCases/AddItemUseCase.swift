//
//  AddItemUseCase.swift
//  ShoppingList
//
//  Created by Marcus Buexenstein on 8/6/25.
//

import Foundation

/// Use case responsible for adding a new shopping item.
/// Isolated to an actor for thread safety.
public actor AddItemUseCase {
    /// The repository used to persist shopping items.
    private let repository: ShoppingListRepository
    
    /// Initializes the use case with a repository.
    /// - Parameter repository: The shopping list repository.
    public init(repository: ShoppingListRepository) {
        self.repository = repository
    }
    
    /// Executes the add item operation.
    /// - Parameters:
    ///   - name: The name of the shopping item.
    ///   - quantity: The quantity of the item.
    ///   - note: An optional note for the item.
    public func execute(name: String, quantity: Int, note: String?) async throws {
        // Create a new ShoppingItem instance.
        let item = ShoppingItem(
            name: name,
            quantity: quantity,
            note: note
        )
        
        // Add the item to the repository.
        try await repository.add(item)
    }
}
