local d=assert(getgenv().WindUIForkDemo)
local w,p=d.Window,d.Profile
local input=game:GetService('UserInputService')
local passed=0
local function check(v,label)assert(v,label);passed+=1 end
local function near(a,b)return math.abs(a-b)<.002 end
local ok,err=pcall(function()
 p:Close();w:SetUIScale(1);w:SetPosition(UDim2.fromScale(.5,.5));d.Library:SetTheme('Light');task.wait(.3)
 local panel=w.UIElements.MainBar.Background
 local row=d.Themes.Elements[1].ElementFrame
 local title=d.Big.SliderFrame.UIElements.Title
 local textAlpha=title.TextTransparency
 p:SetTransparency(.7);task.wait(.2)
 check(near(w.UIElements.Main.Background.ImageTransparency,.7),'window root alpha')
 check(near(panel.ImageTransparency,.7) and near(panel.BackgroundTransparency,.7),'Light panel now transparent')
 check(near(row.ImageTransparency,.7) and near(row.BackgroundTransparency,.7),'Light element now transparent')
 check(near(p.UIElements.Menu.BackgroundTransparency,.7),'profile background participates')
 check(title.TextTransparency==textAlpha,'text alpha unchanged')
 check(w.UIElements.Main:IsA('Frame') and w.UIElements.Main.Main:IsA('Frame'),'no whole-window group fade')
 for _,theme in ipairs({'Dark','Light','Ocean','Paper'})do
  d.Library:SetTheme(theme);task.wait(.2)
  local base=d.Library:GetThemes()[theme].PanelBackgroundTransparency or .95
  check(near(panel.ImageTransparency,base+(1-base)*.7),'panel alpha preserves theme '..theme)
 end
 d.Library:SetTheme('Light');task.wait(.2);p:Open();task.wait(.3)
 firesignal(p.UIElements.ScaleButton.MouseEnter);task.wait(.25)
 check(near(p.UIElements.ScaleButton.BackgroundTransparency,.7),'hover background remains transparent')
 firesignal(p.UIElements.ScaleButton.MouseLeave);task.wait(.25)
 check(near(p.UIElements.ScaleButton.BackgroundTransparency,1),'idle hover layer stays absent')
 p:Close();p:SetTransparency(0);task.wait(.2)
 check(near(panel.ImageTransparency,0) and near(row.ImageTransparency,0),'zero restores exact Light surface alphas')
 check(p.UIElements.Card.BackgroundTransparency==1,'idle footer remains transparent')
 -- Focus is controlled explicitly: the host may be unfocused during automated QA.
 firesignal(input.WindowFocused)
 local cursor=w.Cursor
 w:SetCustomCursor(false);local native=input.MouseIconEnabled
 w:SetCustomCursor({Enabled=true,Size=10});task.wait(.1)
 local dot=cursor.UIElements.Dot
 check(dot and dot.Visible and not input.MouseIconEnabled,'cursor enabled only while menu visible')
 check(dot.BackgroundColor3==Color3.new(1,1,1)and dot.BackgroundTransparency==0,'cursor filled white')
 check(dot.UICorner.CornerRadius.Scale==1 and dot.AbsoluteSize==Vector2.new(10,10),'cursor is a ten-pixel circle')
 local center=dot.AbsolutePosition-cursor.UIElements.Gui.AbsolutePosition+dot.AbsoluteSize/2
 check((center-input:GetMouseLocation()).Magnitude<1,'cursor matches physical mouse coordinate including GUI origin')
 w:SetUIScale(1.25);task.wait(.15);check(dot.AbsoluteSize==Vector2.new(10,10),'cursor size independent of menu DPI')
 w:SetUIScale(1)
 d.Library.ScreenGui.Enabled=false;task.wait(.1)
 check(not dot.Visible and input.MouseIconEnabled==native,'GUI hide restores native cursor state')
 d.Library.ScreenGui.Enabled=true;task.wait(.1);check(dot.Visible and not input.MouseIconEnabled,'GUI show reacquires circle')
 w:Close();task.wait(.2);check(not dot.Visible and input.MouseIconEnabled==native,'window close restores native cursor')
 w:Open();task.wait(1);check(dot.Visible and not input.MouseIconEnabled,'reopen restores custom cursor')
 w:SetCustomCursor(false);check(not dot.Visible and input.MouseIconEnabled==native,'explicit disable restores previous state')
 w:SetCustomCursor(true)
 w:SetPosition(UDim2.fromScale(.5,.5));w:SetDragSmoothness(.08);task.wait(.1)
 local main=w.UIElements.Main
 local before=main.Position
 local touch={UserInputType=Enum.UserInputType.Touch,Position=Vector3.new(100,100,0)}
 firesignal(main.Main.Topbar.InputBegan,touch)
 touch.Position=Vector3.new(300,100,0);firesignal(input.InputChanged,touch);task.wait(.025)
 local moved=main.Position.X.Offset-before.X.Offset
 check(w.Dragging and moved>0 and moved<200,'smooth drag has intermediate position')
 firesignal(input.InputEnded,touch);task.wait(.8)
 check(not w.Dragging and near(main.Position.X.Offset-before.X.Offset,200),'released drag settles exactly')
 check(w.Position==main.Position,'stored position follows smooth tail')
 w:SetDragSmoothness(0);before=main.Position
 touch={UserInputType=Enum.UserInputType.Touch,Position=Vector3.new(100,100,0)}
 firesignal(main.Main.Topbar.InputBegan,touch);touch.Position=Vector3.new(140,100,0);firesignal(input.InputChanged,touch)
 check(near(main.Position.X.Offset-before.X.Offset,40),'zero smoothness is immediate')
 firesignal(input.InputEnded,touch)
end)
p:SetTransparency(0);p:Close();w:SetCustomCursor({Enabled=true,Size=10});w:SetDragSmoothness(.045);w:SetUIScale(1);d.Library.ScreenGui.Enabled=true;d.Library:SetTheme('Dark');w:SetPosition(UDim2.fromScale(.5,.5));d.Player:Select()
return{status=ok and 'pass' or 'fail',passed=passed,error=not ok and tostring(err)or nil}
