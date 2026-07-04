//
//  ShoppingListChallengeApp.swift
//  ShoppingListChallenge
//
//  Created by Marcus Buexenstein on 8/6/25.
//

import SwiftUI
import ShoppingList
import BackgroundTasks

/// Main application entry point for the Shopping List Challenge.
/// Handles app lifecycle, dependency injection, and background sync scheduling.
@main
struct ShoppingListChallengeApp: App {
    /// Tracks the current scene phase (active, background, etc.).
    @Environment(\.scenePhase) private var phase
    
    /// Identifier for the background sync task.
    static let backgroundTaskIdentifier = "com.challenge.shoppinglist.sync"
    
    /// Registers the background task with the system.
    /// This is done once using a static property to ensure registration occurs only once.
    static let registerBackgroundTask: Void = {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: backgroundTaskIdentifier,
            using: nil
        ) { task in
            guard let appRefreshTask = task as? BGAppRefreshTask else {
                task.setTaskCompleted(success: false)
                return
            }
            handleSync(task: appRefreshTask)
        }
    }()
    
    /// Initializes the app and registers the background task.
    init() {
        Self.registerBackgroundTask
    }

    /// The main scene of the app, displaying the shopping list view.
    var body: some Scene {
        WindowGroup {
            ShoppingListView()
                .modelContainer(ShoppingListModelContainer.shared)
        }
    }
    
    /// Handles the execution of the background sync task.
    /// - Parameter task: The background app refresh task to handle.
    private static func handleSync(task: BGAppRefreshTask) {
        // Schedule the next sync before starting the current one.
        scheduleNextSync()
        
        // Perform the sync operation asynchronously.
        let operation = Task {
            let context = ShoppingListModelContainer.shared.mainContext
            let syncUseCase = ShoppingListDI.makeBackgroundSyncUseCase(context: context)
            
            do {
                try await syncUseCase.execute()
                task.setTaskCompleted(success: true)
            } catch {
                print("🔴 Sync failed: \(error.localizedDescription)")
                task.setTaskCompleted(success: false)
            }
        }
        
        // Handle task expiration by cancelling the operation.
        task.expirationHandler = {
            operation.cancel()
            print("🔴 Background task expired")
        }
    }
    
    /// Schedules the next background sync task with a 15-minute interval.
    private static func scheduleNextSync() {
        let request = BGAppRefreshTaskRequest(identifier: backgroundTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes from now
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("🔴 Failed to schedule sync task: \(error.localizedDescription)")
        }
    }
}
