-- Focused synthetic GUI/API checks. No claim of a physical input-device matrix.
local d=assert(getgenv().WindUIForkDemo)
local p=d.Profile
local passed=0
local function check(v,label)assert(v,label);passed+=1 end
local ok,err=pcall(function()
 d.Window:SetUIScale(1);d.Window:SetSize(UDim2.fromOffset(740,520));d.Window:SetPosition(UDim2.fromScale(.5,.5));d.Player:Select()
 p:Open();task.wait(.3);firesignal(p.UIElements.Menu.MouseEnter)
 local gear,hint=false,false
 for _,c in ipairs(p.UIElements.StyleButton:GetChildren())do
  if c:IsA('Frame')then gear=gear or c.Position.X.Offset==230;hint=hint or c.Position.X.Offset==252 end
 end
 check(not gear,'Style gear removed')
 check(hint,'Style hover hint retained')
 check(p.UIElements.Menu.Size.Y.Offset==304,'longer preferences panel')
 check(p.UIElements.Menu.AbsolutePosition.Y+p.UIElements.Menu.AbsoluteSize.Y>d.Window.UIElements.Main.AbsolutePosition.Y+d.Window.UIElements.Main.AbsoluteSize.Y,'floating panel may extend below main window')
 check(p.UIElements.HistoryButton.Position.Y.Offset>p.UIElements.TransparencyButton.Position.Y.Offset,'History last')
 local track,hit,tip=p.UIElements.TransparencyTrack,p.UIElements.TransparencyInput,p.UIElements.TransparencyTooltip
 check(#track:GetChildren()==2 and track:FindFirstChild('Fill')~=nil,'bar only: no thumb object')
 check(not tip.Visible,'numeric value hidden at rest')
 firesignal(hit.MouseEnter);task.wait(.15)
 check(tip.Visible and tip.TextTransparency==0,'hover reveals value')
 local touch={UserInputType=Enum.UserInputType.Touch,Position=Vector3.new(track.AbsolutePosition.X+track.AbsoluteSize.X*.7,track.AbsolutePosition.Y,0)}
 firesignal(hit.InputBegan,touch);task.wait(.1)
 check(p:GetTransparency()==.7 and tip.Text=='0.7','track interaction gives 0.7')
 check(math.abs(d.Window.UIElements.Main.Background.ImageTransparency-.7)<.001,'actual WindUI transparency applied')
 touch.Position=Vector3.new(track.AbsolutePosition.X+track.AbsoluteSize.X*2,track.AbsolutePosition.Y,0)
 firesignal(game:GetService('UserInputService').InputChanged,touch);task.wait(.05)
 check(p:GetTransparency()==1,'drag beyond track clamps maximum')
 firesignal(game:GetService('UserInputService').InputEnded,touch)
 check(d.Library.CurrentInput==nil,'release clears input ownership')
 firesignal(hit.MouseLeave);task.wait(.2);check(not tip.Visible,'value hides after leaving')
 p:SetTransparency(-5);check(p:GetTransparency()==0 and not d.Window.Transparent,'zero restores opaque window')
 for _,scale in ipairs({.75,1,1.25})do
  d.Window:SetUIScale(scale);task.wait(.2);p:SetTransparency(.7)
  check(math.abs(p.UIElements.TransparencyFill.AbsoluteSize.X/track.AbsoluteSize.X-.7)<.02,'bar ratio remains stable at DPI '..scale)
 end
 d.Window:SetUIScale(1);p:SetTransparency(0)
 for _,theme in ipairs({'Dark','Light','Ocean','Forest','Ember','Orchid','Paper'})do
  d.Library:SetTheme(theme);task.wait(.1)
  check(p.UIElements.TransparencyFill.BackgroundColor3==d.Library:GetThemes()[theme].Slider,'bar follows theme '..theme)
 end
 d.Window:SetPosition(UDim2.fromOffset(100000,100000));task.wait(.2)
 local menu,gui=p.UIElements.Menu,d.Library.ScreenGui
 check(menu.AbsolutePosition.Y+menu.AbsoluteSize.Y<=gui.AbsolutePosition.Y+gui.AbsoluteSize.Y,'long panel stays inside viewport bottom')
 p:Close();d.Window:SetPosition(UDim2.fromScale(.5,.5));d.Library:SetTheme('Dark');task.wait(.3)
 local sidebar=d.Window.UIElements.SideBarContainer
 local search
 for _,c in ipairs(sidebar:GetChildren())do
  if c:IsA('TextButton') then local box=c:FindFirstChildWhichIsA('TextLabel',true);if box and box.Text=='Search'then search=c end end
 end
 check(not d.Window.HideSearchBar and search and search.Visible,'original WindUI Search enabled')
 check(search.AbsolutePosition.Y+search.AbsoluteSize.Y<=d.Visuals.UIElements.Main.AbsolutePosition.Y,'Search above COMMON and tabs')
 local main=d.Window.UIElements.Main
 local before={};for _,c in ipairs(main:GetChildren())do before[c]=true end
 firesignal(search.MouseButton1Click);task.wait(.35)
 local container
 for _,c in ipairs(main:GetChildren())do if not before[c] and c:IsA('Frame')then container=c end end
 check(container and container.Visible,'native search opens')
 local input=container:FindFirstChildWhichIsA('TextBox',true)
 check(input and input.PlaceholderText=='Search...','original search input')
 input.Text='Distance';task.wait(.4)
 local results=container:FindFirstChild('Results',true)
 local scroll=results and results:FindFirstChildWhichIsA('ScrollingFrame')
 local parentRow
 for _,c in ipairs(scroll:GetChildren())do if c:IsA('TextButton')then parentRow=c;break end end
 check(parentRow~=nil,'search finds nested Player element')
 local element
 for _,row in ipairs(parentRow.ParentContainer.Frame:GetChildren())do if row:IsA('TextButton')then local title=row:FindFirstChild('Title',true);if title and title.Text=='Distance'then element=row end end end
 check(element and element.Main:FindFirstChild('Title',true).Text=='Distance','Distance result title')
 d.World:Select();firesignal(element.Main.MouseButton1Click);task.wait(.4)
 check(d.Window.CurrentTab==d.Player.Index and d.Visuals.SubTabsOpened,'result routes into nested Player')
 p:Open();task.wait(.3)
 touch.Position=Vector3.new(track.AbsolutePosition.X+track.AbsoluteSize.X*.5,track.AbsolutePosition.Y,0)
 firesignal(hit.InputBegan,touch);p:Close();task.wait(.25)
 check(not p.UIElements.Menu.Visible and d.Library.CurrentInput==nil,'closing during drag releases ownership and hides popup')
end)
p:SetTransparency(0);p:Close();d.Library:SetTheme('Dark');d.Window:SetUIScale(1);d.Window:SetPosition(UDim2.fromScale(.5,.5));d.Player:Select()
return{status=ok and 'pass' or 'fail',passed=passed,error=not ok and tostring(err)or nil}
