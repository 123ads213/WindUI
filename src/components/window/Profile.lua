-- WindUI by Footagesus (MIT). Optional themed profile/preferences footer.
local Creator = require('../../modules/Creator')
local New, Tween = Creator.New, Creator.Tween
local Players = game:GetService('Players')
local Input = game:GetService('UserInputService')
local Profile = {}

function Profile.New(Window, WindUI, Config)
    local self = { Opened = false, Page = 'Main', Destroyed = false, UIElements = {}, Config = Config }
    local main = Window.UIElements.Main
    local parent = main.Main
    local signals = {}
    local function connect(signal, fn) local c=signal:Connect(fn);signals[#signals+1]=c;return c end
    local function corner(parent, radius) return New('UICorner',{Parent=parent,CornerRadius=UDim.new(0,radius)}) end
    local function text(parent, name, value, x,y,w,h,size,secondary)
        return New('TextLabel',{Parent=parent,Name=name,Text=value,Position=UDim2.fromOffset(x,y),Size=UDim2.new(w<0 and 1 or 0,w,h<0 and 1 or 0,h),
            BackgroundTransparency=1,TextSize=size or 15,TextXAlignment='Left',TextYAlignment='Center',TextTruncate='AtEnd',
            FontFace=Font.new(Creator.Font,secondary and Enum.FontWeight.Regular or Enum.FontWeight.Medium),
            ThemeTag={TextColor3=secondary and 'Placeholder' or 'Text'},ZIndex=202})
    end
    local function icon(parent, name, x,y,size)
        local im=Creator.Image(name,name,0,Window.Folder,'Profile',true,false,'Icon')
        im.Parent=parent;im.Position=UDim2.fromOffset(x,y);im.Size=UDim2.fromOffset(size,size);im.ZIndex=203
        im.ImageLabel.ZIndex=203
        return im
    end
    local function button(parent,name,title,symbol,y)
        local b=New('TextButton',{Parent=parent,Name=name,Text='',Size=UDim2.new(1,-24,0,42),Position=UDim2.fromOffset(12,y),
            BackgroundTransparency=1,AutoButtonColor=false,ThemeTag={BackgroundColor3='ElementBackground'},ZIndex=201})
        corner(b,9);icon(b,symbol,10,11,20);text(b,'Label',title,42,0,-84,42,15)
        connect(b.MouseEnter,function()Tween(b,.16,{BackgroundTransparency=0}):Play()end)
        connect(b.MouseLeave,function()Tween(b,.16,{BackgroundTransparency=1}):Play()end)
        return b
    end
    local previousUserEnabled = Window.User.Enabled
    if Window.User.Disable then Window.User:Disable() end
    local sidebar = Window.UIElements.SideBarContainer
    local previousSideSize = UDim2.new(0,Window.SideBarWidth,1,-Window.Topbar.Height-(previousUserEnabled and 42+Window.UIPadding*2 or 0))
    local footerSize=UDim2.new(0,Window.SideBarWidth,1,-Window.Topbar.Height-76)
    Tween(sidebar,0,{Size=footerSize}):Play()
    sidebar.Size=footerSize
    -- Stop any in-flight built-in User animation from overwriting the reserved footer area.
    task.defer(function()if not self.Destroyed then sidebar.Size=UDim2.new(0,Window.SideBarWidth,1,-Window.Topbar.Height-76)end end)
    local card=New('TextButton',{Parent=parent,Name='ProfileCard',Text='',Size=UDim2.fromOffset(Window.SideBarWidth-16,60),
        Position=UDim2.new(0,8,1,-8),AnchorPoint=Vector2.new(0,1),AutoButtonColor=false,
        ThemeTag={BackgroundColor3='ElementBackground'},BackgroundTransparency=1,ZIndex=110})
    corner(card,12)
    local avatar=New('ImageLabel',{Parent=card,Name='Avatar',Image=Config.Avatar or ('rbxthumb://type=AvatarHeadShot&id='..Players.LocalPlayer.UserId..'&w=150&h=150'),
        BackgroundTransparency=1,Size=UDim2.fromOffset(36,36),Position=UDim2.fromOffset(10,12),ZIndex=202})
    corner(avatar,18)
    local name=Config.Name or Players.LocalPlayer.DisplayName
    local cardName=text(card,'Name',name,56,10,-82,20,15)
    local days=text(card,'Remaining','',56,31,-82,18,12,true)
    icon(card,'chevron-right',Window.SideBarWidth-37,22,16)

    local menu=New('CanvasGroup',{Parent=parent,Name='ProfileMenu',Visible=false,Size=UDim2.fromOffset(304,304),
        GroupTransparency=1,ThemeTag={BackgroundColor3='Dialog'},ZIndex=200,Active=true})
    corner(menu,14)
    New('UIStroke',{Parent=menu,Thickness=1,Transparency=.92,ThemeTag={Color='Outline'}})
    local pages={}
    for _,page in ipairs({'Main','History'})do
        pages[page]=New('CanvasGroup',{Parent=menu,Name=page,BackgroundTransparency=1,Size=UDim2.fromScale(1,1),Visible=page=='Main',ZIndex=201})
    end
    self.UIElements={Card=card,Menu=menu,Avatar=avatar,Name=cardName,Remaining=days,Pages=pages}
    local header=pages.Main
    local bigAvatar=New('ImageLabel',{Parent=header,Image=avatar.Image,BackgroundTransparency=1,Size=UDim2.fromOffset(48,48),Position=UDim2.fromOffset(16,24),ZIndex=202})
    corner(bigAvatar,24)
    text(header,'Name',name,76,14,-92,22,17)
    local expiry=text(header,'Expiry','',76,38,-92,18,13,true)
    local renew=New('TextButton',{Parent=header,Name='Renew',Text='Renew',BackgroundTransparency=1,Position=UDim2.fromOffset(76,58),Size=UDim2.fromOffset(110,24),
        TextXAlignment='Left',TextSize=14,FontFace=Font.new(Creator.Font,Enum.FontWeight.Medium),ThemeTag={TextColor3='Primary'},ZIndex=202})
    New('Frame',{Parent=header,Position=UDim2.fromOffset(16,96),Size=UDim2.new(1,-32,0,1),BorderSizePixel=0,BackgroundTransparency=.94,ThemeTag={BackgroundColor3='Text'},ZIndex=202})

    local scaleButton=button(header,'MenuScale','Menu Scale','scaling',106)
    scaleButton.Label.Size=UDim2.fromOffset(128,42)
    local scaleValue=text(scaleButton,'Value','100%',170,0,76,42,14,true)
    scaleValue.TextXAlignment='Right'
    icon(scaleButton,'chevron-right',252,13,16)
    local styleButton=button(header,'Style','Style','palette',152)
    local styleValue=text(styleButton,'Value',WindUI:GetCurrentTheme(),142,0,80,42,13,true)
    styleValue.TextXAlignment='Right'
    icon(styleButton,'chevron-right',252,13,16)
    local historyButton=button(header,'History','History','history',244)
    icon(historyButton,'chevron-right',252,13,16)

    local scheduleClose
    local transparencyButton=button(header,'Transparency','Transparency','blend',198)
    transparencyButton.Label.Size=UDim2.fromOffset(120,42)
    local hit=New('TextButton',{Parent=transparencyButton,Name='TrackInput',Text='',AutoButtonColor=false,
        Position=UDim2.fromOffset(164,6),Size=UDim2.fromOffset(104,30),BackgroundTransparency=1,ZIndex=204,Active=true})
    local track=New('Frame',{Parent=hit,Name='Track',Position=UDim2.new(0,2,.5,-2),Size=UDim2.new(1,-4,0,4),
        BorderSizePixel=0,BackgroundTransparency=.83,ThemeTag={BackgroundColor3='Icon'},ZIndex=204})
    corner(track,2)
    local fill=New('Frame',{Parent=track,Name='Fill',Size=UDim2.fromScale(0,1),BorderSizePixel=0,
        ThemeTag={BackgroundColor3='Slider'},ZIndex=205})
    corner(fill,2)
    local tip=New('TextLabel',{Parent=transparencyButton,Name='HoverValue',Text='0',Visible=false,
        AnchorPoint=Vector2.new(.5,1),Size=UDim2.fromOffset(44,24),Position=UDim2.fromOffset(188,3),
        BackgroundTransparency=0,TextSize=13,FontFace=Font.new(Creator.Font,Enum.FontWeight.Medium),
        ThemeTag={BackgroundColor3='Dialog',TextColor3='Text'},ZIndex=208})
    corner(tip,7)
    New('UIStroke',{Parent=tip,Thickness=1,Transparency=.94,ThemeTag={Color='Outline'}})
    local transparency=Window.Transparent and WindUI.TransparencyValue or 0
    local overTrack,dragging,dragInput=false,false,nil
    local dragToken={}
    local tipTween
    local function showTip(show)
        if tipTween then tipTween:Cancel()end
        if show then tip.Visible=true end
        tipTween=Tween(tip,.12,{TextTransparency=show and 0 or 1,BackgroundTransparency=show and 0 or 1});tipTween:Play()
        if not show then task.delay(.12,function()if not self.Destroyed and not overTrack and not dragging then tip.Visible=false end end)end
    end
    function self:SetTransparency(value)
        value=tonumber(value)
        if not value or value~=value or math.abs(value)==math.huge then return transparency end
        transparency=math.round(math.clamp(value,0,1)*100)/100
        Window:SetBackgroundTransparency(transparency)
        fill.Size=UDim2.fromScale(transparency,1)
        tip.Text=string.format('%.2f',transparency):gsub('0+$',''):gsub('%.$','')
        tip.Position=UDim2.fromOffset(166+math.clamp(transparency*100,22,78),3)
        return transparency
    end
    function self:GetTransparency()return transparency end
    local function readTrack(input)
        local x=input.Position.X
        local width=track.AbsoluteSize.X
        if width>0 then self:SetTransparency((x-track.AbsolutePosition.X)/width)end
    end
    local function stopDrag()
        if not dragging then return end
        dragging=false;dragInput=nil
        if WindUI.CurrentInput==dragToken then WindUI.CurrentInput=nil end
        if not overTrack then showTip(false);if self.Opened and scheduleClose then scheduleClose()end end
    end
    connect(hit.MouseEnter,function()overTrack=true;showTip(true);self:CloseFlyout()end)
    connect(hit.MouseLeave,function()overTrack=false;if not dragging then showTip(false)end end)
    connect(hit.InputBegan,function(input)
        if input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch then return end
        if WindUI.CurrentInput and WindUI.CurrentInput~=dragToken then return end
        dragging=true;dragInput=input;WindUI.CurrentInput=dragToken;showTip(true);self:CloseFlyout();readTrack(input)
    end)
    connect(Input.InputChanged,function(input)
        if dragging and ((dragInput.UserInputType==Enum.UserInputType.Touch and input==dragInput) or
            (dragInput.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseMovement))then readTrack(input)end
    end)
    connect(Input.InputEnded,function(input)
        if dragging and (input==dragInput or (dragInput.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseButton1))then stopDrag()end
    end)
    connect(Input.WindowFocusReleased,stopDrag)
    self.UIElements.TransparencyButton=transparencyButton
    self.UIElements.TransparencyInput=hit
    self.UIElements.TransparencyTrack=track
    self.UIElements.TransparencyFill=fill
    self.UIElements.TransparencyTooltip=tip
    self:SetTransparency(transparency)

    local function backHeader(page,title)
        local b=button(page,'Back',title,'arrow-left',10)
        connect(b.MouseButton1Click,function()self:ShowPage('Main')end)
    end
    backHeader(pages.History,'Update history')
    local history=New('ScrollingFrame',{Parent=pages.History,Name='Entries',Position=UDim2.fromOffset(16,60),Size=UDim2.new(1,-32,1,-76),
        BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageTransparency=.35,ThemeTag={ScrollBarImageColor3='Icon'},
        ScrollingDirection='Y',CanvasSize=UDim2.new(),AutomaticCanvasSize='Y',ZIndex=202})
    New('UIListLayout',{Parent=history,Padding=UDim.new(0,12),SortOrder='LayoutOrder'})
    New('UIPadding',{Parent=history,PaddingRight=UDim.new(0,8),PaddingBottom=UDim.new(0,8)})
    for index,entry in ipairs(Config.History or {})do
        local item=New('Frame',{Parent=history,Name='Update_'..index,Size=UDim2.new(1,0,0,0),AutomaticSize='Y',BackgroundTransparency=.45,
            ThemeTag={BackgroundColor3='ElementBackground'},LayoutOrder=index,ZIndex=203})
        corner(item,10)
        New('UIPadding',{Parent=item,PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12),PaddingTop=UDim.new(0,12),PaddingBottom=UDim.new(0,12)})
        New('UIListLayout',{Parent=item,Padding=UDim.new(0,6),SortOrder='LayoutOrder'})
        for i,v in ipairs({tostring(entry.Version or '')..'  ·  '..tostring(entry.Date or ''),entry.Title or '',entry.Description or ''})do
            local label=New('TextLabel',{Parent=item,Name='Line_'..i,Text=v,Size=UDim2.new(1,0,0,0),AutomaticSize='Y',TextWrapped=true,
                TextXAlignment='Left',BackgroundTransparency=1,TextSize=i==2 and 15 or 12,LayoutOrder=i,ZIndex=204,
                FontFace=Font.new(Creator.Font,i==2 and Enum.FontWeight.SemiBold or Enum.FontWeight.Regular),ThemeTag={TextColor3=i==2 and 'Text' or 'Placeholder'}})
        end
    end
    self.UIElements.History=history

    local choices={'Auto','75%','90%','100%','110%','125%','150%'}
    local scaleMode='100%'
    local scaleControl
    local function applyScale(mode)
        local value=tonumber(tostring(mode):match('^(%d+)%%$'))
        if mode=='Auto' then
            local view=WindUI.ScreenGui.AbsoluteSize
            local size=Window.Size
            value=100*math.clamp(math.min((view.X-24)/math.max(1,size.X.Offset),(view.Y-24)/math.max(1,size.Y.Offset)),.5,1)
        end
        if value then scaleMode=mode;Window:SetUIScale(math.clamp(value/100,.5,1.5))end
    end
    local flyout=New('CanvasGroup',{Parent=parent,Name='ProfileFlyout',Visible=false,GroupTransparency=1,
        Size=UDim2.fromOffset(180,212),ThemeTag={BackgroundColor3='Dialog'},ZIndex=210,Active=true})
    corner(flyout,12)
    New('UIStroke',{Parent=flyout,Thickness=1,Transparency=.92,ThemeTag={Color='Outline'}})
    local lists={}
    for _,kind in ipairs({'Scale','Style'})do
        lists[kind]=New('Frame',{Parent=flyout,Name=kind,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false,ZIndex=211})
    end
    self.UIElements.Flyout=flyout
    local optionRecords={Scale={},Style={}}
    local hoverCard,hoverMenu=false,false
    local hoverFlyout,hoverRow=false,nil
    local flySerial=0
    local flyAnim,flyMove
    local themeControl={Value=WindUI:GetCurrentTheme(),Opened=false,UIElements={}}
    scaleControl={Value='100%',Opened=false,UIElements={}}
    local function updateChecks(kind,value)
        for option,record in pairs(optionRecords[kind])do record.Check.Visible=option==value end
    end
    function scaleControl:Select(mode)
        if not table.find(choices,mode)then return end
        self.Value=mode;scaleValue.Text=mode;applyScale(mode);updateChecks('Scale',mode)
    end
    function themeControl:Select(theme)
        if not WindUI:GetThemes()[theme]then return end
        self.Value=theme;styleValue.Text=theme;WindUI:SetTheme(theme);updateChecks('Style',theme)
        if Config.OnThemeChanged then Creator.SafeCallback(Config.OnThemeChanged,theme)end
    end
    local function options(kind,values)
        for i,value in ipairs(values)do
            local row=New('TextButton',{Parent=lists[kind],Name='Option_'..i,Text='',Position=UDim2.fromOffset(6,8+(i-1)*28),Size=UDim2.new(1,-12,0,28),
                BackgroundTransparency=1,AutoButtonColor=false,ThemeTag={BackgroundColor3='ElementBackground'},ZIndex=212})
            corner(row,7)
            local label=text(row,'Label',value,10,0,-40,28,14);label.ZIndex=213
            local mark=icon(row,'check',126,6,16);mark.AnchorPoint=Vector2.new(1,0);mark.Position=UDim2.new(1,-10,0,6);mark.ZIndex=214;mark.ImageLabel.ZIndex=214
            mark.Visible=value==(kind=='Scale' and scaleControl.Value or themeControl.Value)
            optionRecords[kind][value]={Row=row,Check=mark}
            connect(row.MouseEnter,function()Tween(row,.16,{BackgroundTransparency=0}):Play()end)
            connect(row.MouseLeave,function()Tween(row,.16,{BackgroundTransparency=1}):Play()end)
            connect(row.MouseButton1Click,function()if kind=='Scale'then scaleControl:Select(value)else themeControl:Select(value)end end)
        end
    end
    options('Scale',choices);options('Style',Config.Themes or {'Dark','Light'})
    self.UIElements.ScaleOptions,self.UIElements.ThemeOptions=optionRecords.Scale,optionRecords.Style
    local function placeFlyout()
        local kind=self.FlyoutKind;if not kind then return end
        local scale=WindUI.UIScaleObj.Scale
        local origin,available=WindUI.ScreenGui.AbsolutePosition,WindUI.ScreenGui.AbsoluteSize
        local width=kind=='Scale' and 160 or 180
        local values=kind=='Scale' and choices or (Config.Themes or {'Dark','Light'})
        local height=16+#values*28
        flyout.Size=UDim2.fromOffset(width,height)
        local minX=(origin.X-main.AbsolutePosition.X)/scale+8
        local maxX=(origin.X+available.X-main.AbsolutePosition.X)/scale-width-8
        local x=menu.Position.X.Offset+menu.Size.X.Offset+6
        if x>maxX then x=menu.Position.X.Offset-width-6 end
        x=math.clamp(x,minX,math.max(minX,maxX))
        local minY=(origin.Y-main.AbsolutePosition.Y)/scale+8
        local maxY=(origin.Y+available.Y-main.AbsolutePosition.Y)/scale-height-8
        local y=math.clamp(menu.Position.Y.Offset+(kind=='Scale' and 106 or 152),minY,math.max(minY,maxY))
        flyout.Position=UDim2.fromOffset(x,y)
    end
    function self:CloseFlyout()
        flySerial+=1;local id=flySerial;self.FlyoutKind=nil;scaleControl.Opened=false;themeControl.Opened=false
        if flyAnim then flyAnim:Cancel()end;if flyMove then flyMove:Cancel()end
        flyAnim=Tween(flyout,.16,{GroupTransparency=1});flyAnim:Play()
        task.delay(.16,function()if not self.Destroyed and flySerial==id and not self.FlyoutKind then flyout.Visible=false end end)
    end
    function self:OpenFlyout(kind)
        if not lists[kind]or self.Destroyed then return end
        if not self.Opened then self:Open()end
        if self.FlyoutKind==kind then return end
        flySerial+=1;self.FlyoutKind=kind
        scaleControl.Opened=kind=='Scale';themeControl.Opened=kind=='Style'
        themeControl.Value=WindUI:GetCurrentTheme();styleValue.Text=themeControl.Value;updateChecks('Style',themeControl.Value)
        for k,v in pairs(lists)do v.Visible=k==kind end
        placeFlyout();local position=flyout.Position
        if flyAnim then flyAnim:Cancel()end;if flyMove then flyMove:Cancel()end
        flyout.Position=position-UDim2.fromOffset(6,0);flyout.GroupTransparency=1;flyout.Visible=true
        flyAnim=Tween(flyout,.2,{GroupTransparency=0},Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
        flyMove=Tween(flyout,.2,{Position=position},Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
        flyAnim:Play();flyMove:Play()
    end
    function scaleControl:Open()self.Opened=true;self.UIElements=lists.Scale;return Window.Profile:OpenFlyout('Scale')end
    function themeControl:Open()self.Opened=true;return Window.Profile:OpenFlyout('Style')end
    function scaleControl:Close()if self.Opened then Window.Profile:CloseFlyout()end end
    function themeControl:Close()if self.Opened then Window.Profile:CloseFlyout()end end
    function themeControl:Display()styleValue.Text=self.Value;updateChecks('Style',self.Value)end
    connect(flyout.MouseEnter,function()hoverFlyout=true;flySerial+=1 end)
    connect(flyout.MouseLeave,function()hoverFlyout=false;local id=flySerial;task.delay(.25,function()if not self.Destroyed and flySerial==id and not hoverRow and not hoverFlyout then self:CloseFlyout();if not hoverCard and not hoverMenu then self:Close()end end end)end)
    for kind,row in pairs({Scale=scaleButton,Style=styleButton})do
        connect(row.MouseEnter,function()hoverRow=kind;self:OpenFlyout(kind)end)
        connect(row.MouseLeave,function()hoverRow=nil;local id=flySerial;task.delay(.25,function()if not self.Destroyed and id==flySerial and not hoverFlyout and not hoverRow then self:CloseFlyout()end end)end)
    end
    self.ScaleControl,self.ThemeControl=scaleControl,themeControl
    self.UIElements.ScaleButton,self.UIElements.StyleButton,self.UIElements.HistoryButton,self.UIElements.Renew=scaleButton,styleButton,historyButton,renew
    local serial=0
    local anim,move
    local function place()
        if self.Destroyed then return end
        local scale=WindUI.UIScaleObj.Scale
        local width,height=main.AbsoluteSize.X/scale,main.AbsoluteSize.Y/scale
        local origin,available=WindUI.ScreenGui.AbsolutePosition,WindUI.ScreenGui.AbsoluteSize
        local minX=(origin.X-main.AbsolutePosition.X)/scale+8
        local maxX=(origin.X+available.X-main.AbsolutePosition.X)/scale-menu.Size.X.Offset-8
        local minY=(origin.Y-main.AbsolutePosition.Y)/scale+8
        local maxY=(origin.Y+available.Y-main.AbsolutePosition.Y)/scale-menu.Size.Y.Offset-8
        -- Keep the old header anchor; the longer list may extend below the window, never outside the viewport.
        menu.Position=UDim2.fromOffset(math.clamp(Window.SideBarWidth+8,minX,math.max(minX,maxX)),
            math.clamp(math.max(8,height-260),minY,math.max(minY,maxY)))
    end
    local function highlight(on)Tween(card,.18,{BackgroundTransparency=on and 0 or 1}):Play()end
    local pageTween
    function self:ShowPage(page)
        if page=='Style'or page=='Scale'then self:OpenFlyout(page);return end
        if not pages[page]then return end
        self:CloseFlyout()
        self.Page=page
        if pageTween then pageTween:Cancel()end
        for k,v in pairs(pages)do v.Visible=k==page end
        pages[page].GroupTransparency=1
        pageTween=Tween(pages[page],.18,{GroupTransparency=0});pageTween:Play()
    end
    function self:Open()
        if self.Destroyed or self.Opened then return end
        serial+=1;self.Opened=true;place();self:ShowPage('Main');highlight(true)
        if anim then anim:Cancel()end;if move then move:Cancel()end
        local position=menu.Position
        menu.Position=position+UDim2.fromOffset(0,8);menu.Visible=true;menu.GroupTransparency=1
        anim=Tween(menu,.24,{GroupTransparency=0},Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
        move=Tween(menu,.24,{Position=position},Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
        anim:Play();move:Play()
    end
    function self:Close()
        serial+=1;local id=serial;self.Opened=false;stopDrag();overTrack=false;showTip(false);highlight(false)
        self:CloseFlyout()
        if anim then anim:Cancel()end;if move then move:Cancel()end
        anim=Tween(menu,.18,{GroupTransparency=1});anim:Play()
        task.delay(.18,function()if not self.Destroyed and serial==id and not self.Opened then menu.Visible=false end end)
    end
    scheduleClose=function()
        serial+=1;local id=serial
        task.delay(.3,function()
            if not self.Destroyed and serial==id and not hoverCard and not hoverMenu and not hoverFlyout and not hoverRow and not dragging then self:Close()end
        end)
    end
    connect(card.MouseEnter,function()hoverCard=true;serial+=1;self:Open()end)
    connect(card.MouseLeave,function()hoverCard=false;scheduleClose()end)
    connect(menu.MouseEnter,function()hoverMenu=true;serial+=1 end)
    connect(menu.MouseLeave,function()hoverMenu=false;scheduleClose()end)
    connect(card.MouseButton1Click,function()if not self.Opened then self:Open()end end)
    connect(scaleButton.MouseButton1Click,function()self:ShowPage('Scale')end)
    connect(styleButton.MouseButton1Click,function()self:ShowPage('Style')end)
    connect(historyButton.MouseButton1Click,function()self:ShowPage('History')end)
    function self:Renew()
        local copy=setclipboard or toclipboard
        if not copy then
            WindUI:Notify({Title='Clipboard unavailable',Content=Config.StoreLink or 'https://discord.gg/eqAEszZzHj',Icon='link',Duration=5})
            self.LastRenewResult='unavailable';return false
        end
        local ok=pcall(copy,Config.StoreLink or 'https://discord.gg/eqAEszZzHj')
        self.LastRenewResult=ok and 'copied' or 'error'
        self.LastRenewNotification=WindUI:Notify({Title=ok and 'Link copied' or 'Copy failed',
            Content=ok and 'Discord store link copied to clipboard.' or 'Clipboard is unavailable.',Icon=ok and 'clipboard-check' or 'triangle-alert',IconSize=36,Duration=4})
        return ok
    end
    connect(renew.MouseButton1Click,function()self:Renew()end)
    connect(Input.InputBegan,function(input)if self.Opened and input.KeyCode==Enum.KeyCode.Escape then self:Close()end end)
    connect(main:GetPropertyChangedSignal('AbsolutePosition'),function()if self.Opened then place();if self.FlyoutKind then placeFlyout()end end end)
    connect(main:GetPropertyChangedSignal('AbsoluteSize'),function()if self.Opened then place();if self.FlyoutKind then placeFlyout()end end end)
    connect(WindUI.UIScaleObj:GetPropertyChangedSignal('Scale'),function()if self.Opened then place();if self.FlyoutKind then placeFlyout()end end end)
    connect(WindUI.ScreenGui:GetPropertyChangedSignal('AbsoluteSize'),function()if scaleMode=='Auto'then applyScale('Auto')end;if self.Opened then place();if self.FlyoutKind then placeFlyout()end end end)
    connect(WindUI.ScreenGui:GetPropertyChangedSignal('AbsolutePosition'),function()if self.Opened then place();if self.FlyoutKind then placeFlyout()end end end)
    function self:SetSubscription(info)
        self.Subscription=info or {};local value=self.Subscription
        local label,untilText
        if value.IsLifetime then label='Lifetime';untilText='Lifetime access'
        elseif value.State=='paused' then label='Paused';untilText='Subscription paused'
        elseif value.State=='pending' then label='Not activated';untilText='Starts on activation'
        elseif value.State=='expired' then label='Expired';untilText='Subscription expired'
        else
            local expiryTime=value.ExpiresAt or (value.DaysRemaining and os.time()+value.DaysRemaining*86400)
            local seconds=expiryTime and math.max(0,expiryTime-os.time())
            label=seconds and (math.ceil(seconds/86400)..' days left') or 'Status unavailable'
            untilText=expiryTime and ('Till: '..os.date('!%b %d, %Y',expiryTime)) or 'Expiry not provided'
        end
        days.Text=label;expiry.Text=untilText
    end
    self:SetSubscription(Config)
    function self:Destroy()
        if self.Destroyed then return end
        stopDrag();self.Destroyed=true;serial+=1
        if tipTween then tipTween:Cancel()end
        if anim then anim:Cancel()end;if move then move:Cancel()end
        if pageTween then pageTween:Cancel()end
        for _,c in ipairs(signals)do c:Disconnect()end
        if flyAnim then flyAnim:Cancel()end;if flyMove then flyMove:Cancel()end
        flyout:Destroy()
        card:Destroy();menu:Destroy()
        if sidebar.Parent then sidebar.Size=previousSideSize end
        if previousUserEnabled and Window.User.Enable and not Window.Destroyed then Window.User:Enable()end
    end
    connect(main.Destroying,function()self:Destroy()end)
    return self
end
return Profile
