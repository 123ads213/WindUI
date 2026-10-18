# Revision 2 QA status

The previous dashboard-style layout and sidebar-section interpretation were rejected. Revision 2 restores upstream inline elements and introduces actual parent-tab → child-tab pages.

## Verified offline

- NumberFormat: 20 display cases plus parsing, bounds and precision assertions passed.
- TabTree: 12 routing cases passed (first child, remembered child, locked child, locked ancestor, nested branch, stale selection, ordinary tab).
- Release build succeeds with Darklua 0.19.0 and the pinned upstream icons submodule.
- Changed modules, distribution, example and runtime test compile with Luau.
- `Section.lua`, `HStack.lua` and `Group.lua` were restored exactly from upstream.

## Not yet verified for this revision

Roblox runtime layout, real screenshots, actual clicks and numeric drag regression: the MCP server reported no connected Roblox client during revision 2 work. The old revision's 34 live assertions and screenshots are NOT evidence that this revision has passed. Reconnect using connector.luau, run the new example, then run tests/ForkRuntime.lua and inspect screenshots before marking this revision visually verified.
