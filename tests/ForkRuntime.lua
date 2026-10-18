-- Run after ForkExample.lua. Synthetic GUI-signal tests, not a physical mouse test.
local d = assert(getgenv().WindUIForkDemo, 'Run ForkExample.lua first')
local b, passed = d.Big, 0
local function check(value, label) assert(value, label); passed += 1 end
local ok, err = pcall(function()
    check(#d.Visuals.SubTabs==2,'two real child tabs')
    d.Visuals:Select(); task.wait(.2)
    check(d.Window.TabModule.SelectedTab==d.Player.Index,'parent opens first child')
    check(d.Visuals.SubTabsOpened and d.Visuals.UIElements.SubTabs.Visible,'child list expanded')
    d.World:Select(); task.wait(.2)
    check(d.Window.TabModule.SelectedTab==d.World.Index,'second child selected')
    check(d.World.UIElements.ContainerFrameCanvas.Visible and not d.Player.UIElements.ContainerFrameCanvas.Visible,'separate content pages')
    d.General:Select(); task.wait(.2)
    check(d.Window.TabModule.SelectedTab==d.General.Index,'ordinary tab unchanged')
    d.Visuals:Collapse(); d.Visuals:Select(); task.wait(.2)
    check(d.Window.TabModule.SelectedTab==d.World.Index,'last child remembered')
    check(d.Visuals.SubTabsOpened,'programmatic parent selection expands')
    d.Visuals:Collapse(); d.Player:Select(); task.wait(.2)
    check(d.Visuals.SubTabsOpened and d.Window.TabModule.SelectedTab==d.Player.Index,'direct child selection opens ancestor')
    assert(firesignal,'firesignal required')
    firesignal(d.Visuals.UIElements.Main.MouseButton1Click);task.wait()
    check(not d.Visuals.SubTabsOpened,'parent click collapses')
    firesignal(d.Visuals.UIElements.Main.MouseButton1Click);task.wait(.2)
    check(d.Visuals.SubTabsOpened and d.Window.TabModule.SelectedTab==d.Player.Index,'parent click restores child')
    d.Visuals:Collapse();task.wait(.3)
    local holder=d.Visuals.UIElements.SubTabs
    check(not holder.Visible and holder.Size.Y.Offset==0,'collapsed holder hidden')
    d.Visuals:Expand();task.wait(.06)
    local mid=holder.AbsoluteSize.Y
    task.wait(.3)
    check(mid>0 and mid<holder.AbsoluteSize.Y,'expansion has intermediate heights')
    local full=holder.AbsoluteSize.Y
    d.Visuals:Collapse();task.wait(.06)
    check(holder.AbsoluteSize.Y>0 and holder.AbsoluteSize.Y<full,'collapse has intermediate heights')
    d.Visuals:Expand();task.wait(.04);d.Visuals:Collapse();task.wait(.04);d.Visuals:Expand();task.wait(.35)
    check(holder.Visible and d.Visuals.SubTabsOpened and holder.AbsoluteSize.Y>=full-.5,'rapid reversal ends expanded')
    local window=d.Window
    window:SetLockOffscreen(true)
    local main=window.UIElements.Main
    for _,scale in ipairs({.75,1}) do
        window:SetUIScale(scale);task.wait(.3)
        for _,pos in ipairs({Vector2.new(-10000,-10000),Vector2.new(10000,-10000),Vector2.new(-10000,10000),Vector2.new(10000,10000)}) do
            window:SetPosition(UDim2.fromOffset(pos.X,pos.Y));task.wait(.05)
            local p,z,view=main.AbsolutePosition,main.AbsoluteSize,d.Library.ScreenGui.AbsoluteSize
            local origin=d.Library.ScreenGui.AbsolutePosition
            check(p.X>=origin.X-.5 and p.Y>=origin.Y-.5 and p.X+z.X<=origin.X+view.X+.5 and p.Y+z.Y<=origin.Y+view.Y+.5,'locked bounds at scale '..scale)
        end
    end
    window:SetLockOffscreen(false);window:SetPosition(UDim2.fromOffset(-2000,-2000));task.wait(.05)
    check(main.AbsolutePosition.X<0,'offscreen allowed when disabled')
    window:SetLockOffscreen(true);task.wait(.05)
    check(main.AbsolutePosition.X>=d.Library.ScreenGui.AbsolutePosition.X-.5 and main.AbsolutePosition.Y>=d.Library.ScreenGui.AbsolutePosition.Y-.5,'enabling rescues offscreen window')
    window:SetPosition(UDim2.fromScale(.5,.5))
    local drag={UserInputType=Enum.UserInputType.Touch,Position=Vector3.new(main.AbsolutePosition.X+240,main.AbsolutePosition.Y+20,0)}
    firesignal(main.Main.Topbar.InputBegan,drag)
    check(window.Dragging,'topbar drag begins')
    drag.Position=Vector3.new(drag.Position.X,-5000,0)
    firesignal(game:GetService('UserInputService').InputChanged,drag);task.wait(.1)
    check(math.abs(main.AbsolutePosition.Y-d.Library.ScreenGui.AbsolutePosition.Y)<.5,'drag stops exactly at real viewport top edge')
    firesignal(game:GetService('UserInputService').InputEnded,drag);task.wait()
    check(not window.Dragging,'topbar drag releases')
    window:SetPosition(UDim2.fromScale(.5,.5))
    local valueBox=b.UIElements.SliderContainer.TextBox
    b:Set(283780000);task.wait(.1)
    check(valueBox.Text=='283.78m','long compact number')
    check(valueBox.TextBounds.X<=valueBox.AbsoluteSize.X,'long compact text fits fixed slot')
    check(b.UIElements.SliderIcon.AbsoluteSize.X>=99,'usable fixed track width')
    check(b.UIElements.SliderIcon.AbsolutePosition.X>=valueBox.AbsolutePosition.X+valueBox.AbsoluteSize.X+11,'value/track breathing room')
    check(d.General.UIElements.ContainerFrame.UIPadding.PaddingTop.Offset==10,'requested compact top inset')
    b:Set(500000);check(b.UIElements.SliderContainer.TextBox.Text=='500k','compact value')
    b:Set(1000000);check(type(d.Calls.Distance)=='number' and d.Calls.Distance==1000000,'numeric callback')
    b:Set(-1);check(b:Get()==0,'minimum clamp')
    b:Set(1e15);check(b:Get()==1e9,'maximum clamp')
    b:Set(0/0);check(b:Get()==1e9,'NaN ignored')
    b:SetRange(5,5);task.wait(.1);check(b:Get()==5 and b.UIElements.SliderIcon.Frame.Size.X.Scale==1,'equal bounds')
    b:SetRange(0,1e9);b:Set(500000);b:Lock();b:Set(1);check(b:Get()==500000,'locked');b:Unlock()
    d.Fine:Set(-.02326);task.wait()
    check(d.Fine.UIElements.SliderContainer.TextBox.Text=='-0.02326','negative fractional display has no binary tail')
    check(d.Calls.Fine==-.02326,'negative fractional callback follows step')
    local fineBox=d.Fine.UIElements.SliderContainer.TextBox
    firesignal(fineBox.Focused)
    check(fineBox.Text=='-0.02326','focused negative fraction is clean')
    firesignal(fineBox.FocusLost,true)
    d.Fine:Set(.54321);d.Fine:Set(.12345)
    check(math.abs(d.Calls.Fine-.12345)<1e-12,'fractional precision')
    local box=b.UIElements.SliderContainer.TextBox
    firesignal(box.Focused);check(tonumber(box.Text)==500000,'raw value on focus')
    box.Text='1.25m';firesignal(box.FocusLost,true);task.wait();check(b:Get()==1250000,'abbreviation input')
    firesignal(box.Focused);box.Text='invalid';firesignal(box.FocusLost,true);task.wait();check(box.Text=='1.25m','invalid restored')
    local track=b.UIElements.SliderIcon
    local x,w,y=track.AbsolutePosition.X,track.AbsoluteSize.X,track.AbsolutePosition.Y
    local touch={UserInputType=Enum.UserInputType.Touch,Position=Vector3.new(x+w*.1,y,0)}
    firesignal(b.UIElements.SliderContainer.InputBegan,touch)
    for _,ratio in ipairs({.001,.1,.25,.5,.75,.999}) do
        touch.Position=Vector3.new(x+w*ratio,y,0);task.wait(.08)
        check(math.abs(track.AbsolutePosition.X-x)<.1 and math.abs(track.AbsoluteSize.X-w)<.1,'stable drag geometry')
        check(math.abs(b:Get()-ratio*1e9)<1e9/w*.01,'linear drag')
    end
    b:Lock();b:Unlock()
    for _,size in ipairs({Vector2.new(560,350),Vector2.new(740,520),Vector2.new(850,560)}) do
        d.Window:SetSize(UDim2.fromOffset(size.X,size.Y));task.wait(.2)
        local desc=b.SliderFrame.UIElements.Desc
        check(desc.AbsolutePosition.X+desc.AbsoluteSize.X<=b.UIElements.SliderContainer.AbsolutePosition.X,'inline text/control separation')
        check(track.AbsoluteSize.X>0,'positive track width')
    end
end)
b:Lock();b:Unlock();b:SetRange(0,1e9);b:Set(500000)
d.Window:SetLockOffscreen(true);d.Window:SetUIScale(1);d.Window:SetPosition(UDim2.fromScale(.5,.5))
d.Window:SetSize(UDim2.fromOffset(740,520));d.Player:Select()
return {status=ok and 'pass' or 'fail',passed=passed,error=not ok and tostring(err) or nil,
    interaction='synthetic GUI signals',sizes='original limits: 560x350, 740x520, 850x560'}
