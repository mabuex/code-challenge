//
//  FailingShoppingListRemoteDataSource.swift
//  ShoppingList
//
//  Created by Marcus Buexenstein on 8/6/25.
//

import Foundation
@testable import ShoppingList

actor FailingShoppingListRemoteDataSource: ShoppingListRemoteDataSource {
    func cleanup() async {}
    
    var store: [UUID : ShoppingItem] = [:]
    
    func fetch() async throws {}
    
    func insert(items: [ShoppingItem]) async throws {}
    
    func update(items: [ShoppingItem]) async throws {}
    
    func delete(items: [ShoppingItem]) async throws {
        syncCallCount += 1
    }
    
    private(set) var syncCallCount = 0
}
