---

## 📄 `DESIGN_DOC.md`

```markdown
# 📄 Design Document – ShoppingList Feature

## ✨ Summary

This document outlines the design decisions behind the modular **ShoppingList** Swift Package, built to integrate into a larger super-app. It focuses on maintainability, offline support, and clear architectural boundaries.

---

## 🧱 Architecture Overview

The feature follows **Clean Architecture**, with three core layers:

- **Domain**: Use cases, repositories, models
- **Data**: SwiftData-backed repository, mock remote sync
- **Presentation**: SwiftUI views and ViewModels

The design encourages testability, scalability, and isolation between layers.

---

## 🔁 Sync Strategy

- Local changes are stored via **SwiftData** and marked with `needsSync`
- Background sync runs using `BGAppRefreshTask`
- Implements **last-write-wins** using `updatedAt` timestamps
- Retries up to 3x with **exponential backoff** (1s, 2s, 4s)

---

## 💾 Persistence

- Uses **SwiftData** with the `@Model` macro
- Data is stored locally and designed for full offline support
- Sync reconciles local vs remote changes

---

## ✅ Testing

- Unit tests using **Swift Testing macros** (`#Test`, `#expect`)
- Includes:
    - ViewModel tests
    - Use case tests
    - Retry logic with delay verification
- No external mocking frameworks

---

## 🧩 Modularity

- Packaged as a Swift Package (`ShoppingList`)
- Exposes only `ShoppingListView` to the outside world
- Easily pluggable into an app via DI + `.modelContainer(...)`

---

## ❌ Rejected Alternatives

### 1. Realm instead of SwiftData
- ❌ Rejected because SwiftData is native, cleaner for Apple platforms, and simplifies model definitions via `@Model`.

### 2. Combine + Timer for sync
- ❌ Rejected due to battery implications and complexity.
- `BackgroundTasks` is more efficient and iOS-native for background work.

---

## 📦 Interfaces

- **Exposed**: `ShoppingListView`, ready to embed
- **Internal**: UseCases, ViewModels, SwiftData logic

---

## ✅ Clean Code Practices

- Separation of concerns
- Small, composable use cases
- Testable logic without UI
- Minimal coupling
