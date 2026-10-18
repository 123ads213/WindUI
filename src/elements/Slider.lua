local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)

local UserInputService = cloneref(game:GetService("UserInputService"))
local RunService = cloneref(game:GetService("RunService"))

local Creator = require("../modules/Creator")
local Numbers = require("../modules/NumberFormat")
local New = Creator.New
local Tween = Creator.Tween

local Element = {}

local IsSliderHolding = false

function Element:New(Config)
	local Slider = {
		__type = "Slider",
		Title = Config.Title or nil,
		Desc = Config.Desc or nil,
		Locked = Config.Locked or nil,
		LockedTitle = Config.LockedTitle,
		Value = Config.Value or {},
		Icons = Config.Icons or nil,
		IsTooltip = Config.IsTooltip or false,
		IsTextbox = Config.IsTextbox,
		Step = math.max(Numbers.Finite(Config.Step) or 1, 1e-9),
		Compact = Config.Compact ~= false,
		Decimals = Config.Decimals or 2,
		Format = Config.Format,
		Callback = Config.Callback or function() end,
		UIElements = {},
		IsFocusing = false,

		Width = math.max(Numbers.Finite(Config.Width) or (Config.Compact ~= false and 184 or 130), 100),
		TextBoxWidth = math.max(30, Numbers.Finite(Config.ValueWidth) or (Config.Compact ~= false and 72 or 48)),
		ThumbSize = 13,
		IconSize = 26,
	}
	if type(Slider.Icons) == "table" and next(Slider.Icons) == nil then
		Slider.Icons = {
			From = "sfsymbols:sunMinFill",
			To = "sfsymbols:sunMaxFill",
		}
	end
	if Slider.IsTextbox == nil and Slider.Title == nil then
		Slider.IsTextbox = false
	else
		Slider.IsTextbox = Slider.IsTextbox ~= false
	end

	local isTouch
	local moveconnection
	local releaseconnection
	Slider.Value.Min = Numbers.Finite(Slider.Value.Min) or 0
    Slider.Value.Max = Numbers.Finite(Slider.Value.Max) or 100
    if Slider.Value.Min > Slider.Value.Max then
        Slider.Value.Min, Slider.Value.Max = Slider.Value.Max, Slider.Value.Min
    end
    local Value = Numbers.Snap(Numbers.Finite(Slider.Value.Default) or Slider.Value.Min,
        Slider.Value.Min, Slider.Value.Max, Slider.Step)
    Slider.Value.Default = Value
    local LastValue = Value
    local delta = Numbers.Ratio(Value, Slider.Value.Min, Slider.Value.Max)
    local CanCallback = true
    local function Display(val)
        if type(Slider.Format) == "function" then
            local ok, result = pcall(Slider.Format, val)
            if ok and result ~= nil then return tostring(result) end
        end
        return Numbers.Format(val, { Compact = Slider.Compact, Decimals = Slider.Decimals })
    end

	local IconFrom, IconTo
	local TotalSliderWidth = 0
	local IconCount = 0
	if Slider.Icons then
		if Slider.Icons.From then
			IconFrom = Creator.Image(
				Slider.Icons.From,
				Slider.Icons.From,
				0,
				Config.Window.Folder,
				"SliderIconFrom",
				true,
				true,
				"SliderIconFrom"
			)
			IconFrom.Size = UDim2.new(0, Slider.IconSize, 0, Slider.IconSize)
			TotalSliderWidth = TotalSliderWidth + Slider.IconSize
			IconCount += 1
		end
		if Slider.Icons.To then
			IconTo = Creator.Image(
				Slider.Icons.To,
				Slider.Icons.To,
				0,
				Config.Window.Folder,
				"SliderIconTo",
				true,
				true,
				"SliderIconTo"
			)
			IconTo.Size = UDim2.new(0, Slider.IconSize, 0, Slider.IconSize)
			TotalSliderWidth = TotalSliderWidth + Slider.IconSize
			IconCount += 1
		end
	end
	Slider.SliderFrame = require("../components/window/Element")({
		Title = Slider.Title,
		Desc = Slider.Desc,
		Parent = Config.Parent,
		TextOffset = Slider.Width + 24,
		Hover = false,
		Tab = Config.Tab,
		Index = Config.Index,
		Window = Config.Window,
		ElementTable = Slider,
		ParentConfig = Config,
		Tags = Config.Tags,
	})

	Slider.UIElements.SliderIcon = Creator.NewRoundFrame(99, "Squircle", {
		ImageTransparency = 0.95,
		Size = UDim2.new(1, not Slider.IsTextbox and -TotalSliderWidth or (-Slider.TextBoxWidth - 8), 0, 4),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Name = "Frame",
		ThemeTag = {
			ImageColor3 = "Text",
		},
	}, {
		Creator.NewRoundFrame(99, "Squircle", {
			Name = "Frame",
			Size = UDim2.new(delta, 0, 1, 0),
			ImageTransparency = 0.1,
			ThemeTag = {
				ImageColor3 = "Slider",
			},
		}, {
			Creator.NewRoundFrame(99, "Squircle", {
				Size = UDim2.new(
					0,
					Config.Window.NewElements and (Slider.ThumbSize * 2) or (Slider.ThumbSize + 2),
					0,
					Config.Window.NewElements and (Slider.ThumbSize + 4) or (Slider.ThumbSize + 2)
				),
				Position = UDim2.new(1, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				ThemeTag = {
					ImageColor3 = "SliderThumb",
				},
				Name = "Thumb",
			}, {
				Creator.NewRoundFrame(999, "SquircleGlass", {
					Size = UDim2.new(1, 0, 1, 0),
					ImageColor3 = Color3.new(1, 1, 1),
					Name = "Highlight",
					ImageTransparency = 0.5,
				}),
			}),
		}),
	})

	Slider.UIElements.SliderContainer = New("Frame", {
		Size = UDim2.new(Slider.Title == nil and 1 or 0, Slider.Title == nil and 0 or Slider.Width, 0, 0),
		AutomaticSize = "Y",
		Position = UDim2.new(1, Slider.IsTextbox and (Config.Window.NewElements and -12 - 4 or 0) or 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		Parent = Slider.SliderFrame.UIElements.Main,
	}, {
		New("UIListLayout", {
			Padding = UDim.new(0, 12),
			FillDirection = "Horizontal",
			VerticalAlignment = "Center",
			HorizontalAlignment = Slider.Icons
					and (Slider.Icons.From and (Slider.Icons.To and "Center" or "Left") or Slider.Icons.To and "Right")
				or "Center",
		}),
		IconFrom,
		Slider.UIElements.SliderIcon,
		IconTo,
		New("TextBox", {
			Size = UDim2.new(0, Slider.TextBoxWidth, 0, 0),
			TextXAlignment = "Left",
			Text = Display(Value),
			ClearTextOnFocus = false,
			ClipsDescendants = true,
			ThemeTag = {
				TextColor3 = "Text",
			},
			TextTransparency = 0.4,
			AutomaticSize = "Y",
			TextSize = 15,
			FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
			BackgroundTransparency = 1,
			LayoutOrder = -1,
			Visible = Slider.IsTextbox,
		}),
	})

	local Tooltip
	if Slider.IsTooltip then
		Tooltip = require("../components/ui/Tooltip").New(
			Display(Value),
			Slider.UIElements.SliderIcon.Frame.Thumb,
			true,
			"Secondary",
			"Small",
			false
		)
		Tooltip.Container.AnchorPoint = Vector2.new(0.5, 1)
		Tooltip.Container.Position = UDim2.new(0.5, 0, 0, -8)
	end

    local TextBox = Slider.UIElements.SliderContainer.TextBox
    local ScrollingFrameParent = Config.Tab.UIElements.ContainerFrame
    local CurInput = Config.WindUI.GenerateGUID()
    local PreviousScrolling
    local DragX, DragWidth
    local Holding = false
    local Destroyed = false

    local function Render(instant)
        if Destroyed then return end
        local text = Slider.IsFocusing and tostring(LastValue) or Display(LastValue)
        TextBox.Text = text
        local gap = 12
        local gapWidth = gap * (IconCount + (Slider.IsTextbox and 1 or 0))
        -- Fixed value slot: never shift the track as digits/suffixes change during drag.
        TextBox.Size = UDim2.new(0, Slider.TextBoxWidth, 0, 0)
        Slider.UIElements.SliderIcon.Size = UDim2.new(1,
            -TotalSliderWidth - gapWidth - (Slider.IsTextbox and Slider.TextBoxWidth or 0), 0, 4)
        local size = UDim2.new(Numbers.Ratio(LastValue, Slider.Value.Min, Slider.Value.Max), 0, 1, 0)
        if instant or Holding then Slider.UIElements.SliderIcon.Frame.Size = size
        else Tween(Slider.UIElements.SliderIcon.Frame, 0.05, { Size = size }):Play() end
        if Tooltip then Tooltip.TitleFrame.Text = Display(LastValue) end
    end

    local function StopDrag()
        if moveconnection then moveconnection:Disconnect(); moveconnection = nil end
        if releaseconnection then releaseconnection:Disconnect(); releaseconnection = nil end
        if not Holding then return end
        Holding = false
        IsSliderHolding = false
        ScrollingFrameParent.ScrollingEnabled = PreviousScrolling
        if Config.WindUI.CurrentInput == CurInput then Config.WindUI.CurrentInput = nil end
        if not Destroyed then
            if Config.Window.NewElements then
                Tween(Slider.UIElements.SliderIcon.Frame.Thumb, 0.2, {
                    ImageTransparency = 0,
                    Size = UDim2.new(0, Slider.ThumbSize * 2, 0, Slider.ThumbSize + 4),
                }):Play()
            end
            if Tooltip then Tooltip:Close(false) end
        end
    end

    function Slider:Set(newValue)
        if not CanCallback or Destroyed then return LastValue end
        local snapped = Numbers.Snap(newValue, Slider.Value.Min, Slider.Value.Max, Slider.Step)
        if not snapped then Render(true); return LastValue end
        local changed = snapped ~= LastValue
        LastValue = snapped
        Value = snapped
        Slider.Value.Default = snapped
        Render(not changed)
        if changed then Creator.SafeCallback(Slider.Callback, snapped) end
        return snapped
    end

    function Slider:Get() return LastValue end

    function Slider:SetRange(newMin, newMax)
        newMin, newMax = Numbers.Finite(newMin), Numbers.Finite(newMax)
        if not newMin or not newMax then return Slider.Value.Min, Slider.Value.Max end
        if newMin > newMax then newMin, newMax = newMax, newMin end
        Slider.Value.Min, Slider.Value.Max = newMin, newMax
        -- Bounds must update even on a locked slider; only user callbacks remain suppressed.
        local snapped = Numbers.Snap(LastValue, newMin, newMax, Slider.Step)
        local changed = snapped ~= LastValue
        LastValue, Value, Slider.Value.Default = snapped, snapped, snapped
        Render(false)
        if changed and CanCallback then Creator.SafeCallback(Slider.Callback, snapped) end
        return newMin, newMax
    end

    function Slider:SetMin(newMin)
        newMin = Numbers.Finite(newMin)
        if newMin then Slider:SetRange(newMin, math.max(newMin, Slider.Value.Max)) end
        return Slider.Value.Min
    end
    function Slider:SetMax(newMax)
        newMax = Numbers.Finite(newMax)
        if newMax then Slider:SetRange(math.min(Slider.Value.Min, newMax), newMax) end
        return Slider.Value.Max
    end
    function Slider:Lock()
        StopDrag()
        Slider.Locked, CanCallback = true, false
        TextBox.TextEditable = false
        return Slider.SliderFrame:Lock(Slider.LockedTitle)
    end
    function Slider:Unlock()
        Slider.Locked, CanCallback = false, true
        TextBox.TextEditable = true
        return Slider.SliderFrame:Unlock()
    end

    Creator.AddSignal(TextBox.Focused, function()
        if Slider.Locked then TextBox:ReleaseFocus(); return end
        Slider.IsFocusing = true
        Render(true) -- Edit the full exact number, never a rounded abbreviation.
    end)
    Creator.AddSignal(TextBox.FocusLost, function()
        local parsed = Numbers.Parse(TextBox.Text)
        Slider.IsFocusing = false
        if parsed then Slider:Set(parsed) end
        Render(true) -- Restore even if parsing failed or the value did not change.
    end)

    local function ReadPointer(input)
        local x = isTouch and input.Position.X or UserInputService:GetMouseLocation().X
        local track = Slider.UIElements.SliderIcon
        if not DragWidth or DragWidth <= 0 then return end
        local ratio = math.clamp((x - DragX) / DragWidth, 0, 1)
        Slider:Set(Slider.Value.Min + ratio * (Slider.Value.Max - Slider.Value.Min))
    end
    Creator.AddSignal(Slider.UIElements.SliderContainer.InputBegan, function(input)
        if Slider.Locked or Slider.IsFocusing or IsSliderHolding then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
            and input.UserInputType ~= Enum.UserInputType.Touch then return end
        -- The numeric editor must not start a drag when clicked/tapped.
        local p = input.Position
        if Slider.IsTextbox and p.X >= TextBox.AbsolutePosition.X
            and p.X <= TextBox.AbsolutePosition.X + TextBox.AbsoluteSize.X
            and p.Y >= TextBox.AbsolutePosition.Y
            and p.Y <= TextBox.AbsolutePosition.Y + TextBox.AbsoluteSize.Y then return end
        if Config.WindUI.CurrentInput and Config.WindUI.CurrentInput ~= CurInput then return end
        Config.WindUI.CurrentInput = CurInput
        Holding, IsSliderHolding = true, true
        isTouch = input.UserInputType == Enum.UserInputType.Touch
        PreviousScrolling = ScrollingFrameParent.ScrollingEnabled
        ScrollingFrameParent.ScrollingEnabled = false
        DragX = Slider.UIElements.SliderIcon.AbsolutePosition.X
        DragWidth = Slider.UIElements.SliderIcon.AbsoluteSize.X
        ReadPointer(input)
        moveconnection = RunService.RenderStepped:Connect(function() ReadPointer(input) end)
        releaseconnection = UserInputService.InputEnded:Connect(function(ended)
            if (isTouch and ended == input) or (not isTouch and ended.UserInputType == Enum.UserInputType.MouseButton1) then
                StopDrag()
            end
        end)
        if Tooltip then Tooltip:Open() end
    end)
    Creator.AddSignal(Slider.UIElements.SliderContainer:GetPropertyChangedSignal("AbsoluteSize"), function() Render(true) end)
    Creator.AddSignal(Slider.UIElements.SliderContainer.Destroying, function()
        Destroyed = true
        StopDrag()
    end)
    Render(true)
    if Slider.Locked then Slider:Lock() end
    return Slider.__type, Slider
end

return Element
