//
//  ShoppingListRemoteDataSource.swift
//  ShoppingList
//
//  Created by Marcus Buexenstein on 8/6/25.
//

import Foundation

/// Protocol defining remote data operations for shopping list items.
/// All methods are asynchronous and actor-isolated for thread safety.
public protocol ShoppingListRemoteDataSource: Sendable {
    /// Asynchronously returns the current store of shopping items.
    var store: [UUID: ShoppingItem] { get async }
    
    /// Fetches shopping items from the remote source.
    func fetch() async throws
    /// Inserts new shopping items to the remote source.
    func insert(items: [ShoppingItem]) async throws
    /// Updates existing shopping items in the remote source.
    func update(items: [ShoppingItem]) async throws
    /// Deletes shopping items from the remote source.
    func delete(items: [ShoppingItem]) async throws
    /// Cleans up resources or performs any necessary cleanup operations.
    func cleanup() async
}

/// Mock implementation of ShoppingListRemoteDataSource for testing.
/// Uses a local JSON file to simulate remote data and API calls.
@MainActor
public final class MockShoppingListRemoteDataSource: ShoppingListRemoteDataSource {
    /// In-memory store of shopping items, keyed by UUID.
    public var store: [UUID: ShoppingItem] = [:]
    private let filename = "mock_shopping_items_store.json"
    
    public init() {}
    
    /// Loads mock data from a JSON file and populates the store.
    public func fetch() async throws {
        await loadStore()
        
        print("📞 API initialized with \(store.count) items.")
        print("-------------------------------------------------")
        print(store.prettyJSONString)
        print("-------------------------------------------------")
    }
    
    /// Simulates inserting items and prints them as pretty JSON.
    public func insert(items: [ShoppingItem]) async throws {
        for item in items {
            store[item.identifier] = item
        }
    
        print("📞 API insert called for \(items.count) items inserted.")
        print("-------------------------------------------------")
        print(items.prettyJSONString)
        print("-------------------------------------------------")
    }
    
    /// Simulates updating items and prints them as pretty JSON.
    public func update(items: [ShoppingItem]) async throws {
        for item in items {
            store[item.identifier] = item
        }
       
        print("📞 API update called for \(items.count) items updated.")
        print("-------------------------------------------------")
        print(items.prettyJSONString)
        print("-------------------------------------------------")
    }
    
    /// Simulates deleting items and prints them as pretty JSON.
    public func delete(items: [ShoppingItem]) async throws {
        for item in items {
            store.removeValue(forKey: item.identifier)
        }
        
        print("📞 API delete called for \(items.count) items deleted.")
        print("-------------------------------------------------")
        print(items.prettyJSONString)
        print("-------------------------------------------------")
    }
    
    /// Cleans up resources by saving the current store to disk.
    public func cleanup() async {
        try? await saveStore()
    }
    
    // MARK: - Persistence
    private func storeURL() -> URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent(filename)
    }
    
    private func loadStore() async {
        let url = storeURL()
        guard let data = try? Data(contentsOf: url) else { return }
        
        if let decoded = try? JSONDecoder().decode([ShoppingItem].self, from: data) {
            store = Dictionary(uniqueKeysWithValues: decoded.map { ($0.identifier, $0) })
        }
    }
    
    private func saveStore() async throws {
        let items = store.values.map { $0 } as? [ShoppingItem] ?? []
        let data = try JSONEncoder().encode(items)
        try data.write(to: storeURL(), options: .atomic)
    }
}

/// Extension to pretty-print any Encodable object as JSON for debugging.
fileprivate extension Encodable {
    /// Returns a pretty-printed JSON string representation of the object.
    var prettyJSONString: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let jsonData = try? encoder.encode(self)
        guard let jsonData else {
            return "Failed to prettify JSON."
        }
        
        return String(data: jsonData, encoding: .utf8)!
    }
}
