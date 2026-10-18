local Section = {}


local Creator = require("../../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween

local TabModule = require("./Tab")

function Section.New(SectionConfig, Parent, Folder, UIScale, Window)
    local SectionModule = {
        Title = SectionConfig.Title or "Section",
        Icon = SectionConfig.Icon,
        IconThemed = SectionConfig.IconThemed,
        Opened = SectionConfig.Opened or false,
        
        HeaderSize = SectionConfig.HeaderSize or 42,
        IconSize = 18,
        
        Expandable = false,
    }
    
    local IconFrame
    if SectionModule.Icon then
        IconFrame = Creator.Image(
            SectionModule.Icon,
            SectionModule.Icon,
            0,
            Folder,
            "Section",
            true,
            SectionModule.IconThemed,
            "TabSectionIcon"
        )
        
        IconFrame.Size = UDim2.new(0,SectionModule.IconSize,0,SectionModule.IconSize)
        IconFrame.ImageLabel.ImageTransparency = .25
    end
    
    local ChevronIconData = Creator.Icon("chevron-down")
    local ChevronIconFrame = New("Frame", {
        Size = UDim2.new(0,SectionModule.IconSize,0,SectionModule.IconSize),
        BackgroundTransparency = 1,
        Visible = false
    }, {
        New("ImageLabel", {
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            Image = ChevronIconData and ChevronIconData[1],
            ImageRectSize = ChevronIconData and ChevronIconData[2] and ChevronIconData[2].ImageRectSize,
            ImageRectOffset = ChevronIconData and ChevronIconData[2] and ChevronIconData[2].ImageRectPosition,
            ThemeTag = {
                ImageColor3 = "Icon",
            },
            ImageTransparency = .7,
        })
    })
    
    local SectionFrame = New("Frame", {
        Size = UDim2.new(1,0,0,SectionModule.HeaderSize),
        BackgroundTransparency = 1,
        Parent = Parent,
        ClipsDescendants = true,
    }, {
        New("TextButton", {
            Size = UDim2.new(1,0,0,SectionModule.HeaderSize),
            BackgroundTransparency = 1,
            Text = "",
        }, {
            IconFrame,
            New("TextLabel", {
                Text = SectionModule.Title,
                TextXAlignment = "Left",
                Size = UDim2.new(
                    1, 
                    IconFrame and (-SectionModule.IconSize-10)*2
                        or (-SectionModule.IconSize-10),
                        
                    1,
                    0
                ),
                ThemeTag = {
                    TextColor3 = "Text",
                },
                FontFace = Font.new(Creator.Font, Enum.FontWeight.SemiBold),
                TextSize = 14,
                BackgroundTransparency = 1,
                TextTransparency = .7,
                --TextTruncate = "AtEnd",
                TextWrapped = true
            }),
            New("UIListLayout", {
                FillDirection = "Horizontal",
                VerticalAlignment = "Center",
                Padding = UDim.new(0,10)
            }),
            ChevronIconFrame,
            New("UIPadding", {
                PaddingLeft = UDim.new(0,11),
                PaddingRight = UDim.new(0,11),
            })
        }),
        New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1,0,0,0),
            AutomaticSize = "Y",
            Name = "Content",
            Visible = true,
            Position = UDim2.new(0,0,0,SectionModule.HeaderSize)
        }, {
            New("UIListLayout", {
                FillDirection = "Vertical",
                Padding = UDim.new(0,Window.Gap),
                VerticalAlignment = "Bottom",
            }),
        })
    })
    
    
    function SectionModule:Tab(TabConfig)
        if not SectionModule.Expandable then
            SectionModule.Expandable = true
            ChevronIconFrame.Visible = true
        end
        TabConfig.Parent = SectionFrame.Content
        local tab = TabModule.New(TabConfig, UIScale)
        tab.TabSection = SectionModule
        return tab
    end
    
    SectionModule.UIElements = { Main = SectionFrame, Content = SectionFrame.Content, Chevron = ChevronIconFrame.ImageLabel }
    local sizeTween, arrowTween
    local function animate(open)
        if not SectionModule.Expandable then return end
        SectionModule.Opened = open
        if sizeTween then sizeTween:Cancel() end
        if arrowTween then arrowTween:Cancel() end
        local scale = Window:GetUIScale() or UIScale or 1
        local height = SectionModule.HeaderSize + (open and SectionFrame.Content.AbsoluteSize.Y / scale or 0)
        sizeTween = Tween(SectionFrame, .24, { Size = UDim2.new(1,0,0,height) }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        arrowTween = Tween(ChevronIconFrame.ImageLabel, .24, { Rotation = open and 180 or 0 }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        sizeTween:Play(); arrowTween:Play()
    end
    function SectionModule:Open() animate(true) end
    function SectionModule:Close() animate(false) end

    Creator.AddSignal(SectionFrame.TextButton.MouseButton1Click, function()
        if SectionModule.Expandable then
            if SectionModule.Opened then
                SectionModule:Close()
            else
                SectionModule:Open()
            end
        end
    end)
    
    Creator.AddSignal(SectionFrame.Content.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        if SectionModule.Opened then
            SectionModule:Open()
        end
    end)
    
    if SectionModule.Opened then
        task.spawn(function()
            task.wait()
            SectionModule:Open()
        end)
    end

    
    
    return SectionModule
end


return Section