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

These assertions use synthetic GUI signals and programmatic placement; they are not a physical device matrix. A topbar drag was separately verified with synthetic touch signals: dragging toward Y=-5000 stopped at Y=0 and released cleanly. A later VirtualInputManager attempt did not reliably begin a drag and is not counted as evidence. Actual OS screenshots were captured and visually inspected: original inline layout, nested child indentation and distinct Player/World content.

## Limits

No mobile/touch hardware matrix, extreme custom text-width stress test or viewport-resize device matrix. For an explicitly oversized window, resize/scale it to fit; position locking does not silently change your configured dimensions. No claim that unrelated upstream issues have all been eliminated.

## Revision 3 follow-up — decimal tails / stranded demo

- Reproduced the user's exact value live: the old field contained `-0.0232599999999999` while Step was 0.00001.
- Confirmed two separate WindUI roots: one current at Y=0, one stranded old example at Y=1184. This was not the current window crossing the top boundary.
- Added 2001 signed lattice checks plus negative-minimum/scientific-step regressions offline.
- Runtime regression suite: **65 assertions passed**, including clean negative display, focused edit text, numeric callback at -0.02326, and actual drag-handler start/top-boundary/release signals.
- Separate rerun suite: **7 assertions passed**. Three repeated starts, a controlled setup failure with recoverable handle, and concurrent invocations all settle to one demo root.
- The new cleanup removed the already stranded older example; one WindUI demo root remains.

All 79 source/release/example/runtime-test Lua files compile in this follow-up. `Precision-TopEdge.jpg` and `TopEdge-Full.jpg` are actual OS captures after the synthetic drag: clean -0.02326, one demo at the top client boundary. The native Roblox title bar visible above the client area is outside WindUI's viewport.
