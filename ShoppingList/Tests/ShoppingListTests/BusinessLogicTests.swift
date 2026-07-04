//
//  BusinessLogicTests.swift
//  ShoppingList
//
//  Created by Marcus Buexenstein on 8/6/25.
//

import Testing
import ShoppingList
@testable import ShoppingList
import XCTest

@Suite
struct BusinessLogicTests {
    @Test("Fetches all items in the repository")
    func testFetchItems() async throws {
        let repository = MockShoppingListRepository()
        let useCase = FetchItemsUseCase(repository: repository)
        
        let item1 = ShoppingItem(name: "Item 1", quantity: 1, note: nil)
        let item2 = ShoppingItem(name: "Item 2", quantity: 1, note: "This is a test item")
        let item3 = ShoppingItem(name: "Item 3", quantity: 1, note: nil)
        
        item2.isBought = true
        // Add items to the repository
        try await repository.add(item1)
        try await repository.add(item2)
        try await repository.add(item3)
        
        // Fetch items with different parameters
        let result1 = try await useCase.execute(includeBought: false, searchQuery: nil, sortDescending: false)
        #expect(result1.count == 2)
        
        let result2 = try await useCase.execute(includeBought: true, searchQuery: nil, sortDescending: false)
        #expect(result2.count == 3)
        
        let result3 = try await useCase.execute(includeBought: false, searchQuery: "Item 1", sortDescending: false)
        #expect(result3.count == 1)
    }
    
    @Test("Adds an item to the repository")
    func testAddItem() async throws {
        let repository = MockShoppingListRepository()
        let useCase = AddItemUseCase(repository: repository)
        
        try await useCase.execute(name: "Test Item", quantity: 4, note: "Test Note")
        
        // Verify the item was added correctly
        await #expect(repository.storage.count == 1)
        await #expect(repository.storage.first?.name == "Test Item")
    }
    
    @Test("Updates an item in the repository")
    func testUpdateItem() async throws {
        let repository = MockShoppingListRepository()
        let addUseCase = AddItemUseCase(repository: repository)
        let updateUseCase = UpdateItemUseCase(repository: repository)
        
        try await addUseCase.execute(name: "Old Item", quantity: 1, note: nil)
        
        if let item = await repository.storage.first(where: { $0.name == "Old Item" }) {
            item.name = "Updated Item"
            item.quantity = 2
            item.note = "Updated Note"
            
            try await updateUseCase.execute(item: item)
        }
        
        // Verify the item was updated
        await #expect(repository.storage.count == 1)
        await #expect(repository.storage.first?.name == "Updated Item")
    }
    
    @Test("Delete an item in the repository")
    func testDeleteItem() async throws {
        let repository = MockShoppingListRepository()
        let useCase = DeleteItemUseCase(repository: repository)
        
        try await repository.add(ShoppingItem(name: "Item", quantity: 1, note: nil))
        // Verify the item was added
        await #expect(repository.storage.count == 1)
        
        let item = await repository.storage.first(where: { $0.name == "Item" })
        
        if let item {
            try await useCase.execute(item: item)
        }
        
        // Verify the item was deleted
        await #expect(repository.storage.count == 0)
    }
    
    @Test("Sync retries 3 times and fails with exponential backoff")
    func testRetriesAndFails() async throws {
        let context = try InMemoryModelContainer.create()
        
        // Insert a dummy item that needs sync
        let item = ShoppingItem(name: "Sync Item", quantity: 1, note: "Needs sync")
        item.needsSync = true
        context.insert(item)
        try context.save()
        
        // Use failing mock remote data source
        let failingRemote = FailingShoppingListRemoteDataSource()
        let syncUseCase = BackgroundSyncUseCase(context: context, remote: failingRemote)
        let startTime = Date()
        
        do {
            try await syncUseCase.execute()
            XCTFail("Expected sync to fail but it succeeded")
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            
            // Should retry 3 times
            await #expect(failingRemote.syncCallCount == 3)
            
            // Expect duration should be >= 1s + 2s = 3s total (before final fail)
            #expect(duration >= 2.5, "Expected backoff delay to occur")
        }
    }
}
