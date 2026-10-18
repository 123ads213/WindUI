# Fork QA — 2026-10-18

Base: upstream WindUI 1.6.66, commit d2c9bac5f96f997418d680d19cb759892542e492.

- Release build: Darklua 0.19.0, icons submodule pinned at 46d30c19ba7bc601d6ec794a48dc3a89568b1eec.
- Offline Luau: 20 compact display cases plus parsing, precision and range assertions passed.
- Syntax: all library modules and the compiled distribution were checked with Luau's compiler; no syntax errors.
- Live Roblox MCP: 34 runtime assertions passed in a connected baseplate client, including synthetic GUI focus/input and touch-style drag signals.
- Tested window sizes: 600x400, 900x740, 1200x900. Description/control vertical separation and positive track width asserted.
- Drag geometry remained fixed across seven positions. Numeric callback values, bounds, locking, exact-range handling and abbreviation parsing were checked.
- Real Windows Roblox screenshots were captured and visually inspected for Dark, Light, Ocean, Forest, Ember, Orchid and Paper. Light's surface contrast was adjusted after its first screenshot.
- Original Dark palette and MIT license preserved.

Limitations: synthetic signals do not establish physical mouse or touchscreen behavior; no exhaustive executor/device matrix or complete accessibility/contrast audit. Save in the example is intentionally a notification-only stub. Classic Inline layout and arbitrary extremely long custom formatting need separate integration tests in consuming scripts.
