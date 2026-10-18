-- WindUI fork showcase. Original library by Footagesus, MIT (see LICENSE).
-- Use this fork URL, not the original upstream distribution.
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
    Title = 'WindUI · Extended', Author = 'WindUI by Footagesus · community fork',
    Folder = 'WindUI-fork', Icon = 'panels-top-left', Theme = 'Dark',
    NewElements = true, Size = UDim2.fromOffset(900, 740),
    MinSize = Vector2.new(600, 400), MaxSize = Vector2.new(1440, 1100),
    Resizable = true,
})
local Common = Window:Section({ Title = 'COMMON', Collapsible = false, Indent = 12 })
local Visuals = Common:Tab({ Title = 'Visuals', Icon = 'image' })
local Players = Common:Tab({ Title = 'Players', Icon = 'users' })
local World = Common:Tab({ Title = 'World', Icon = 'globe' })
local SettingsGroup = Window:Section({ Title = 'SETTINGS', Opened = true, Indent = 12 })
local Themes = SettingsGroup:Tab({ Title = 'Appearance', Icon = 'palette' })

Visuals:Section({ Title = 'Interactive Elements', Desc = 'Compact numbers. Exact values. Flexible rows.', Icon = 'sliders-horizontal' })
local Calls = {}
local Big = Visuals:Slider({
    Title = 'Distance', Desc = '500000 is displayed as 500k. Focus to edit the full number.',
    Value = { Min = 0, Max = 1e9, Default = 500000 }, Step = 1, IsTooltip = true,
    Callback = function(value) Calls.Distance = value end,
})
local Billion = Visuals:Slider({ Title = 'Budget', Value = { Min = 0, Max = 1e12, Default = 1250000000 }, Step = 1000,
    Callback = function(value) Calls.Budget = value end })
local Fine = Visuals:Slider({ Title = 'Fine precision', Value = { Min = -1, Max = 1, Default = 0.12345 }, Step = 0.00001,
    Callback = function(value) Calls.Fine = value end })
Visuals:Section({ Title = 'Brightness Control', Icon = 'sun', TextSize = 15 })
Visuals:Slider({ IsTextbox = false, Width = 250, Icons = { From = 'moon', To = 'sun' },
    Value = { Min = 0, Max = 100, Default = 55 }, IsTooltip = true })
Visuals:Section({ Title = 'Volume Settings', Icon = 'volume-2', TextSize = 15 })
local Volume = Visuals:Slider({ IsTextbox = false, Icons = { From = 'volume-1', To = 'volume-2' },
    Value = { Min = 0, Max = 100, Default = 72 }, IsTooltip = true })
local Actions = Visuals:HStack({})
Actions:Button({ Title = 'Save', Icon = 'save', IconAlign = 'Left', Justify = 'Center', Callback = function()
    WindUI:Notify({ Title = 'Saved', Content = 'Example only: connect your persistence here.', Duration = 2 })
end })
Actions:Button({ Title = 'Reset', Icon = 'rotate-ccw', IconAlign = 'Left', Justify = 'Center', Callback = function()
    Big:Set(500000); Billion:Set(1250000000); Fine:Set(0.12345); Volume:Set(72)
end })

Players:Section({ Title = 'Value displays', Icon = 'hash' })
Players:ProgressBar({ Title = 'Balance', DisplayMode = 'Value', Value = { Min = 0, Max = 1e9, Default = 500000 } })
Players:ProgressBar({ Title = 'Collection', DisplayMode = 'Fraction', Width = 230,
    Value = { Min = 0, Max = 1e9, Default = 250000000 } })
Players:Slider({ Title = 'Unshortened', Compact = false, Width = 220,
    Value = { Min = 0, Max = 1000000, Default = 500000 } })
Players:Slider({ Title = 'Locked', Locked = true, Value = { Min = 0, Max = 1e6, Default = 500000 } })
Players:Slider({ Title = 'Fixed range', Value = { Min = 5, Max = 5, Default = 5 } })
World:Paragraph({ Title = 'Sidebar groups', Desc = 'COMMON is a static heading. SETTINGS is collapsible. Tabs keep separate content pages.' })
World:Toggle({ Title = 'Autumn', Value = true, Callback = function() end })
local WorldRow = World:HStack({})
WorldRow:Button({ Title = 'Load', Icon = 'folder-open', IconAlign = 'Left', Justify = 'Center' })
WorldRow:Button({ Title = 'Unload', Icon = 'package-minus', IconAlign = 'Left', Justify = 'Center' })

Themes:Section({ Title = 'Appearance', Desc = 'Dark unchanged. Light tuned. Five distinct alternative palettes.', Icon = 'palette' })
Themes:Dropdown({ Title = 'Theme', Values = { 'Dark', 'Light', 'Ocean', 'Forest', 'Ember', 'Orchid', 'Paper' }, Value = 'Dark',
    Callback = function(theme) WindUI:SetTheme(theme) end })
Themes:Toggle({ Title = 'Preview toggle', Value = true, Callback = function() end })
Themes:Slider({ Title = 'Preview slider', Value = { Min = 0, Max = 1e6, Default = 500000 } })
Themes:ProgressBar({ Title = 'Preview progress', Value = { Min = 0, Max = 100, Default = 65 } })
Themes:Button({ Title = 'Preview button', Icon = 'check', IconAlign = 'Left', Justify = 'Center' })
Themes:Input({ Title = 'Preview input', Placeholder = 'Type here…', Callback = function() end })
Window:SelectTab(Visuals.Index)

-- Optional inspection handle for the MCP test; contains only this showcase's objects.
if getgenv then getgenv().WindUIForkDemo = { Library = WindUI, Window = Window,
    Big = Big, Billion = Billion, Fine = Fine, Calls = Calls, Visuals = Visuals,
    Players = Players, Themes = Themes, Common = Common, Settings = SettingsGroup } end
return Window
