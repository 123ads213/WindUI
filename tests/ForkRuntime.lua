-- Run AFTER ForkExample.lua, in a Roblox executor with firesignal.
-- Mutates only this example's controls and restores the default state.
local d = assert(getgenv().WindUIForkDemo, 'Run ForkExample.lua first')
local b = d.Big
local passed = 0
local function check(value, label) assert(value, label); passed += 1 end
local ok, err = pcall(function()
    b:Set(500000); check(b.UIElements.SliderContainer.TextBox.Text == '500k', 'compact')
    b:Set(1000000); check(type(d.Calls.Distance) == 'number' and d.Calls.Distance == 1000000, 'numeric callback')
    b:Set(-1); check(b:Get() == 0, 'minimum clamp')
    b:Set(1e15); check(b:Get() == 1e9, 'maximum clamp')
    b:Set(0/0); check(b:Get() == 1e9, 'NaN ignored')
    b:SetRange(5,5); task.wait(.1); check(b:Get()==5 and b.UIElements.SliderIcon.Frame.Size.X.Scale==1,'equal range')
    b:SetRange(1000,0); check(b.Value.Min==0 and b.Value.Max==1000,'reversed bounds')
    b:SetRange(0,1e9); b:Set(500000); b:Lock(); b:Set(1); check(b:Get()==500000,'locked'); b:Unlock()
    d.Fine:Set(.54321); d.Fine:Set(.12345)
    check(type(d.Calls.Fine)=='number' and math.abs(d.Calls.Fine-.12345)<1e-12,'fractional callback precision')
    check(d.Fine.UIElements.SliderContainer.TextBox.Text=='0.12345','no decimal noise')
    assert(firesignal, 'firesignal required for interaction regression')
    local box=b.UIElements.SliderContainer.TextBox
    firesignal(box.Focused); check(tonumber(box.Text)==500000,'full value on focus')
    box.Text='1.25m'; firesignal(box.FocusLost,true); task.wait(); check(b:Get()==1250000,'abbreviation input')
    firesignal(box.Focused); box.Text='invalid'; firesignal(box.FocusLost,true); task.wait()
    check(box.Text=='1.25m','invalid input restored')
    firesignal(box.Focused); box.Text='1250000'; firesignal(box.FocusLost,true); task.wait()
    check(box.Text=='1.25m','unchanged input restored')
    local track=b.UIElements.SliderIcon
    local x,w,y=track.AbsolutePosition.X,track.AbsoluteSize.X,track.AbsolutePosition.Y
    local touch={UserInputType=Enum.UserInputType.Touch, Position=Vector3.new(x+w*.1,y,0)}
    firesignal(b.UIElements.SliderContainer.InputBegan,touch)
    for _, ratio in ipairs({.001,.02,.1,.25,.5,.75,.999}) do
        touch.Position=Vector3.new(x+w*ratio,y,0); task.wait(.08)
        check(math.abs(track.AbsolutePosition.X-x)<.1 and math.abs(track.AbsoluteSize.X-w)<.1,'stable drag geometry')
        -- Vector3 pointer coordinates are float32, so compare within one subpixel of the range.
        check(math.abs(b:Get()-ratio*1e9)<1e9/w*.01,'linear drag')
    end
    b:Lock();b:Unlock()
    for _,size in ipairs({Vector2.new(600,400),Vector2.new(900,740),Vector2.new(1200,900)}) do
        d.Window:SetSize(UDim2.fromOffset(size.X,size.Y)); task.wait(.2)
        local e=b.SliderFrame.UIElements
        check(e.Desc.AbsolutePosition.Y+e.Desc.AbsoluteSize.Y<=b.UIElements.SliderContainer.AbsolutePosition.Y,'no description overlap')
        check(track.AbsoluteSize.X>0,'positive responsive track width')
    end
end)
b:Lock();b:Unlock();b:SetRange(0,1e9);b:Set(500000)
d.Window:SetSize(UDim2.fromOffset(900,740))
return {status=ok and 'pass' or 'fail',passed=passed,error=not ok and tostring(err) or nil,
    interaction='synthetic GUI signals; not physical mouse drag',sizes='600x400, 900x740, 1200x900'}
