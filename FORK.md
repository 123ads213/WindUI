# WindUI Extended

Fork of [WindUI by Footagesus](https://github.com/Footagesus/WindUI), based on upstream 1.6.66 (`d2c9bac5f96f997418d680d19cb759892542e492`). Original MIT license and copyright retained. Not an official Footagesus release.

## Scope

The original WindUI element layout, slider position, buttons, window sizing, sidebar sections and horizontal containers are retained. No layout based on the second reference image is applied. Changes are limited to compact numeric displays, nested tabs, numerical/interaction fixes needed by those features, and curated themes.

## Run

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/123ads213/WindUI/main/ForkExample.lua"))()
```

Library only:

```lua
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/123ads213/WindUI/main/dist/main.lua"))()
```

`ForkExample.lua` demonstrates actual nested pages and ordinary upstream-positioned elements, not a custom dashboard. Re-running it destroys the previous demo before loading a fresh library. Upstream launchers are retained as upstream examples; use `ForkExample.lua` for this fork's features.

## Actual subtabs

```lua
local Visuals = Window:Tab({ Title = "Visuals", Icon = "image" })
local Player = Visuals:Tab({ Title = "Player", Icon = "user" })
local World = Visuals:Tab({ Title = "World", Icon = "globe" })

Player:Slider({
    Title = "Distance",
    Value = { Min = 0, Max = 1000000, Default = 500000 },
    Callback = function(number) print(number) end,
})
World:Toggle({ Title = "Shadows", Value = true, Callback = function(value) end })
```

- Click **Visuals**: its child buttons expand and the first unlocked child (**Player**) opens.
- Click **World**: World gets its own separate content page.
- Click Visuals again to collapse; reopening restores its last selected child.
- `Visuals:SubTab({...})` is an alias for `Visuals:Tab({...})`.
- `:Select()` / `Window:SelectTab(index)` resolve parent tabs to the last/first unlocked child. Selecting a child directly opens its ancestors.
- `:Expand()` / `:Collapse()` control the child list without changing content.
- Ordinary tabs and `Window:Section` keep their upstream behavior. Child tabs can also have children; locked branches are skipped.

## Compact numeric displays

Sliders (including their floating tooltips) and ProgressBar Value/Fraction modes show `500k`, `1.25m`, `1b`, `1t`, `qa`, `qi`, `sx`, `sp`, `oc`, `no`, `dc`. Values from 1e36 use scientific notation.

- Display formatting only: callbacks, `:Get()` and stored values remain numbers.
- `Compact = false` opts out; `Decimals = 2` controls abbreviated text, not numeric step precision.
- Focus the number to edit its full value. Plain values, `500k`, `1.25m` and scientific notation are accepted; invalid text restores the previous value.
- `Format = function(number) return ... end` overrides slider text and tooltip. ProgressBar keeps its existing Format signature.
- `WindUI.NumberFormat.Format(number, options)` is available for custom counters. User-authored text is not automatically converted.
- Sliders retain upstream inline positioning and `Width` (default 130). The fixed `ValueWidth` (default 48) prevents text changes from moving the track. Use a larger Width/ValueWidth for long custom formats or full precision readouts.
- Drag geometry is stable while digits/suffixes change; drag updates are not repeatedly tweened. Connections and scroll lock are cleaned on release, lock and destruction.
- Added `:Get()` and `:SetRange(min,max)`. Non-finite values are ignored; reversed/equal bounds are handled. Fractional callbacks are not truncated to two decimals.
- Roblox doubles cannot represent every integer above 2^53.

## Themes

Dark's palette is unchanged. Light is tuned, with five alternatives: Ocean, Forest, Ember, Orchid and Paper. Old near-duplicate upstream theme names were deliberately removed; update saved configurations referencing them. Custom themes via `AddTheme` still work.

## Build / tests

```sh
git clone --recurse-submodules https://github.com/123ads213/WindUI.git
cd WindUI
# Install Luau CLI and Darklua.
npm test
npm run build
```

- `tests/NumberFormat.luau`: standalone numeric formatting/parsing/bounds tests.
- `tests/TabTree.luau`: standalone nested selection routing tests.
- `tests/ForkRuntime.lua`: run after ForkExample inside Roblox; tests parent/child clicks, content-page isolation, selection memory, numeric input/dragging and upstream window limits. These are synthetic GUI-signal tests, not a physical input/device matrix.

See [current QA status](docs/fork/QA.md). Screenshots of the rejected custom-layout version have been removed rather than presented as evidence for this revision.
