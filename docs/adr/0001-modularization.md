# 1. Modularize with a hybrid of packages and modules

- **Status:** Accepted
- **Date:** 2026-10-29

## Context

BookApp started as one app target holding both features and a `BooksRepository`, plus three local packages (`NetworkClient`, `BookAPIClient`, `SharedUI`). The app is meant to grow (shelves, richer search, more screens), so the architecture has to scale without slowing development down.

The original layout had concrete problems:

- `BooksRepository` mixed HTTP calls, Realm persistence and API-to-domain mapping, and every feature depended on all of it.
- Features could not be previewed or tested without the real network and database.
- Nothing stopped a feature from importing Realm or networking code directly.
- `NetworkClient` was meant to be generic, but hard-coded the Google Books host and API-key parameter.

## Decision

**Package boundaries are for reuse; module boundaries are for isolation.**

- **`NetworkClient` stays a standalone package.** It is generic HTTP infrastructure with no knowledge of Google Books. The base URL and default query items and headers come from a `NetworkClientConfiguration`, so it could be versioned and reused by another app.
- **Everything app-specific lives in one `Modules` package,** with one target per feature, client interface, client implementation, the Google Books API, the design system and shared models.
- **Clients are split into an interface and a live implementation** (`BooksClient` / `BooksClientLive`, `FavoritesClient` / `FavoritesClientLive`), using TCA's `@DependencyClient`. Interfaces provide test and preview values.
- **The app target is the composition root.** `BookAppApp` is the only place that chooses live clients.
- **Dependency rules:**
  - Features depend only on client interfaces, `Models` and `SharedUI`.
  - A parent feature may depend on a child feature it presents; no sibling or cyclic feature dependencies.
  - Only `…Live` modules import Realm or networking code.
- **Access levels:** `public` for API used by the app, `package` for code shared between modules of `Modules`, `internal` otherwise. Only modules the app imports are package products.
- **Tooling:**
  - `BookApp.xcworkspace` contains the app project and both packages, because a plain project can't run local packages' test targets.
  - `BookApp.xctestplan` runs every test target with coverage.
  - The workspace's `Package.resolved` is the single source of dependency versions.

## Consequences

**Positive**

- Boundaries are enforced by the compiler, not by convention.
- Each feature builds, tests and previews on its own, without network, database or API key.
- Replacing Realm only touches `FavoritesClientLive`; features and their tests are unaffected.
- Adding a feature is one new target in one manifest, and `Modules/Package.swift` documents the whole dependency graph.

**Negative**

- More files and `public` or `package` boilerplate than a single target.
- All modules in `Modules` share one set of platforms and Swift settings.
- More structure than a two-screen app strictly needs; this is accepted because the app is built to grow and to demonstrate the pattern.
- Xcode quirks to remember:
  - Open the workspace, not the project.
  - Clean the build folder after changing a package's public API if the build reports stale types.
  - Never link a package's test-support product into the app-hosted `BookAppTests`. Xcode then turns the shared package into a dynamic framework and its coverage is lost.

## Alternatives considered

1. **Single app target with folders.** Simplest, but boundaries are only conventions, builds and previews always include everything, and features can't be tested in isolation.
2. **One package per module.** Strongest separation, but every feature needs its own manifest plus workspace, test plan and scheme entries. Worth it only for code that is genuinely reused, which today is just `NetworkClient`.
3. **Everything, including `NetworkClient`, in `Modules`.** One package fewer, but it hides that `NetworkClient` is meant to be reusable and makes it easy for app-specific code to creep into it.
