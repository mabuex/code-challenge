//
//  ShoppingListDI.swift
//  ShoppingList
//
//  Created by Marcus Buexenstein on 8/6/25.
//

import Foundation
import SwiftData

/// Dependency Injection container for the ShoppingList app.
/// Provides factory methods to create repositories, view models, and use cases.
@MainActor
public struct ShoppingListDI {
    /// Creates a ShoppingListRepository using the provided ModelContext.
    /// - Parameter context: The SwiftData context for persistence.
    /// - Returns: An instance of ShoppingListRepository.
    public static func makeRepository(context: ModelContext) -> ShoppingListRepository {
        ShoppingListRepositoryImpl(context: context)
    }
    
    /// Creates a ShoppingListViewModel with all required use cases.
    /// - Parameter context: The SwiftData context for persistence.
    /// - Returns: An instance of ShoppingListViewModel.
    public static func makeViewModel(context: ModelContext) -> ShoppingListViewModel {
        // Create repository and use cases.
        let repository = makeRepository(context: context)
        let fetchItemUseCase = FetchItemsUseCase(repository: repository)
        let addItemUseCase = AddItemUseCase(repository: repository)
        let updateItemUseCase = UpdateItemUseCase(repository: repository)
        let deleteItemUseCase = DeleteItemUseCase(repository: repository)
        let backgroundSyncUseCase = makeBackgroundSyncUseCase(context: context)
        
        // Inject dependencies into the view model.
        return ShoppingListViewModel(
            fetchItemsUseCase: fetchItemUseCase,
            addItemsUseCase: addItemUseCase,
            updateItemUseCase: updateItemUseCase,
            deleteItemUseCase: deleteItemUseCase,
            backgroundSyncUseCase: backgroundSyncUseCase
        )
    }
    
    /// Creates a BackgroundSyncUseCase with a mock remote data source.
    /// - Parameter context: The SwiftData context for persistence.
    /// - Returns: An instance of BackgroundSyncUseCase.
    public static func makeBackgroundSyncUseCase(context: ModelContext) -> BackgroundSyncUseCase {
        let remote = MockShoppingListRemoteDataSource()
        return BackgroundSyncUseCase(context: context, remote: remote)
    }
}
