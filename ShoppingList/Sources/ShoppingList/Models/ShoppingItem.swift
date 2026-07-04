//
//  ShoppingItem.swift
//  ShoppingList
//
//  Created by Marcus Buexenstein on 8/6/25.
//

import Foundation
import SwiftData

/// Model representing a shopping item in the shopping list.
/// Conforms to Identifiable, Hashable, Codable, and Sendable for use in SwiftData and concurrency.
@Model
public final class ShoppingItem: Identifiable, Hashable, Codable, @unchecked Sendable {
    /// Coding keys for encoding and decoding.
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case quantity
        case note
        case isBought
        case createdAt
        case updatedAt
    }
    
    /// Unique identifier for the shopping item.
    @Attribute(.unique)
    public var identifier: UUID
    /// Name of the shopping item.
    public var name: String
    /// Quantity of the item.
    public var quantity: Int
    /// Optional note for the item.
    public var note: String?
    /// Flag indicating if the item has been bought.
    public var isBought: Bool
    /// Date when the item was created.
    public var createdAt: Date
    /// Date when the item was last updated.
    public var updatedAt: Date
    
    /// Flag indicating if the item needs to be synchronized with a remote source.
    public var needsSync: Bool = true
    /// Soft delete flag for marking the item as deleted.
    public var isDeleted: Bool = false
    
    /// Initializes a new ShoppingItem.
    /// - Parameters:
    ///   - id: Unique identifier (default: new UUID).
    ///   - name: Name of the item.
    ///   - quantity: Quantity (default: 1).
    ///   - note: Optional note.
    ///   - isBought: Whether the item is bought (default: false).
    ///   - createdAt: Creation date (default: now).
    ///   - updatedAt: Last updated date (default: now).
    public init(
        id: UUID = .init(),
        name: String,
        quantity: Int = 1,
        note: String? = nil,
        isBought: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.identifier = id
        self.name = name
        self.quantity = quantity
        self.note = note
        self.isBought = isBought
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    /// Decodes a ShoppingItem from a decoder.
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        identifier = try container.decode(UUID.self, forKey: .identifier)
        name = try container.decode(String.self, forKey: .name)
        quantity = try container.decode(Int.self, forKey: .quantity)
        note = try container.decodeIfPresent(String.self, forKey: .note)
        isBought = try container.decode(Bool.self, forKey: .isBought)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }
    
    /// Encodes the ShoppingItem to an encoder.
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(identifier, forKey: .identifier)
        try container.encode(name, forKey: .name)
        try container.encode(quantity, forKey: .quantity)
        try container.encodeIfPresent(note, forKey: .note)
        try container.encode(isBought, forKey: .isBought)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
}
