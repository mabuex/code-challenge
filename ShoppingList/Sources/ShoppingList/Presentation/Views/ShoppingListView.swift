//
//  ShoppingListView.swift
//  ShoppingList
//
//  Created by Marcus Buexenstein on 8/6/25.
//


import SwiftUI
import SwiftData

/// Main view displaying the shopping list and handling user interactions.
public struct ShoppingListView: View {
    /// ViewModel managing the shopping list state and business logic.
    @State private var viewModel: ShoppingListViewModel
    
    /// State for new item name input.
    @State private var newName: String = ""
    /// State for new item quantity input.
    @State private var newQuantity: String = ""
    /// State for new item note input.
    @State private var newNote: String = ""
    /// Controls the presentation of the add item sheet.
    @State private var showSheet: Bool = false
    
    /// Initializes the view and injects the ViewModel using dependency injection.
    public init() {
        let context = ShoppingListModelContainer.shared.mainContext
        _viewModel = State(initialValue: ShoppingListDI.makeViewModel(context: context))
    }
    
    /// The main body of the view, containing the UI layout and logic.
    public var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                // Search and filter controls
                VStack(spacing: 12) {
                    HStack {
                        // Search field for filtering items
                        TextField("Search...", text: $viewModel.searchQuery)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: viewModel.searchQuery) {
                                Task { await viewModel.loadItems() }
                            }
                        
                        // Button to toggle sorting order
                        Button {
                            viewModel.sortDescending.toggle()
                            Task { await viewModel.loadItems() }
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                        }
                    }
                    
                    // Toggle to show/hide bought items
                    Toggle("Show Bought Items", isOn: $viewModel.showBoughtItems)
                        .onChange(of: viewModel.showBoughtItems) {
                            Task { await viewModel.loadItems() }
                        }
                }
                .padding()
                
                // List of shopping items
                List {
                    ForEach(viewModel.items, content: listContent)
                }
            }
            .sheet(isPresented: $showSheet, content: sheetContent)
            .toolbar(content: toolbarContent)
            .task {
                // Sync items with remote on first load
                await viewModel.syncItems()
                // Load local items after sync
                await viewModel.loadItems()
            }
        }
    }
    
    /// Toolbar content builder for navigation bar actions.
    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            // Button to manually trigger sync
            Button("Sync", systemImage: "arrow.clockwise") {
                Task {
                    await viewModel.syncItems()
                }
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            // Button to show add item sheet
            Button("Add Item", systemImage: "plus") {
                showSheet.toggle()
            }
        }
    }
    
    /// View builder for each shopping item row in the list.
    /// - Parameter item: The shopping item to display.
    @ViewBuilder
    func listContent(_ item: ShoppingItem) -> some View {
        HStack(alignment: .center) {
            // Button to toggle bought status
            Button {
                let updated = item
                updated.isBought.toggle()
                Task { await viewModel.updateItem(updated) }
            } label: {
                Image(systemName: item.isBought ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.isBought ? .green : .secondary)
                    .imageScale(.large)
            }
            .buttonStyle(.plain)
            
            // Item name and optional note
            VStack(alignment: .leading) {
                Text(item.name)
                    .strikethrough(item.isBought)
                
                if let note = item.note {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // Indicator if item needs sync
            if item.needsSync {
                Image(systemName: "exclamationmark.arrow.trianglehead.2.clockwise.rotate.90")
                    .foregroundStyle(.orange)
            }
                
            // Item quantity
            Text("x\(item.quantity)")
                .foregroundStyle(.secondary)
            
            // Button to delete item
            Button(role: .destructive) {
                Task {
                    await viewModel.deleteItem(item)
                }
            } label: {
                Image(systemName: "trash")
            }
            .foregroundStyle(.red)
            .buttonStyle(.plain)
        }
    }
    
    /// View builder for the add item sheet content.
    @ViewBuilder
    func sheetContent() -> some View {
        NavigationStack {
            VStack(spacing: 16) {
                Group {
                    // Input for item name
                    TextField("Item name", text: $newName)
                    
                    // Input for item quantity
                    TextField("Quantity", text: $newQuantity)
                        .keyboardType(.numberPad)
                    
                    // Input for optional note
                    TextField("Note (optional)", text: $newNote)
                }
                .textFieldStyle(.roundedBorder)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Add New Item")
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 0) {
                Divider()
                
                // Button to add the new item
                Button {
                    guard let quantity = Int(newQuantity), quantity > 0, !newName.isEmpty else { return }
                    
                    Task {
                        await viewModel.addItem(name: newName, quantity: quantity, note: newNote)
                        newName = ""
                        newQuantity = ""
                        newNote = ""
                        
                        showSheet.toggle()
                    }
                } label: {
                    Label("Add Item", systemImage: "plus")
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.white)
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .background(.ultraThinMaterial)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

/// Preview provider for SwiftUI previews.
#Preview {
    ShoppingListView()
}
