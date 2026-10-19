-- Background-only transparency. Retain each surface's own theme/hover alpha;
-- never fade text, icons, toggle state, slider fill, or notification contents.
local Transparency = {}
local surfaces = {
    PanelBackground=true, ElementBackground=true, ElementBackgroundHover=true,
    TabBackground=true, TabBackgroundHover=true, TabBackgroundActive=true,
    LabelBackground=true, Dialog=true, DialogBackground=true,
    WindowSearchBarBackground=true, SectionBox=true, SectionBoxBackground=true,
    DropdownBackground=true, DropdownTabBackground=true, PopupBackground=true,
}
function Transparency.New(Window, WindUI, Creator)
    local root=Window.UIElements.Main
    local self={Level=Window.Transparent and WindUI.TransparencyValue or 0,Destroyed=false}
    local records,signals={},{}
    local function connect(signal,fn)local c=signal:Connect(fn);signals[#signals+1]=c;return c end
    local function apply(record)
        if self.Destroyed or not record.Object.Parent then return end
        local alpha=record.Base+(1-record.Base)*self.Level
        record.Last=alpha
        if math.abs(record.Object[record.Property]-alpha)>1e-6 then record.Object[record.Property]=alpha end
    end
    local function register(object)
        if self.Destroyed or records[object] or not object:IsDescendantOf(root) then return end
        local data=Creator.Objects[object]
        local props=data and data.Properties
        if not props then return end
        local property
        if surfaces[props.ImageColor3] and (object:IsA('ImageLabel')or object:IsA('ImageButton'))then property='ImageTransparency'
        elseif surfaces[props.BackgroundColor3] and object:IsA('GuiObject')then property='BackgroundTransparency' end
        if not property then return end
        local record={Object=object,Property=property,Base=object[property]}
        records[object]=record
        record.Signal=object:GetPropertyChangedSignal(property):Connect(function()
            if self.Destroyed or not object.Parent then return end
            local value=object[property]
            if record.Last and math.abs(value-record.Last)<1e-6 then return end
            record.Base=value;apply(record)
        end)
        connect(object.Destroying,function()if record.Signal then record.Signal:Disconnect()end;records[object]=nil end)
        apply(record)
    end
    for object in pairs(Creator.Objects)do register(object)end
    connect(root.DescendantAdded,function(object)task.defer(function()register(object)end)end)
    local themeSignal=Creator:OnThemeChange(function()
        for object,record in pairs(records)do
            local data=Creator.Objects[object]
            local key=data and data.Properties[record.Property]
            local value=key and Creator.GetThemeProperty(key,Creator.Theme)
            if type(value)=='number'then record.Base=value end
            apply(record)
        end
    end)
    function self:Set(value)
        if self.Destroyed then return end
        self.Level=math.clamp(value,0,1)
        for _,record in pairs(records)do apply(record)end
    end
    function self:Destroy()
        if self.Destroyed then return end;self.Destroyed=true
        if themeSignal then themeSignal:Disconnect()end
        for _,record in pairs(records)do if record.Signal then record.Signal:Disconnect()end end
        for _,c in ipairs(signals)do c:Disconnect()end
        table.clear(records)
    end
    connect(root.Destroying,function()self:Destroy()end)
    return self
end
return Transparency
