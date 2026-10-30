# Why the project is split into packages and modules

I wanted to understand how modular architecture actually feels in practice — not just read about it, but build it, hit the Xcode quirks, and make the tradeoffs concrete.

## The split

**`NetworkClient` is a standalone package** because it's generic HTTP infrastructure with no knowledge of Google Books. Base URL, query items and headers come from a configuration object passed at startup, so it could plug into a different app without changes.

**Everything else lives in a single `Modules` package** with one target per responsibility. One manifest, one set of platform and Swift settings, one place to see the whole dependency graph.

**Clients are split into an interface and a live implementation** (`BooksClient` / `BooksClientLive`, `FavoritesClient` / `FavoritesClientLive`). Features depend only on interfaces:
- The compiler prevents a feature from importing Realm directly. No convention required.
- Tests and previews work without a real database or network.
- Replacing Realm only touches `FavoritesClientLive`; features and their tests are unaffected.

**`BookAppApp` is the only place that picks live clients.** Everything else declares what it needs via `@Dependency`.

## Alternatives I considered

**One big target** — simplest, and fine for a small app. But nothing stops a feature from importing Realm, previews always wire in everything, and you can't test a feature without the real network.

**One package per module** — the strongest isolation. But each package needs its own manifest, test plan and scheme entry. That overhead is only worth it for code that's genuinely reused across apps. Today that's just `NetworkClient`.

**Everything including `NetworkClient` in `Modules`** — one package fewer, but it blurs the line between generic infrastructure and app-specific code, and makes it easy for Google Books details to creep into the network layer.

## Tradeoffs I'd own

- More `public` and `package` boilerplate than a single target. Not free.
- All modules in `Modules` share one set of platforms and Swift settings. A real multi-app monorepo would need more control here.
- More structure than a two-screen app strictly needs. Worth it for what it taught me.
- Xcode has quirks: always open the workspace, clean after changing public API, never link test-support products into the app-hosted test target or Xcode promotes the package to a dynamic framework and loses coverage.
