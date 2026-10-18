# Revision 2 QA — 2026-10-18

Revision 2 restores upstream inline controls and introduces actual parent-tab → child-tab pages. The rejected dashboard layout is not used.

## Verified offline

- NumberFormat: 20 display cases plus parsing, bounds and precision assertions passed.
- TabTree: 12 routing cases passed.
- Release build succeeds with Darklua 0.19.0 and the pinned upstream icons submodule.
- All 78 source/release/example/runtime-test Lua files compile with Luau.
- Element Section.lua, HStack.lua and Group.lua are byte-identical to upstream. Sidebar Section adds an optional HeaderSize; its original default stays 42.
- Original window min/max defaults (560×350 / 850×560) retained.

## Verified in Roblox through MCP

Client 00770cfb-0e7e-4b12-a2cc-b81c918995d5, Just a baseplate, viewport 2560×1440.

`tests/ForkRuntime.lua`: **59 assertions passed**:

- Real nested pages, parent resolves to first/remembered child, separate Player/World containers.
- Ordinary tabs unchanged, direct child selection opens ancestors, parent GUI-signal clicks collapse/expand.
- Expansion and collapse both have intermediate heights; rapid reversal finishes expanded without an old completion callback hiding it.
- LockOffscreen keeps rendered bounds inside all four corners at UIScale 0.75 and 1.0. Disabling permits offscreen placement; enabling rescues it.
- Compact fields, numeric callbacks, input parsing, invalid-input restoration, bounds, NaN, equal ranges and fractional precision.
- Stable drag track geometry at six positions; no digit-driven width changes.
- Long 283.78m text fits its fixed field, stays separated from a 100px track; requested 10px content inset.
- Original inline text/control separation at 560×350, 740×520 and 850×560.

These assertions use synthetic GUI signals and programmatic placement; they are not a physical device matrix. A separate VirtualInputManager topbar drag also completed and hit the top screen boundary (Y=0). Actual OS screenshots were captured and visually inspected: original inline layout, nested child indentation and distinct Player/World content.

## Limits

No mobile/touch hardware matrix, extreme custom text-width stress test or viewport-resize device matrix. For an explicitly oversized window, resize/scale it to fit; position locking does not silently change your configured dimensions. No claim that unrelated upstream issues have all been eliminated.
