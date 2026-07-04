//
//  MockShoppingListRepository.swift
//  ShoppingList
//
//  Created by Marcus Buexenstein on 8/6/25.
//

import Foundation
@testable import ShoppingList

actor MockShoppingListRepository: ShoppingListRepository {
    var storage: [ShoppingItem] = []
    
    func add(_ item: ShoppingItem) async throws {
        storage.append(item)
    }
    
    func update(_ item: ShoppingItem) async throws {
        if let index = storage.firstIndex(where: { $0.identifier == item.identifier }) {
            storage[index] = item
        }
    }
    
    func delete(_ item: ShoppingItem) async throws {
        storage.removeAll { $0.identifier == item.identifier }
    }
    
    func getAllItems(includeBought: Bool, searchQuery: String?, sortDescending: Bool) async throws -> [ShoppingItem] {
        var reslult = storage
        if !includeBought {
            reslult = reslult.filter { !$0.isBought }
        }
        if let searchQuery, !searchQuery.isEmpty {
            reslult = reslult.filter { $0.name.localizedCaseInsensitiveContains(searchQuery) || $0.note?.localizedCaseInsensitiveContains(searchQuery) ?? false }
        }
        
        return reslult.sorted {
            sortDescending ? $0.updatedAt > $1.updatedAt : $0.updatedAt < $1.updatedAt
        }
    }
}
