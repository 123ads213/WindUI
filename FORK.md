# WindUI Extended

Fork of [WindUI by Footagesus](https://github.com/Footagesus/WindUI), based on upstream 1.6.66 (`d2c9bac5f96f997418d680d19cb759892542e492`). Original MIT license and copyright retained. Not an official Footagesus release.

## Scope

The original WindUI element layout, slider position, buttons, window sizing, sidebar sections and horizontal containers are retained. No layout based on the second reference image is applied. Changes are limited to compact numeric displays, nested tabs, numerical/interaction fixes needed by those features, curated themes, optional offscreen locking, animated subtab/section expansion, optional profile preferences, theme-aware notification icons, a compact gradient editor, per-feature hotkeys and optional watermark/keylist overlays.

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

## Revision 4 — real viewport bounds and clean light contours

- LockOffscreen uses both `ScreenGui.AbsolutePosition` and `AbsoluteSize`, not an assumed (0,0) origin. Roblox can report a negative GUI origin (observed Y=-58); top and bottom now use the same rectangle. GUI origin/inset changes trigger re-clamping.
- The native OS/Roblox title bar is not drawn by WindUI and cannot be covered by a ScreenGui. The lock concerns the actual game viewport.
- Light and Paper use `CleanShapes = true`: native UICorner per-corner radii and uniform inner UIStroke instead of baked fill/glass sprites. Joined first/middle/last row geometry stays intact. No extra GuiObjects are inserted into UIListLayout.
- Dark and the other dark palettes keep their existing shape sprites. All themes use a clean native resting toggle thumb; the oversized glass rim is hidden, while the drag-only glass animation is retained.
- Legacy clients without per-corner UICorner properties fall back to the original texture for joined half-corner shapes.
- `tests/ForkVisual.lua` checks theme round trips, original row sizes/layout-child counts, per-corner grouping, theme-color propagation, resting toggles, and real top/bottom bounds.

![Clean Light controls](docs/fork/Light-Clean.jpg)

![True viewport top](docs/fork/Viewport-Top.jpg)

![True viewport bottom](docs/fork/Viewport-Bottom.jpg)

## Tab selection animation

`Window:SelectTab(tab.Index)` and `tab:Select()` use the original WindUI page-slide animation (not a new layout). The duration/easing now match nested expansion: **0.24 seconds, Quad Out**. Repeated selection of the current page does not restart it; rapid switches cancel the previous tween. Click sidebar tabs directly to see page switching. For the separate collapsible Tab Section, use **APPEARANCE** (see below).

## Slider title icon

```lua
Player:Slider({
    Title = "Distance",
    Icon = "ruler", -- or Image = "ruler" (Image takes precedence)
    IconSize = 24, -- or ImageSize = 24
    Value = { Min = 0, Max = 1e9, Default = 500000 },
    Callback = function(value) print(value) end,
})
```

The icon occupies the existing WindUI element-image slot before the title/description; text reserves its width. It is separate from `Icons = { From = ..., To = ... }`, which places endpoint icons by the slider track. Omitting `Icon`/`Image` preserves the existing title layout. This title-icon configuration is supported on Slider; do not assume every other element forwards it.

## Window sizing and revision 5 contours

Window default size, min/max limits, auto-scaling, resize handles and fullscreen sizing code remain upstream behavior. The example still requests 740×520; minimum 560×350 and maximum 850×560 are unchanged. No new auto-size or scale rule was added for theme/animation fixes. LockOffscreen only clamps position to the GUI rectangle.

Ocean, Forest, Ember and Orchid now use the same clean native contour renderer as Light/Paper. Their palettes are unchanged. Dark retains its upstream panel rendering.

## Actual tab sections (revision 6 correction)

A **Tab Section** is the upstream collapsible sidebar group, not the temporary “Tab selection” dropdown from revision 5. The example now puts Themes inside **APPEARANCE**, created with:

```lua
local Appearance = Window:Section({ Title = "APPEARANCE", Opened = true })
local Themes = Appearance:Tab({ Title = "Themes", Icon = "palette" })
Appearance:Close()
Appearance:Open()
```

Click the APPEARANCE header to see its height and chevron animate together: 0.24s, Quad Out, cancellation on rapid reversal. Selecting Themes programmatically also opens its section. Visuals → Player/World remain nested tabs, not this section.

### Title icon alignment

Slider title icons default to **24px**, centred vertically on the full title/description block rather than its upper edge. A title without a description centres the icon on that title alone. `IconSize`/`ImageSize` overrides remain available. The example uses `Icon = "ruler", IconSize = 24`. The normal WindUI title/description spacing and fixed-width right-hand slider remain unchanged.

## Profile footer and preferences

Opt-in, not an alteration to every window:

```lua
local Profile = Window:CreateProfile({
    -- Name / Avatar optional; defaults to local Roblox display name and headshot.
    DaysRemaining = 30,
    Mock = true, -- data is a demo; no mock badge is shown in the UI
    StoreLink = "https://discord.gg/eqAEszZzHj",
    Themes = { "Dark", "Light", "Ocean", "Forest", "Ember", "Orchid", "Paper" },
    History = {
        { Version = "1.0.0", Date = "2026-10-18", Title = "Release",
          Description = "Your update description." },
    },
})
```

- Bottom-left card reserves its own space below the scrolling sidebar. Hover highlights the card and opens a rounded, theme-aware popover. A short leave delay allows moving the pointer from card to menu; click/touch also opens it. Escape closes it.
- **Renew** copies the configured Discord shop link using `setclipboard`/`toclipboard`, then shows a WindUI notification with a clipboard icon. If unavailable/failed, it reports failure instead of claiming success.
- **Menu Scale** changes the actual WindUI UIScale: Auto, 75%, 90%, 100%, 110%, 125%, 150%. Auto shrinks to the current viewport when necessary and never enlarges beyond 100%. Existing upstream resize/min/max behavior is retained. Manual DPI values can intentionally make a window larger than a small viewport; choose Auto or resize in that case.
- **Style** has a right-facing hover hint, no gear, no colour picker. Hover opens a rounded theme selection list to the right while keeping the main menu visible. Clicking a theme applies it immediately. Menu Scale uses the same side-list interaction. Lists flip to the left only when the right viewport edge leaves insufficient room. No Language, ESP Scale, Windows Scale, Units, Safe Mode, Sync, About or Chat items are included.
- **Transparency** is a thumb-free bar before History. Drag its right-hand track from 0 (opaque) to 1 (transparent); the numeric value appears above it only on hover or during dragging. The value controls the window background and theme-tagged panel/element surfaces; text, icons and functional control fills are not group-faded. Theme/hover alpha is preserved with `base + (1-base)*value`. At zero, the theme’s original surface opacity is restored. `Profile:SetTransparency(0.7)` / `Profile:GetTransparency()` are also available.
- The taller profile popover can extend below the WindUI window, but is clamped to the actual viewport. It does not resize the main window.
- **History** shows supplied version/date/title/description entries as a scrolling list. Back returns to the profile menu.
- `Profile:Open()`, `:Close()`, `:ShowPage("Main" | "Scale" | "Style" | "History")`, `:SetSubscription(info)`, `:Destroy()` are available. Creating a new profile destroys the old one. Window destruction cleans up profile connections and its floating selection list.

### Subscription data / FlowAuth integration boundary

This example uses **mock 30 days**; it is not connected to a buyer key and does not claim to authorize a subscription. No FlowAuth production scripts, keys, loaders or delivery settings were changed.

FlowAuth's connected account automation guide was inspected read-only. Its administrative key metadata endpoints (`GET /v1/projects/{project_id}/keys` and `GET /v1/keys/{key_id}`) expose `duration.state`, `duration.remaining_ms`, `duration.is_lifetime` and `duration.evaluated_at` (server Unix milliseconds). Remaining duration is frozen for pending/paused keys. A positive duration does **not** grant access: status/effective_status and pause/revocation checks still matter; runtime authorization remains with the generated FlowAuth loader. Administrative reads are not a client-side authorization API.

A later trusted adapter can pass *display-only* metadata to the UI, without putting an account API token in Luau:

```lua
-- metadata must already have been obtained/validated by your trusted integration.
local duration = metadata.duration
Profile:SetSubscription({
    IsLifetime = duration.is_lifetime,
    State = duration.state, -- pending / active / expired / paused / lifetime
    ExpiresAt = duration.remaining_ms and duration.evaluated_at
        and (duration.evaluated_at + duration.remaining_ms) / 1000 or nil,
})
```

`ExpiresAt` is Unix **seconds** in this UI API; FlowAuth fields above are milliseconds. For a real integration create the profile with `Mock = false`. The precise runtime handoff from the protected loader is deliberately deferred to the later script-integration task, not invented here.

### Final profile styling

The footer has no background at rest in any theme; the rounded highlight fades in only on hover/open. The popover uses the original WindUI Dialog surface (Dark: #1A1A1A), a subdued outline and a 6%-opacity separator. Menu Scale, Style and History use the same compact icon/label/action row style; scale values open a matching hover flyout rather than a large standalone element control or replacement page. Page changes, hover, popover and DPI transitions are animated. The demo/mock badge is intentionally not rendered.

The Distance example additionally uses `IconOffset = Vector2.new(4, -3)` for a subtle right/up adjustment within its reserved slot. Budget demonstrates a wallet icon. `IconOffset`/`ImageOffset` are optional; they affect only the graphic, not the text layout. All built-in profile/notification strings are English. Slider title icons follow the theme by default (set `IconThemed = false` to opt out for full-colour images). Notification icons now follow `NotificationTitle` theme colour and centre vertically on their text block. `Notify({ IconSize = 36, ... })` is supported; Renew uses 36px.


## Original Search (revision 7)

The example enables the built-in WindUI Search above COMMON with `HideSearchBar = false` in `CreateWindow`. This opens upstream's own search dialog and searches tab/element titles and descriptions, including the nested Player/World pages. The search implementation and its appearance are not replaced with a custom field. Omit this option to keep the upstream hidden-by-default setting.


## Smooth dragging and optional cursor (revision 8)

```lua
local Window = WindUI:CreateWindow({
    Title = "My menu",
    DragSmoothness = 0.045, -- seconds; 0 disables smoothing
    CustomCursor = { Enabled = true, Size = 10 }, -- filled white circle, physical pixels
})
Window:SetDragSmoothness(0.06)
Window:SetCustomCursor(true) -- or false, or { Enabled = true, Size = 12 }
Window:SetBackgroundTransparency(0.7) -- includes themed surfaces, not only the root
```

Dragging uses one frame-rate-independent exponential follower rather than repeated overlapping position tweens. Its short release tail settles at the target; programmatic SetPosition, hide, focus loss and destruction cancel stale drag work. LockOffscreen still constrains every rendered position. No size/min/max or resize-handle limits change.

Custom cursor is opt-in (enabled in ForkExample). It is an unoutlined, fully filled white native circle, independent of theme and menu DPI. Only an open, visible, enabled menu on a mouse-capable focused client replaces the native pointer. Closing/hiding/disabling/destroying the menu, disabling the cursor, or losing focus restores the previous MouseIconEnabled state, even when that previous state was false. No OS pointer shape or game input lock is changed.

Revision 7 only faded the window's root background. That left opaque Light/Paper panels over a transparent sidebar. Revision 8 extends opacity to registered theme-tagged window surfaces, including new elements and profile panels; it does not fade notifications or the cursor. At nonzero transparency, nested surfaces still composite normally rather than behaving like a single faded screenshot of the UI.


## Smooth dragging and optional cursor (revision 8)

```lua
local Window = WindUI:CreateWindow({
    Title = "My menu",
    DragSmoothness = 0.045, -- seconds; 0 disables smoothing
    CustomCursor = { Enabled = true, Size = 10 }, -- filled white circle, physical pixels
})
Window:SetDragSmoothness(0.06)
Window:SetCustomCursor(true) -- or false, or { Enabled = true, Size = 12 }
Window:SetBackgroundTransparency(0.7) -- includes themed surfaces, not only the root
```

Dragging uses one frame-rate-independent exponential follower rather than repeated overlapping position tweens. Its short release tail settles at the target; programmatic SetPosition, hide, focus loss and destruction cancel stale drag work. LockOffscreen still constrains every rendered position. No size/min/max or resize-handle limits change.

Custom cursor is opt-in (enabled in ForkExample). It is an unoutlined, fully filled white native circle, independent of theme and menu DPI. Only an open, visible, enabled menu on a mouse-capable focused client replaces the native pointer. Closing/hiding/disabling/destroying the menu, disabling the cursor, or losing focus restores the previous MouseIconEnabled state, even when that previous state was false. No OS pointer shape or game input lock is changed.

Revision 7 only faded the window's root background. That left opaque Light/Paper panels over a transparent sidebar. Revision 8 extends opacity to registered theme-tagged window surfaces, including new elements and profile panels; it does not fade notifications or the cursor. At nonzero transparency, nested surfaces still composite normally rather than behaving like a single faded screenshot of the UI.

## Hover descriptions and feature hotkeys (revision 9)

Keep upstream inline descriptions by default, or move them into themed hover cards:

```lua
local Window = WindUI:CreateWindow({
    Title = "My menu",
    DescriptionMode = "Tooltip", -- default: "Inline"
    -- the rest of your original window options
})
local feature = Player:Toggle({
    Title = "Show players",
    Desc = "Show player overlays. Right-click to configure hotkeys.",
    Flag = "show_players", -- stable, unique config identity
    Value = false,
    Hotkeys = {
        { Key = "K", Mode = "Toggle", Value = true },
        { Key = "L", Mode = "Hold", Value = false },
    },
    Callback = function(enabled)
        -- apply your feature state here
    end,
})
```

`DescMode = "Inline"` / `"Tooltip"` overrides the window setting on one element. `SetDesc()` updates the current description without reintroducing inline text in Tooltip mode. Hover cards have a short delay, title, wrapped description, theme-aware text/surface, soft fade and viewport-aware placement. Existing title icons/layout remain native. For a Paragraph that should remain body text, set `DescMode = "Inline"` explicitly.

### Right-click editor

Boolean Toggles automatically support right-click hotkeys (`Hotkeys = false` disables this on one toggle). The first list contains bindings with a side chevron, **All Hotkeys**, **New Hotkey**, and **Reset**. Hover a binding to open its editor, without replacing the first list. Key captures the next keyboard key or mouse button; Escape cancels, Backspace/Delete unbinds. Mode has Toggle, Hold and Always. Value is an Enabled/Disabled switch. Delete removes only that binding; Reset removes all bindings on that feature. There is no Visible option.

- **Toggle:** first press applies Value, next applies its inverse. `Value = false` therefore disables first, enables second. Repeated key-down events do not retrigger.
- **Hold:** applies Value while held; release or focus loss applies the inverse.
- **Always:** continuously enforces Value (no key needed). If multiple Always bindings conflict, the last one wins. Always takes precedence over key-driven changes; deleting it stops enforcement and exposes any earlier Always binding. With no Always binding, input events apply in registration order.
- Typing in a TextBox, game-processed input, locked features, key capture and open hotkey panels suppress normal activation. Holds still release on key-up. Hidden menu hotkeys continue to work, as feature controls normally should.

The scrollable, closeable **All Hotkeys** panel lists feature title, key, mode and target boolean value. Click a row to edit that binding. `Window:ShowHotkeys()` opens it programmatically. Panels, mode lists and description cards follow all seven themes and menu DPI; positions clamp to the actual viewport. Moving/resizing the viewport or hiding the window dismisses transient UI; deleting a feature unregisters its bindings.

```lua
feature:AddHotkey({Key = Enum.KeyCode.J, Mode = "Toggle", Value = true})
local snapshot = feature:GetHotkeys() -- independent persistent records
feature:SetHotkeys(snapshot)         -- replace every binding on this feature
feature:ResetHotkeys()
feature:OpenHotkeys()                -- at the mouse
Window:ShowHotkeys()
```

### Config compatibility

Use the original config manager with a stable `Flag` (or explicitly `config:Register("id", feature)`). `Save()` writes every binding as `{Key, Mode, Value}` alongside the ordinary element value; `Load()` replaces those bindings, rather than appending duplicates. Runtime press/hold phases are not serialized. Missing hotkey data in an old config preserves code-defined bindings. Existing Slider/Input/Dropdown/Colorpicker values retain their value parser. The example creates `WindUIForkDemoConfig`, with autoload **off**, for manual `:Save()` / `:Load()`; no existing config is silently overwritten.

Nonboolean elements do not receive a meaningless boolean assignment automatically. To opt in on a Slider/Button/etc., pass `HotkeyCallback = function(enabled) ... end` and a `Flag`; implement the feature's boolean action there. These adapters use the same editor and config extension. Revision 10 removes standalone upstream `Tab:Keybind()` and its parser. Migrate old standalone key controls to the per-feature `Hotkeys` editor; old Keybind records are not loaded.


## Gradient color editor and panel polish (revision 10)

```lua
local color = Themes:Colorpicker({
    Title = "Accent",
    Flag = "accent",
    Default = Color3.fromRGB(42, 148, 255),
    Transparency = 0.15, -- 0 opaque; 1 transparent
    AllowGradient = true, -- default; false keeps a solid-only editor
    Callback = function(firstColor, firstTransparency, gradient)
        -- First two arguments retain the solid-color API.
        -- gradient is nil for a solid, or {Rotation, Stops} for multiple colors.
    end,
})
local gradient = Themes:Colorpicker({
    Title = "Gradient",
    Gradient = {
        {Position = 0, Color = Color3.fromRGB(0, 170, 255), Transparency = 0},
        {Position = 1, Color = Color3.fromRGB(196, 92, 255), Transparency = 0.2},
    },
})
local state = gradient:GetValue() -- independent {Rotation, Stops} copy
local colors, transparency, angle = gradient:GetColorSequence()
gradient:SetGradient(state, true) -- true invokes callback
color:Update(Color3.fromRGB(255, 128, 0), 0.25) -- silent solid update
color:Reset() -- restores the construction-time default and invokes callback
```

- Click the rounded color square to open the editor. The square displays the full gradient and per-stop transparency. The checkerboard indicates transparency.
- Top swatches select colors; **+** adds a color (maximum 16). Starting from a solid duplicates its endpoint; later additions interpolate the largest gap. Right-click a top color swatch for Copy, Paste and Delete color. Delete removes the selected color while retaining valid endpoints. Stop positions/rotation can be specified through the API; this release does not include draggable positions or an angle control.
- Saturation/value, hue and opacity edit the selected color. Opacity reads 0–100%, the inverse of the API's Transparency. Hover/click **HEX** to choose HEX, RGB, HSV or HSL from a list anchored directly to that control. Text input accepts all listed formats, including short/long hex with optional alpha, and validates channel ranges.
- The compact editor follows the reference: top swatches, saturation/value map, slim hue/opacity tracks and one input row, with native medium typography, no text border/stroke, and a reset icon. **Copy** always stores the exact selected color and alpha in a shared menu-local clipboard, and also writes the OS clipboard when supported. **Paste** reads the OS clipboard when supported, otherwise pastes the menu-local color immediately across color editors and gradient stops. When neither is available, it defers focus until the context click finishes and selects the text for external Ctrl+V and Enter. Enter explicitly commits the field; duplicate Enter/FocusLost events do not repeat an unchanged callback. Bare HEX is accepted regardless of the currently selected display format. The connected client has clipboard write but no clipboard-read API, so external colors must be pasted into the field with Ctrl+V.
- Save/Load retains every stop, opacity and rotation, while older solid color configs still load. `Export()`/`Import()` expose the serializable representation (hex strings instead of Color3). Invalid updates leave the current value unchanged.
- Popup movement/fades follow the theme and menu scale; viewport edges are clamped. Escape, outside click, focus loss, locking, moving/resizing/hiding the window or switching its page dismiss the color editor. Only one color editor is active at a time.
- Feature/profile popups use subtle native sliced shadows rather than white outlines. Hotkey context opens 6 px from the cursor (clamped at the viewport edges). All Hotkeys uses a dedicated icon-only close button. Main-window shadow disappears at background transparency 1. Sidebar text keeps its theme color after tab selection and theme changes.

Runtime QA: `tests/ForkColors.lua` checks format/alpha round trips, invalid input, 16-stop limits, UI signals, actual disk Save/Load, legacy solid configs, default reset, popup bounds at 0.75/1/1.25 scale, cursor-near hotkeys, and full-transparency shadow. `tests/ForkHotkeys.lua` retains the previous editor/persistence/lifecycle regression coverage. These are synthetic signal/API checks; screenshots are captured separately from the real Roblox window.

Paste regression: `tests/ForkPaste.lua` covers menu-local cross-editor copy/paste with exact alpha, selected-stop isolation, HEX/RGBA auto-detection, visible invalid-input feedback, deferred focus/selection, context dismissal, and actual keyboard Enter events. The test does not overwrite the user’s OS clipboard.

## Watermark and active keylist (revision 11)

```lua
local HUD = Window:CreateHUD({Watermark = true, Keylist = true})
-- Or pass HUD = {Watermark = true, Keylist = true} to CreateWindow.
HUD:SetWatermarkEnabled(false)
HUD:SetKeylistEnabled(true)
HUD:ResetPositions()
local state = HUD:Export()
HUD:Import(state) -- validates the complete state before applying it
local telemetry = HUD:GetMetrics()
```

The example exposes **General → Watermark / Keylist / Reset widget positions**. It uses the existing native Inter font, theme Dialog/Text/Primary colors, rounded translucent surfaces and sliced dark shadows. Changing themes updates both widgets without recreating them. `RB` and the actual local player's display name/avatar replace the other game's branding.

- Watermark: live RenderStepped FPS, client Data Ping (fallback GetNetworkPing), frame-time standard deviation in milliseconds (`VAR`, up to 60 recent frames), username and avatar. Metrics refresh four times per second. Roblox does not provide a reliable public per-client packet-loss/timeout measurement here: these fields show `—`, not fictional zeroes. An optional `MetricsProvider = function() return {Ping=..., Loss=..., Timeout=...} end` may supply genuine values in milliseconds, percent and seconds respectively. No other-game APIs or gameplay logic are executed.
- Keylist: actual active per-feature Toggle/Hold/Always bindings from `Window.FeatureUI.Model`, with the real feature title and boolean-value indicator. Rows fade/resize on activation and release. Only the last Always binding on a feature takes precedence, and unavailable/locked features are omitted. With the menu open, the empty header remains available for dragging; with the menu closed and no active bindings, the list fades out. Closing the menu does not hide active bindings or stop telemetry.
- Dragging follows the supplied `drag_widget` behavior, reimplemented for Roblox GUI input: menu-open only, direct grab offset without smoothing/jumps, one shared input capture, screen clamping and cancellation on focus loss or menu close. The watermark shows center/top/bottom rulers, snaps within 10 px to center X and center Y 32 px from the top/bottom, and bypasses snapping/rulers while Ctrl is held. On release, its horizontal anchor becomes left/center/right according to the widget center's screen third. Keylist uses the same direct drag and bounds without watermark rulers. Hover/held highlights and guides are time-based animations.
- Positions are normalized, so a right/center-anchored watermark stays aligned as its text width or viewport changes. The watermark scales down to fit narrow viewports. HUD has a separate overlay lifecycle and is destroyed with the window, rather than disappearing when the menu is merely closed.
- Ordinary ConfigManager `Save()` / `Load()` now includes `__hud`: both visibility flags and normalized positions. Legacy configs without `__hud` keep the configured defaults. As with other settings, changes persist to disk when the config is explicitly saved; this feature does not silently overwrite a user's config.

QA: `tests/HUDGeometry.luau` adds 31 pure geometry assertions to `npm test`. `tests/ForkHUD.lua` passed 43 live API/synthetic-signal checks: telemetry, unknown fields, font, active/disabled-value bindings, Always precedence, menu visibility, drag offsets/edges/rulers/release, focus cancellation, atomic config validation, actual disk Save/Load, and all seven themes. Real VirtualInputManager mouse input additionally verified exact movement (-120, +110 px) with successful capture/release. Separate OS screenshots were inspected in Dark and Light, including active rows. These checks do not execute the supplied game's script.

## Refined configurable HUD (revision 12 — current)

Revision 12 supersedes the fixed telemetry strip and switch-style rows described for revision 11. Default fields are **FPS, Ping, Username, Time, Weekday, Avatar, Logo, Build**; the misleading/unavailable LOSS and TIMEOUT cells are removed entirely.

**General → Watermark elements** is a multi-select with an empty selection allowed. Optional elements include executor name (read once from `identifyexecutor` / `getexecutorname` when exposed), client memory, frame-time variance, session uptime and place ID. Unsupported executor identification is omitted rather than invented. No executor credentials or private files are read. Time/weekday use `os.date` on the client's local machine; session time begins when this HUD is constructed.

```lua
local HUD=Window:CreateHUD({
    Watermark=true,Keylist=true,
    Builds={syntheticplatinum27='Nightly'}, -- cosmetic exact-username allowlist
    Build='Release',                       -- everyone else's display label
})
HUD:SetFields({'FPS','Ping','Username','Time','Weekday','Avatar','Logo','Build'})
HUD:SetField('Executor',true) -- API uses stable IDs; the multi-select uses labels
HUD:SetKeylistMode('Value')  -- or 'Key'
local selected=HUD:GetFields()
```

- Build lookup uses the real Roblox **Name**, not DisplayName, with exact case-insensitive matching. It is only a display label, not an authentication, entitlement or permission check. The demo assigns this user's requested Nightly label; other users receive Release.
- Numeric telemetry gets reserved-width columns and mild display smoothing, so FPS/ping changes never resize or shift the watermark. Raw current values remain available via `GetMetrics()`. Field insertion/removal animates clipping, opacity, occupied width and neighboring positions. Whole-widget visibility fades/scales subtly, with no per-update width tween resets. Transitions use delta-time exponential interpolation, not frame counts.
- Current Keylist has a compact 118×30 header and lightly tinted, value-first rows, not switches or a full card behind every label. Numeric features show their actual value on the left; booleans use ON/OFF. **General → Keylist labels** can show the bound key instead. `HotkeyLabel` may be a string or `(owner,binding)` formatter for integrations that need a specialized actual value. Removing a binding retains its row until the opacity/height collapse finishes, then destroys it.
- Rulers/drag hover highlights follow the theme Accent surface: white in Light, dark in Dark. Hover highlighting is only visible while hovered/held, not as a permanent rectangular slab. Direct dragging and reference snap/release behavior are retained; fractional positions avoid artificial whole-pixel stepping during size transitions.
- HUD state version 2 persists selected fields and Keylist mode in `__hud`, alongside existing visibility/anchors. Version-1 HUD configs still load without losing the new default field selection. The demo's settings mirror API/Import/Load changes via `HUD.OnChanged`; field/mode widgets have a single config source of truth rather than conflicting duplicate flags.

QA: `HUDModel.luau` adds 80 pure assertions for defaults, selection validation, exact build identity, clock formatting and frame-rate-independent monotonic animation. Updated `ForkHUD.lua` passed 62 live checks, including stable width during real telemetry updates, interpolated selection, empty selection, executor identity, Nightly, local time/day, actual numeric values, removal fade/cleanup, settings mirroring, disk persistence, and white Light-theme guides. All earlier geometry/hotkey/number tests remain enabled.

## Reference-size binds and tighter opaque watermark (revision 13 — current)

The latest supplied reference replaces the previous switch-at-right and value-first default layouts. **Classic** now means: a 14px neutral header icon and 12px Hotkeys text in a 24px header; a 14×8 boolean indicator at x=8 on each row; feature name at x=38 in the native 12px font; 24px rows on a 31px pitch. Header-to-first-row center spacing is 30px. No large header/body cards are drawn in this mode. General → Keylist style defaults to Classic; the earlier Value and Key alternatives remain optional and config-compatible. Actual binding data/actions are unchanged.

Watermark has an opaque, pure-black background in Dark and opaque themed Dialog color elsewhere, a restrained 7px corner radius and neutral icons. Inter-field spacing is 6px and side padding 8px. Numeric reserves fit normal three-digit values instead of four-digit columns, weekday reserves use Wed rather than WWW; exceptional four-plus-digit numbers expand their reserve smoothly rather than clipping. The same eight default fields measured 482px rather than the previous 550px in the live client. User-selected fields, Nightly lookup, time/day and animated insertion/removal are retained. Updated live HUD suite passed 66 checks; reference sizes/positions, no-heavy-plates Classic mode, opaque black Dark watermark and all previous core settings/drag/telemetry tests are covered.

## Sirius labels and opaque bind surfaces (revision 14 — current)

FPS now uses Lucide `monitor`, visually distinct from Ping's signal bars. Icon-bearing watermark labels begin 22px after a 14px icon, providing an explicit **8px icon-to-text gap**; inter-field spacing remains 6px. The brand cell displays **Sirius** rather than RB while retaining its existing config ID. Weekday labels use full English names (Monday–Sunday), measured from the current name instead of reserving a long empty slot every day. Header and Classic bind-list body use opaque themed surfaces: pure black in Dark, Dialog color in other themes. The reference's compact icon/label dimensions remain; only its transparent styling was not retained. Unit HUDModel coverage is now 89 checks, and the live HUD suite passed 68 checks including brand, full weekday and gap/surface assertions.

### fork.15 — content-sized Classic hotkeys
- Classic is now the only keylist layout. Removed the style dropdown; legacy Key/Value config/API requests normalize to Classic.
- Header backplate and shadow fit only the icon/title (native font measurement + padding), independent of binding widths. No body/row background.
- Larger native typography: title and bindings 14px, header/rows 30px, header icon 16px, binding indicators 18×10px; 6px row gap.
- Drag guides and hover highlights are fixed white, like the supplied drag_widget source, not theme Accent. Keylist hover highlight only covers its header.
- Live regression: 79 assertions passed, including older configs, content-sized header with long binding, transparent rows, fixed white guides across seven themes. Dark/Light screenshots inspected.

### fork.16 — animated context rows, clipped color previews, split keylist plates
- Per-feature hotkey context retains row instances. Add/remove animates row opacity, 38px occupancy, sibling flow and panel height; deleted rows are cleaned only after collapse. Side editor follows its animated anchor; list remains scrollable after five rows.
- Stronger soft native shadows for context/editor/modes and color panels, outside CanvasGroup clipping.
- Color input has a dedicated ellipsized, clipped preview for HEX/RGB/HSV/HSL. Full TextBox text stays intact; focusing switches to editable full data, and Enter/FocusLost/paste preserve existing parsing behavior.
- Classic header extended to at least 140px; body starts at y32 (2px gap). Each binding uses a separate rounded 30×30 indicator plate and a label plate measured to text +16px padding, themed opaque black/white.
- Live Roblox QA: ForkHotkeys 51, ForkMotion 33, ForkHUD 81 and ForkPaste 18 checks passed. Inspected Dark HSV ellipsis, soft panel shadows, and separate Dark/Light keylist plates.

### fork.17 — subordinate binding size
- Header stays 14px / 30px high. Bindings reduced to 13px / 26px high, 26px square indicator plates and 16×8px switches. Name plates retain measured widths; 5px row gap. Header/row gap stays 2px.
- Live HUD regression: 81 checks passed, including explicit header > binding font/height comparisons. Actual game screenshot inspected.
