-- WindUI by Footagesus (MIT). Fork: compact numbers, nested tabs and curated themes.
-- All element positions and window behavior use the original WindUI layout.
local Env = getgenv and getgenv() or _G
Env.__WindUIForkRunId = (Env.__WindUIForkRunId or 0) + 1
local RunId = Env.__WindUIForkRunId
local function disposeLibrary(library)
    if not library then return end
    for _,key in ipairs({ 'ScreenGui', 'NotificationGui', 'DropdownGui', 'TooltipGui' }) do
        local gui=library[key]
        if gui then gui:Destroy() end
    end
end
local WindUI = Env.__WindUIForkInjectedLibrary
Env.__WindUIForkInjectedLibrary = nil
local previous = Env.WindUIForkDemo
local pending = Env.__WindUIForkPendingLibrary
Env.WindUIForkDemo = nil
Env.__WindUIForkPendingLibrary = nil
if previous and previous.Window and not previous.Window.Destroyed then
    previous.Window:Destroy()
    task.wait(0.7)
end
if pending and (not previous or pending ~= previous.Library) then disposeLibrary(pending) end
if RunId ~= Env.__WindUIForkRunId then disposeLibrary(WindUI);return end
if not WindUI then
    WindUI = assert(loadstring(game:HttpGet(
        'https://raw.githubusercontent.com/123ads213/WindUI/73a8b13d831324023f306f21684b6669837c912c/dist/main.lua')))()
end
if RunId ~= Env.__WindUIForkRunId then disposeLibrary(WindUI);return end
Env.__WindUIForkPendingLibrary = WindUI
WindUI.ScreenGui:SetAttribute('WindUIForkExample', true)
-- Migrate stranded demo roots from older examples. Never delete unrelated WindUI windows.
for _,root in ipairs(WindUI.ScreenGui.Parent:GetChildren()) do
    if root ~= WindUI.ScreenGui and root:IsA('ScreenGui') and root.Name == 'WindUI' then
        local owned = root:GetAttribute('WindUIForkExample') == true
        local folder = root:FindFirstChild('Window')
        if not owned and folder then
            for _,frame in ipairs(folder:GetChildren()) do
                local main=frame:FindFirstChild('Main')
                local top=main and main:FindFirstChild('Topbar')
                local left=top and top:FindFirstChild('Left')
                local title=left and left:FindFirstChild('Title')
                if title then
                    for _,label in ipairs(title:GetChildren()) do
                        if label:IsA('TextLabel') and label.Text=='Footagesus · Extended fork' then owned=true end
                    end
                end
            end
        end
        if owned then root:Destroy() end
    end
end
local Window = WindUI:CreateWindow({
    Title = 'WindUI', Author = 'Footagesus · Extended fork',
    Folder = 'WindUI-fork', Icon = 'panels-top-left', Theme = 'Dark',
    CustomCursor = { Enabled = true, Size = 10 }, DragSmoothness = 0.045,
    DescriptionMode = 'Tooltip', ContentPaddingTop = 10, HideSearchBar = false, LockOffscreen = true, NewElements = true, Size = UDim2.fromOffset(740, 520),
})
-- Register immediately: even a later setup error remains cleanable on rerun.
Env.WindUIForkDemo = { Library = WindUI, Window = Window }
Window:Section({ Title = 'COMMON', HeaderSize = 28 })
local Visuals = Window:Tab({ Title = 'Visuals', Icon = 'image' })
local Player = Visuals:Tab({ Title = 'Player', Icon = 'user' })
local World = Visuals:Tab({ Title = 'World', Icon = 'globe' })
local General = Window:Tab({ Title = 'General', Icon = 'settings-2' })
local HUD=Window:CreateHUD({Watermark=true,Keylist=true})
local Appearance = Window:Section({ Title = 'APPEARANCE', Opened = true, HeaderSize = 32 })
local Themes = Appearance:Tab({ Title = 'Themes', Icon = 'palette' })

