# WindUI Extended

Fork of [WindUI by Footagesus](https://github.com/Footagesus/WindUI), based on upstream 1.6.66 (`d2c9bac5f96f997418d680d19cb759892542e492`). Original MIT license and copyright retained. Not an official Footagesus release.

## Scope

The original WindUI element layout, slider position, buttons, window sizing, sidebar sections and horizontal containers are retained. No layout based on the second reference image is applied. Changes are limited to compact numeric displays, nested tabs, numerical/interaction fixes needed by those features, curated themes, optional offscreen locking and animated subtab expansion.

## Run

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/123ads213/WindUI/main/ForkExample.lua"))()
```

Library only:

```lua
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/123ads213/WindUI/main/dist/main.lua"))()
```

`ForkExample.lua` demonstrates actual nested pages and ordinary upstream-positioned elements, not a custom dashboard. Re-running it destroys the previous demo before loading a fresh library. The example pins its tested distribution commit so Roblox HttpGet caching cannot mix a new example with an old library. Upstream launchers are retained as upstream examples; use `ForkExample.lua` for this fork's features.

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
- `:Expand()` / `:Collapse()` control the child list without changing content. Height and chevron rotation animate over 0.24 seconds; rapid reversals cancel the previous transition.
- Ordinary tabs and `Window:Section` keep their upstream behavior. Child tabs can also have children; locked branches are skipped.

## Lock Offscreen

```lua
local Window = WindUI:CreateWindow({
    Title = "My window",
    Size = UDim2.fromOffset(740, 520),
    LockOffscreen = true,
})
Window:SetLockOffscreen(false) -- runtime toggle
Window:SetLockOffscreen(true)  -- also brings an offscreen window back
Window:SetPosition(UDim2.fromScale(.5, .5))
```

Opt-in (default false) to preserve upstream behavior. The example enables it and includes a **General → Lock Offscreen** toggle. Dragging stops at the Roblox viewport edges, using the actual rendered window size and UIScale. Resizing and viewport changes re-clamp the position as well. This constrains the WindUI window, not the operating-system Roblox window. A manually configured window larger than the viewport must be resized/scaled to fit; locking its position does not override your chosen size.

## Compact numeric displays

Sliders (including their floating tooltips) and ProgressBar Value/Fraction modes show `500k`, `1.25m`, `1b`, `1t`, `qa`, `qi`, `sx`, `sp`, `oc`, `no`, `dc`. Values from 1e36 use scientific notation.

- Display formatting only: callbacks, `:Get()` and stored values remain numbers.
- `Compact = false` opts out; `Decimals = 2` controls abbreviated text, not numeric step precision.
- Focus the number to edit its full value. Plain values, `500k`, `1.25m` and scientific notation are accepted; invalid text restores the previous value.
- `Format = function(number) return ... end` overrides slider text and tooltip. ProgressBar keeps its existing Format signature.
- `WindUI.NumberFormat.Format(number, options)` is available for custom counters. User-authored text is not automatically converted.
- Sliders retain upstream inline positioning and `Width` (compact default 184; Compact=false keeps 130). The fixed `ValueWidth` (compact default 72; otherwise 48) prevents text changes from moving the track. Use a larger Width/ValueWidth for long custom formats or full precision readouts.
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

See [current QA status](docs/fork/QA.md). The screenshots below are actual captures from revision 2, not the rejected dashboard layout.

![Original inline controls and real nested tabs](docs/fork/Player-Dark.jpg)

![Separate World page](docs/fork/World-Dark.jpg)


## Requested spacing adjustments

The example sets `ContentPaddingTop = 10` in CreateWindow (upstream default remains 20 for a panel background), and `HeaderSize = 28` for COMMON (section default remains 42). You can use these explicit settings in your own windows without changing other upstream spacing. The compact slider reserves a fixed 72-pixel value slot plus 12-pixel gap and a 100-pixel track by default; its geometry never changes with the current value.

## Revision 3 regressions

- Decimal snapping is normalized to the precision implied by Min and Step, before display/callbacks. Negative minima no longer expose binary tails such as `-0.0232599999999999` for step `0.00001`.
- The example registers its window as soon as it is created, keeps a pending-library handle if setup fails, and gives reruns a generation ID. A newer invocation wins instead of leaving overlapping demos.
- Old stranded example roots are removed only when marked as this example or identified by the exact `Footagesus · Extended fork` author label. Unrelated WindUI windows are not blanket-deleted.
- `tests/ForkRerun.lua`: set `getgenv().__WindUIForkBuild` to dist/main.lua source and `getgenv().__WindUIForkExampleSource` to ForkExample.lua source, then run it. This is an intentionally destructive **demo-only** QA test: three reruns, a deliberate setup failure/recovery, and two concurrent starts. Results are stored in `__WindUIForkReruns`.

![Clean negative precision at the top viewport edge](docs/fork/Precision-TopEdge.jpg)

![Full capture showing a single demo window](docs/fork/TopEdge-Full.jpg)
