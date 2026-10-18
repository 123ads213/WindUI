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
    b:Set(500000);check(b.UIElements.SliderContainer.TextBox.Text=='500k','compact value')
    b:Set(1000000);check(type(d.Calls.Distance)=='number' and d.Calls.Distance==1000000,'numeric callback')
    b:Set(-1);check(b:Get()==0,'minimum clamp')
    b:Set(1e15);check(b:Get()==1e9,'maximum clamp')
    b:Set(0/0);check(b:Get()==1e9,'NaN ignored')
    b:SetRange(5,5);task.wait(.1);check(b:Get()==5 and b.UIElements.SliderIcon.Frame.Size.X.Scale==1,'equal bounds')
    b:SetRange(0,1e9);b:Set(500000);b:Lock();b:Set(1);check(b:Get()==500000,'locked');b:Unlock()
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
d.Window:SetSize(UDim2.fromOffset(740,520));d.Player:Select()
return {status=ok and 'pass' or 'fail',passed=passed,error=not ok and tostring(err) or nil,
    interaction='synthetic GUI signals',sizes='original limits: 560x350, 740x520, 850x560'}