local Calls = {}
Player:Section({ Title = 'Player settings' })
local Big = Player:Slider({
    Title = 'Distance', Icon = 'ruler', IconSize = 24, IconOffset = Vector2.new(4,0), Desc = 'Set the maximum player display distance. Large values are compact; focus the value to edit the full number.',
    Value = { Min = 0, Max = 1e9, Default = 500000 }, Step = 1, IsTooltip = true,
    Callback = function(value) Calls.Distance = value end,
})
local Billion = Player:Slider({ Title = 'Budget', Icon = 'wallet', IconSize = 24, IconOffset = Vector2.new(4,0), Value = { Min = 0, Max = 1e12, Default = 1250000000 }, Step = 1000,
    IsTooltip = true, Callback = function(value) Calls.Budget = value end })
local Fine = Player:Slider({ Title = 'Precision', Width = 170, ValueWidth = 72,
    Value = { Min = -1, Max = 1, Default = .12345 }, Step = .00001,
    Callback = function(value) Calls.Fine = value end })
local ShowPlayers = Player:Toggle({ Title = 'Show players', Flag = 'show_players', Desc = 'Show player overlays. Right-click to manage multiple hotkeys. K toggles; L applies Enabled while held.', Value = true, Hotkeys = { { Key = 'K', Mode = 'Toggle', Value = true }, { Key = 'L', Mode = 'Hold', Value = true } }, Callback = function(value) Calls.ShowPlayers = value end })
Player:Button({ Title = 'Reset distance', Callback = function() Big:Set(500000) end })

World:Section({ Title = 'World settings' })
local Gravity = World:Slider({ Title = 'Gravity', Value = { Min = 0, Max = 500, Default = 196.2 }, Step = .1 })
local Balance = World:ProgressBar({ Title = 'Balance', DisplayMode = 'Value',
    Value = { Min = 0, Max = 1e9, Default = 500000 } })
local Collection = World:ProgressBar({ Title = 'Collection', DisplayMode = 'Fraction', Width = 210,
    Value = { Min = 0, Max = 1e9, Default = 250000000 } })
World:Toggle({ Title = 'Shadows', Flag = 'world_shadows', Value = true, Callback = function() end })

General:Section({ Title = 'On-screen widgets' })
General:Toggle({ Title = 'Watermark', Flag = 'hud_watermark', Value = true, Hotkeys=false, Callback=function(value)HUD:SetWatermarkEnabled(value)end })
General:Toggle({ Title = 'Keylist', Flag = 'hud_keylist', Value = true, Hotkeys=false, Callback=function(value)HUD:SetKeylistEnabled(value)end })
General:Button({Title='Reset widget positions',Callback=function()HUD:ResetPositions()end})
General:Toggle({ Title = 'Lock Offscreen', Flag = 'lock_offscreen', Value = true,
    Callback = function(value) Window:SetLockOffscreen(value) end })
General:Paragraph({ Title = 'Nested tabs', Desc = 'Click Visuals to expand Player and World. Each child has its own page; the last selected child is remembered.' })
General:Slider({ Title = 'Unshortened', Compact = false, Width = 170, ValueWidth = 72,
    Value = { Min = 0, Max = 1e6, Default = 500000 } })
General:Slider({ Title = 'Locked', Locked = true, Value = { Min = 0, Max = 1e6, Default = 500000 } })
General:Slider({ Title = 'Fixed range', Value = { Min = 5, Max = 5, Default = 5 } })
Themes:Dropdown({ Title = 'Theme', Values = { 'Dark', 'Light', 'Ocean', 'Forest', 'Ember', 'Orchid', 'Paper' }, Value = 'Dark',
    Callback = function(theme) WindUI:SetTheme(theme) end })
Themes:Toggle({ Title = 'Preview toggle', Flag = 'preview_toggle', Value = true, Callback = function() end })
Themes:Slider({ Title = 'Preview slider', Value = { Min = 0, Max = 1e6, Default = 500000 }, IsTooltip = true })
Themes:Button({ Title = 'Preview button' })
Themes:Input({ Title = 'Preview input', Placeholder = 'Type here…', Callback = function() end })
local SolidColor = Themes:Colorpicker({ Title = 'Accent color', Flag = 'accent_color', Default = Color3.fromRGB(42,148,255), Transparency = .15,
    Desc = 'Open the color square. Add colors for a gradient, edit formats, opacity, copy/paste or reset to the default.',
    Callback = function(color,transparency,gradient) Calls.AccentColor = {Color=color,Transparency=transparency,Gradient=gradient} end })
