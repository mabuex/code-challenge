//
//  ShoppingListViewModel.swift
//  ShoppingList
//
//  Created by Marcus Buexenstein on 8/6/25.
//

import Foundation
import SwiftData
import Observation

/// ViewModel responsible for managing the shopping list state and business logic.
/// Handles loading, adding, updating, deleting, and syncing shopping items.
/// Annotated with @MainActor and @Observable for UI updates and concurrency safety.
@MainActor
@Observable
public final class ShoppingListViewModel {
    /// The list of shopping items currently loaded.
    public var items: [ShoppingItem] = []
    /// The current search query for filtering items.
    public var searchQuery: String = ""
    /// Whether to show bought items in the list.
    public var showBoughtItems: Bool = false
    /// Whether to sort items in descending order.
    public var sortDescending: Bool = false
    
    /// Use case for fetching items from the repository.
    private let fetchItemsUseCase: FetchItemsUseCase
    /// Use case for adding new items.
    private let addItemsUseCase: AddItemUseCase
    /// Use case for updating existing items.
    private let updateItemUseCase: UpdateItemUseCase
    /// Use case for deleting items.
    private let deleteItemUseCase: DeleteItemUseCase
    /// Use case for background synchronization with remote data source.
    private var backgroundSyncUseCase: BackgroundSyncUseCase
    
    /// Initializes the view model with all required use cases.
    /// - Parameters:
    ///   - fetchItemsUseCase: Use case for fetching items.
    ///   - addItemsUseCase: Use case for adding items.
    ///   - updateItemUseCase: Use case for updating items.
    ///   - deleteItemUseCase: Use case for deleting items.
    ///   - backgroundSyncUseCase: Use case for background sync.
    public init(
        fetchItemsUseCase: FetchItemsUseCase,
        addItemsUseCase: AddItemUseCase,
        updateItemUseCase: UpdateItemUseCase,
        deleteItemUseCase: DeleteItemUseCase,
        backgroundSyncUseCase: BackgroundSyncUseCase
    ) {
        self.fetchItemsUseCase = fetchItemsUseCase
        self.addItemsUseCase = addItemsUseCase
        self.updateItemUseCase = updateItemUseCase
        self.deleteItemUseCase = deleteItemUseCase
        self.backgroundSyncUseCase = backgroundSyncUseCase
    }
    
    /// Loads shopping items using the fetch use case and updates the items array.
    public func loadItems() async {
        do {
            let result = try await fetchItemsUseCase.execute(
                includeBought: showBoughtItems,
                searchQuery: searchQuery,
                sortDescending: sortDescending
            )
            
            self.items = result
        } catch {
            print("🔴 Failed to fetch items: \(error.localizedDescription)")
        }
    }
    
    /// Adds a new shopping item and reloads the items list.
    /// - Parameters:
    ///   - name: Name of the item.
    ///   - quantity: Quantity of the item.
    ///   - note: Optional note for the item.
    public func addItem(name: String, quantity: Int, note: String?) async {
        do {
            try await addItemsUseCase.execute(name: name, quantity: quantity, note: note)
            await loadItems()
        } catch {
            print("🔴 Failed to add item: \(error.localizedDescription)")
        }
    }
    
    /// Updates an existing shopping item and reloads the items list.
    /// - Parameter item: The item to update.
    public func updateItem(_ item: ShoppingItem) async {
        do {
            try await updateItemUseCase.execute(item: item)
            await loadItems()
        } catch {
            print("🔴 Failed to update item: \(error.localizedDescription)")
        }
    }
    
    /// Deletes a shopping item, reloads the items list, and removes it from the local array.
    /// - Parameter item: The item to delete.
    public func deleteItem(_ item: ShoppingItem) async {
        do {
            try await deleteItemUseCase.execute(item: item)
            await loadItems()
            // Remove from local array to reflect changes immediately
            items.removeAll { $0.id == item.id }
        } catch {
            print("🔴 Failed to delete item: \(error.localizedDescription)")
        }
    }
    
    /// Triggers background synchronization of shopping items with the remote data source.
    public func syncItems() async {
        do {
            try await backgroundSyncUseCase.execute()
        } catch {
            print("🔴 Failed to sync items: \(error.localizedDescription)")
        }
    }
}
