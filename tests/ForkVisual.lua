-- Run after the current ForkExample in a modern Roblox client.
local d=assert(getgenv().WindUIForkDemo)
local passed=0
local function check(v,label)assert(v,label);passed+=1 end
local function guiCount(frame)
 local n=0;for _,c in ipairs(frame:GetChildren())do if c:IsA('GuiObject')then n+=1 end end;return n
end
local rows=d.Themes.Elements
local first,last=rows[1].ElementFrame,rows[#rows].ElementFrame
local before=guiCount(first)
local ok,err=pcall(function()
 d.Themes:Select()
 for _,theme in ipairs({'Light','Paper','Dark','Ocean','Forest','Ember','Orchid','Light'})do
  d.Library:SetTheme(theme);task.wait(.2)
  local clean=theme~='Dark'
  check(d.Window.UIElements.MainBar.Background:GetAttribute('WindUICleanShape')==clean,'background renderer '..theme)
  check(guiCount(first)==before,'no extra layout children '..theme)
  check(first.AbsoluteSize.Y<100 and first.AbsoluteSize.Y>20,'row height '..theme)
  check(d.Themes.UIElements.Main.AbsoluteSize.Y<60,'sidebar height '..theme)
  if clean then
   check(first.Image=='' and last.Image=='','light fill has no baked texture')
   check(first.CleanCorner.TopLeftRadius.Offset>0 and first.CleanCorner.BottomLeftRadius.Offset==0,'joined first row corners')
   check(last.CleanCorner.TopLeftRadius.Offset==0 and last.CleanCorner.BottomLeftRadius.Offset>0,'joined last row corners')
   for _,node in ipairs({d.Window.UIElements.MainBar.Background,first,last})do
    check(node.BackgroundColor3==node.ImageColor3 and node.BackgroundTransparency==node.ImageTransparency,'native fill follows theme')
   end
  else check(first.Image~='','original dark fill restored') end
 end
 local toggle=rows[2]
 local knob
 for _,c in ipairs(toggle.ToggleFrame.UIElements.Main:GetChildren())do
  local t=c:FindFirstChild('ToggleFrame');if t then knob=t.Frame.Bar;break end
 end
 check(knob~=nil,'toggle knob found')
 for _,value in ipairs({false,true,false,true})do
  toggle:Set(value,false,true);task.wait(.15)
  check(knob:GetAttribute('WindUICleanShape') and knob.Image=='','clean native knob')
  check(not knob.Highlight.SquircleGlass.Visible and not knob.Highlight.Glass.Visible,'no resting glass fringe')
 end
 d.Window:SetPosition(UDim2.fromOffset(-10000,-10000));task.wait(.1)
 local origin=d.Library.ScreenGui.AbsolutePosition
 local main=d.Window.UIElements.Main
 check(math.abs(main.AbsolutePosition.Y-origin.Y)<.5,'top equals actual GUI origin, not zero')
 d.Window:SetPosition(UDim2.fromOffset(10000,10000));task.wait(.1)
 check(math.abs(main.AbsolutePosition.Y+main.AbsoluteSize.Y-origin.Y-d.Library.ScreenGui.AbsoluteSize.Y)<.5,'bottom equals same viewport rectangle')
end)
d.Window:SetPosition(UDim2.fromScale(.5,.5))
return{status=ok and 'pass' or 'fail',passed=passed,error=not ok and tostring(err)or nil}