local GradientColor = Themes:Colorpicker({ Title = 'Gradient preview', Flag = 'gradient_color', Gradient = {
    { Position=0, Color=Color3.fromRGB(0,170,255), Transparency=0 },
    { Position=1, Color=Color3.fromRGB(196,92,255), Transparency=.2 },
}, Callback = function(color,transparency,gradient) Calls.GradientColor=gradient end })
local Profile = Window:CreateProfile({
    DaysRemaining = 30, Mock = true, StoreLink = 'https://discord.gg/eqAEszZzHj',
    Themes = { 'Dark', 'Light', 'Ocean', 'Forest', 'Ember', 'Orchid', 'Paper' },
    OnThemeChanged = function(theme) Themes.Elements[1]:Select(theme) end,
    History = {
        {Version='1.6.66-fork.11',Date='2026-10-19',Title='Watermark & keylist',Description='Live Roblox telemetry and an active-hotkey HUD. Reference-style dragging, snap rulers, normalized anchors, theme sync and config persistence.'},
        { Version = '1.6.66-fork.10', Date = '2026-10-19', Title = 'Gradients & popup polish', Description = 'Multi-color gradients, per-stop opacity, Hex/RGB/HSV/HSL formats, copy/paste and reset. Soft popup shadows and cursor-near hotkeys. Legacy Keybind removed.' },
        { Version = '1.6.66-fork.9', Date = '2026-10-19', Title = 'Descriptions & hotkeys', Description = 'Themed hover descriptions and right-click multi-hotkey editor, global list and config persistence. Toggle, Hold and Always with explicit boolean Value.' },
        { Version = '1.6.66-fork.8', Date = '2026-10-18', Title = 'Transparency & interaction', Description = 'Background-only transparency now includes themed panels and surfaces. Time-based smooth dragging and an optional filled white cursor with lifecycle cleanup.' },
        { Version = '1.6.66-fork.7', Date = '2026-10-18', Title = 'Search & transparency', Description = 'Original WindUI Search above COMMON. Longer preferences menu, clean Style row and thumb-free Transparency bar with a hover-only value.' },
        { Version = '1.6.66-fork.6', Date = '2026-10-18', Title = 'Profile & preferences', Description = 'Themed profile menu, subscription display, Renew, menu scaling, Style and scrollable update history. Animated Appearance tab section and centred title icons.' },
        { Version = '1.6.66-fork.5', Date = '2026-10-18', Title = 'Tabs & clean themes', Description = 'Smooth page switching and clean Ocean, Forest, Ember and Orchid contours. Slider title icon support.' },
        { Version = '1.6.66-fork.4', Date = '2026-10-18', Title = 'Viewport & controls', Description = 'Offscreen boundaries now use the actual GUI origin. Clean toggle thumb and Light/Paper outlines.' },
        { Version = '1.6.66-fork.3', Date = '2026-10-18', Title = 'Precision & lifecycle', Description = 'Decimal step normalization, numeric callbacks and safe example reruns without duplicate windows.' },
        { Version = '1.6.66-fork.2', Date = '2026-10-18', Title = 'Original WindUI layout', Description = 'Original inline controls and resize behavior, nested Player/World pages and optional Lock Offscreen.' },
    },
})
local DemoConfig = Window.ConfigManager and Window.ConfigManager:CreateConfig('fork-example-hotkeys')
Env.WindUIForkDemoConfig = DemoConfig
Window:SelectTab(Visuals.Index) -- Selects the first unlocked child (Player).

Env.WindUIForkDemo = { Library = WindUI, Window = Window, Big = Big, Billion = Billion,
    ShowPlayers = ShowPlayers, Fine = Fine, Calls = Calls, Visuals = Visuals, Player = Player, Players = Player,
    World = World, General = General, Themes = Themes, Gravity = Gravity, Balance = Balance, Collection = Collection, Appearance = Appearance, Profile = Profile, HUD = HUD, SolidColor = SolidColor, GradientColor = GradientColor }
Env.__WindUIForkPendingLibrary = nil
return Window
