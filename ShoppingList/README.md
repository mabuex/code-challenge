---

## 📄 `README.md`

```markdown
# 🛒 ShoppingList Feature Module

A modular, offline-first SwiftUI feature for managing a shopping list — designed for integration into a larger **super-app** architecture.

Built with clean architecture principles, local persistence via **SwiftData**, and a background sync mechanism using **BackgroundTasks** and a mock JSON API.

---

## ✅ Features

- Add, edit, and delete shopping items
- Mark items as "bought" (hidden by default)
- Filter by bought/not bought
- Search by name or note
- Sort by created or modified date (ascending/descending)
- Fully functional offline
- Background sync with retry + exponential backoff
- Modular Swift Package design
- Unit + UI tests using modern Swift macros

---

## 🏗 Architecture

- **SwiftUI + SwiftData**
- **Clean Architecture**
    - Domain, Data, Presentation layers
- **Repository pattern** for abstraction
- **Dependency Injection** using manual factory (DI file)

---

## 📦 Tech Stack

| Layer         | Technology      |
|---------------|-----------------|
| UI            | SwiftUI         |
| State Mgmt    | ViewModel       |
| Persistence   | SwiftData       |
| Sync          | BackgroundTasks |
| Architecture  | Clean Architecture |
| Testing       | Swift Testing Macros (`#Test`, `#expect`) |

---

## 🧪 Tests

Run all tests:

```bash
swift test
