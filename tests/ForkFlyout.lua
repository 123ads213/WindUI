local d=assert(getgenv().WindUIForkDemo)
local p=d.Profile
local passed=0
local function check(v,label)assert(v,label);passed+=1 end
local ok,err=pcall(function()
 p:Open();task.wait(.3)
 firesignal(p.UIElements.Menu.MouseEnter)
 firesignal(p.UIElements.ScaleButton.MouseEnter);task.wait(.05)
 check(p.FlyoutKind=='Scale' and p.UIElements.Flyout.Visible,'scale hover opens flyout')
 check(p.UIElements.Flyout.GroupTransparency>0 and p.UIElements.Flyout.GroupTransparency<1,'side list fade has intermediate opacity')
 task.wait(.3)
 check(p.UIElements.Pages.Main.Visible,'main menu not replaced')
 check(p.UIElements.Flyout.AbsolutePosition.X>=p.UIElements.Menu.AbsolutePosition.X+p.UIElements.Menu.AbsoluteSize.X,'side list opens to right when space exists')
 firesignal(p.UIElements.ScaleButton.MouseLeave);firesignal(p.UIElements.Flyout.MouseEnter);task.wait(.3)
 check(p.FlyoutKind=='Scale','pointer transfer keeps flyout open')
 firesignal(p.UIElements.ScaleOptions['75%'].Row.MouseButton1Click);task.wait(.3)
 check(math.abs(d.Library.UIScaleObj.Scale-.75)<.001,'hover option click changes DPI')
 p.ScaleControl:Select('100%');task.wait(.3)
 firesignal(p.UIElements.Flyout.MouseLeave);firesignal(p.UIElements.StyleButton.MouseEnter);task.wait(.3)
 check(p.FlyoutKind=='Style' and p.UIElements.Pages.Main.Visible,'style hover opens side list without replacing main')
 firesignal(p.UIElements.ThemeOptions.Light.Row.MouseButton1Click);task.wait(.2)
 check(d.Library:GetCurrentTheme()=='Light' and d.Themes.Elements[1].Value=='Light','theme flyout selection syncs theme')
 local holder=d.Big.SliderFrame.UIElements.Container.TitleFrame
 for _,c in ipairs(holder:GetChildren())do
  if c:IsA('Frame')and c.Name~='TitleFrame'then check(c.ImageLabel.ImageColor3==d.Library:GetThemes().Light.Icon,'Distance icon visible in Light')end
 end
 d.Window:SetPosition(UDim2.fromOffset(100000,100000));task.wait(.2)
 local f=p.UIElements.Flyout
 local o,v=d.Library.ScreenGui.AbsolutePosition,d.Library.ScreenGui.AbsoluteSize
 check(f.AbsolutePosition.X>=o.X and f.AbsolutePosition.X+f.AbsoluteSize.X<=o.X+v.X,'flyout stays inside viewport at right edge')
 check(f.AbsolutePosition.Y>=o.Y and f.AbsolutePosition.Y+f.AbsoluteSize.Y<=o.Y+v.Y,'flyout stays inside viewport at bottom edge')
 p:Renew();task.wait(.2)
 check(p.LastRenewNotification and p.LastRenewNotification.Title=='Link copied','Renew notification is English')
 check(p.LastRenewNotification.Content=='Discord store link copied to clipboard.','Renew body is English')
end)
p.ScaleControl:Select('100%');p:Close();d.Library:SetTheme('Dark');d.Window:SetPosition(UDim2.fromScale(.5,.5));d.Player:Select()
return{status=ok and 'pass' or 'fail',passed=passed,error=not ok and tostring(err)or nil}
