-- WindUI by Footagesus (MIT). Fork: compact numbers, nested tabs and curated themes.
-- All element positions and window behavior use the original WindUI layout.
local Env = getgenv and getgenv() or _G
if Env.WindUIForkDemo then
    Env.WindUIForkDemo.Window:Destroy()
    task.wait(0.7)
    Env.WindUIForkDemo = nil
end
local WindUI = Env.__WindUIForkInjectedLibrary
Env.__WindUIForkInjectedLibrary = nil
if not WindUI then
    WindUI = assert(loadstring(game:HttpGet(
        'https://raw.githubusercontent.com/123ads213/WindUI/main/dist/main.lua')))()
end
local Window = WindUI:CreateWindow({
    Title = 'WindUI', Author = 'Footagesus · Extended fork',
    Folder = 'WindUI-fork', Icon = 'panels-top-left', Theme = 'Dark',
    NewElements = true, Size = UDim2.fromOffset(740, 520),
})
Window:Section({ Title = 'COMMON' })
local Visuals = Window:Tab({ Title = 'Visuals', Icon = 'image' })
local Player = Visuals:Tab({ Title = 'Player', Icon = 'user' })
local World = Visuals:Tab({ Title = 'World', Icon = 'globe' })
local General = Window:Tab({ Title = 'General', Icon = 'settings-2' })
local Themes = Window:Tab({ Title = 'Themes', Icon = 'palette' })

local Calls = {}
Player:Section({ Title = 'Player settings' })
local Big = Player:Slider({
    Title = 'Distance', Desc = 'Compact display, numeric callback.',
    Value = { Min = 0, Max = 1e9, Default = 500000 }, Step = 1, IsTooltip = true,
    Callback = function(value) Calls.Distance = value end,
})
local Billion = Player:Slider({ Title = 'Budget', Value = { Min = 0, Max = 1e12, Default = 1250000000 }, Step = 1000,
    IsTooltip = true, Callback = function(value) Calls.Budget = value end })
local Fine = Player:Slider({ Title = 'Precision', Width = 170, ValueWidth = 72,
    Value = { Min = -1, Max = 1, Default = .12345 }, Step = .00001,
    Callback = function(value) Calls.Fine = value end })
Player:Toggle({ Title = 'Show players', Value = true, Callback = function() end })
Player:Button({ Title = 'Reset distance', Callback = function() Big:Set(500000) end })

World:Section({ Title = 'World settings' })
local Gravity = World:Slider({ Title = 'Gravity', Value = { Min = 0, Max = 500, Default = 196.2 }, Step = .1 })
local Balance = World:ProgressBar({ Title = 'Balance', DisplayMode = 'Value',
    Value = { Min = 0, Max = 1e9, Default = 500000 } })
local Collection = World:ProgressBar({ Title = 'Collection', DisplayMode = 'Fraction', Width = 210,
    Value = { Min = 0, Max = 1e9, Default = 250000000 } })
World:Toggle({ Title = 'Shadows', Value = true, Callback = function() end })

General:Paragraph({ Title = 'Nested tabs', Desc = 'Click Visuals to expand Player and World. Each child has its own page; the last selected child is remembered.' })
General:Slider({ Title = 'Unshortened', Compact = false, Width = 170, ValueWidth = 72,
    Value = { Min = 0, Max = 1e6, Default = 500000 } })
General:Slider({ Title = 'Locked', Locked = true, Value = { Min = 0, Max = 1e6, Default = 500000 } })
General:Slider({ Title = 'Fixed range', Value = { Min = 5, Max = 5, Default = 5 } })
Themes:Dropdown({ Title = 'Theme', Values = { 'Dark', 'Light', 'Ocean', 'Forest', 'Ember', 'Orchid', 'Paper' }, Value = 'Dark',
    Callback = function(theme) WindUI:SetTheme(theme) end })
Themes:Toggle({ Title = 'Preview toggle', Value = true, Callback = function() end })
Themes:Slider({ Title = 'Preview slider', Value = { Min = 0, Max = 1e6, Default = 500000 }, IsTooltip = true })
Themes:Button({ Title = 'Preview button' })
Themes:Input({ Title = 'Preview input', Placeholder = 'Type here…', Callback = function() end })
Window:SelectTab(Visuals.Index) -- Selects the first unlocked child (Player).

Env.WindUIForkDemo = { Library = WindUI, Window = Window, Big = Big, Billion = Billion,
    Fine = Fine, Calls = Calls, Visuals = Visuals, Player = Player, Players = Player,
    World = World, General = General, Themes = Themes, Gravity = Gravity, Balance = Balance, Collection = Collection }
return Window
