# BookApp

A personal iOS app to browse and save books from the Google Books API. I built this to play with technologies I wanted to understand better — TCA, Swift 6 concurrency, modular SPM architecture — not to ship a product. It will never be fully finished, and that's fine.

## Demo

<img src="docs/demo.gif" width="320" alt="BookApp demo">

## What it does

- Search books via the Google Books API
- Browse by category (Fiction, Mystery, Non-Fiction…)
- Infinite scroll with pagination
- Save favourites to a local shelf (persisted with Realm)
- Light and dark mode

## Technologies

| | |
|---|---|
| **UI** | SwiftUI, iOS 26 |
| **Architecture** | [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) 1.26.2 |
| **Concurrency** | Swift 6, strict concurrency |
| **Persistence** | RealmSwift |
| **Networking** | Custom `NetworkClient` SPM package (URLSession) |
| **Modularisation** | Swift Package Manager — see [docs/modularization.md](docs/modularization.md) |
| **Testing** | Swift Testing, SnapshotTesting |
| **Logging** | os.Logger |

## Running locally

The app uses the Google Books API. Without a key it still runs on Google's anonymous quota (rate-limited). With a key it works properly.

1. Clone the repo and open **`BookApp.xcworkspace`** (not the `.xcodeproj`)
2. Copy the example config: `cp Config/Secrets.example.xcconfig Config/Secrets.xcconfig`
3. Get a free API key at [console.cloud.google.com](https://console.cloud.google.com/apis/credentials) with the Books API enabled
4. Paste it into `Config/Secrets.xcconfig` on the `GOOGLE_BOOKS_API_KEY =` line
5. Build and run

`Secrets.xcconfig` is git-ignored so the key stays local. The key in git history is rotated and no longer valid.

## Architecture

Two SPM packages inside one workspace:

- **`NetworkClient`** — generic HTTP client, no Google Books knowledge
- **`Modules`** — everything app-specific: features, client interfaces, live implementations, models, design system

Features depend only on client interfaces. Live implementations (Realm, networking) are injected at startup in `BookAppApp`. The compiler enforces the boundaries. See [docs/architecture.md](docs/architecture.md).

## What I'd work on next

Things I know are missing or worth improving, roughly in order:

- **Accessibility** — Dynamic Type text styles instead of fixed sizes, VoiceOver labels for book cards
- **Error messages** — map network errors to readable copy instead of showing raw error strings
- **Replace Realm with SQLiteData** — the current Realm setup works but I want to try Point-Free's SQLiteData to see how it compares, and to prove that only `FavoritesClientLive` would need to change
- **"All" and "Popular" show the same results** — they query the same thing; they should use different `orderBy` parameters or one should be removed
- **Image caching** — covers re-download every time you scroll back up
- **XCUITest smoke test** — one end-to-end test that opens the app and taps through the main flow
- **Reading shelves** — Want to read / Reading / Read, the obvious next feature
