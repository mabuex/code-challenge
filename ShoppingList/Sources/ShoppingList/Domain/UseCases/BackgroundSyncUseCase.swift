//
//  BackgroundSyncUseCase.swift
//  ShoppingList
//
//  Created by Marcus Buexenstein on 8/6/25.
//

import Foundation
import SwiftData

/// Use case responsible for synchronizing shopping list data between local storage and a remote data source.
/// Handles background sync, including conflict resolution and exponential backoff on failure.
public struct BackgroundSyncUseCase: @unchecked Sendable {
    /// The local SwiftData context for persistence.
    private let context: ModelContext
    /// The remote data source for syncing shopping items.
    private let remote: ShoppingListRemoteDataSource
    
    /// Initializes the use case with a local context and remote data source.
    /// - Parameters:
    ///   - context: The SwiftData context for persistence.
    ///   - remote: The remote data source for shopping items.
    public init(context: ModelContext, remote: ShoppingListRemoteDataSource) {
        self.context = context
        self.remote = remote
    }
    
    /// Fetches the latest items from the remote data source.
    private func fetchItems() async throws {
        try await remote.fetch()
    }
        
    /// Deletes items marked as deleted both locally and remotely.
    private func deleteItems() async throws {
        let deletedPredicate = #Predicate<ShoppingItem> { $0.isDeleted == true }
        let itemsToDelete = try context.fetch(FetchDescriptor(predicate: deletedPredicate))
        
        // Delete items from remote first.
        try await remote.delete(items: itemsToDelete)
        
        // Remove items from local context.
        for item in itemsToDelete {
            context.delete(item)
        }
    }
    
    /// Synchronizes local items with the remote data source.
    /// Handles inserting new items, updating changed items, and marking items as synced.
    private func syncItems() async throws {
        let localItems = try context.fetch(FetchDescriptor<ShoppingItem>())
        let remoteStore = await remote.store
        
        var itemsToUpdate: [ShoppingItem] = []
        var itemsToInsert: [ShoppingItem] = []
        
        // Insert remote items that do not exist locally.
        for remoteItem in remoteStore {
            if !localItems.contains(where: { $0.identifier == remoteItem.key }) {
                let remoteItem = remoteItem.value
                remoteItem.needsSync = false // Mark as synced
                print("Inserting remote item: \(remoteItem.name)")
                context.insert(remoteItem)
            }
        }
        
        for item in localItems {
            // Check if the item exists in remote store.
            if let remoteItem = remoteStore[item.identifier] {
                // If the remote item exists, compare timestamps.
                if  item.updatedAt > remoteItem.updatedAt {
                    // Local item is newer, update remote.
                    itemsToUpdate.append(item)
                }
            } else {
                // If the remote item does not exist, it means it's a new item.
                itemsToInsert.append(item)
            }
            
            // Mark item as synced.
            item.needsSync = false
        }
        
        // Insert and update items in remote.
        try await remote.insert(items: itemsToInsert)
        try await remote.update(items: itemsToUpdate)
    }
    
    /// Executes the background synchronization process with exponential backoff on failure.
    /// Attempts to delete, fetch, and sync items, saving the context if successful.
    public func execute() async throws {
        var attempt = 0
        let maxAttempts = 3
        var delay: UInt64 = 1_000_000_000 // 1 second in nanoseconds
        
        // Exponential backoff retry loop.
        while attempt < maxAttempts {
            do {
                // Fetch items from remote.
                try await fetchItems()
                // Delete items that are marked as deleted.
                try await deleteItems()
                // Sync local items with remote.
                try await syncItems()
                // Save changes to local context.
                try context.save()
                
                await remote.cleanup()
                print("🟢 Background sync succeeded on attempt \(attempt + 1).")
                return
            } catch {
                attempt += 1
                
                if attempt == maxAttempts {
                    print("🔴 Sync failed after \(attempt) attempts: \(error)")
                    throw error
                }
                
                print("🟡 Sync attempt \(attempt) failed, retrying in \(delay / 1_000_000_000) seconds")
                try? await Task.sleep(nanoseconds: delay)
                delay *= 2 // Exponential backoff.
            }
        }
    }
}
