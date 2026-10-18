local d=assert(getgenv().WindUIForkDemo)
local p=d.Profile
local passed=0
local function check(v,label)assert(v,label);passed+=1 end
local ok,err=pcall(function()
 d.Player:Select();p:Close();task.wait(.3)
 check(d.Billion.SliderFrame.Image=='wallet','Budget icon enabled')
 local h=d.Big.SliderFrame.UIElements.Container.TitleFrame
 local im
 for _,c in ipairs(h:GetChildren())do if c:IsA('Frame')and c.Name~='TitleFrame'then im=c;break end end
 check(im and im.ImageLabel.Position==UDim2.fromOffset(4,-3),'Distance icon right/up offset')
 for _,theme in ipairs({'Dark','Light','Ocean','Paper'})do
  d.Library:SetTheme(theme);task.wait(.2)
  check(p.UIElements.Card.BackgroundTransparency==1,'transparent idle footer '..theme)
  check(im.ImageLabel.ImageColor3==d.Library:GetThemes()[theme].Icon,'title icon follows palette '..theme)
 end
 p:Open();task.wait(.3)
 check(p.UIElements.Menu.BackgroundColor3==d.Library:GetThemes().Paper.Dialog,'popover uses standard dialog surface')
 check(p.UIElements.Menu.UIStroke.Transparency>=.9,'subtle popover outline')
 firesignal(p.UIElements.ScaleButton.MouseButton1Click);task.wait(.2)
 check(p.FlyoutKind=='Scale' and p.UIElements.Flyout.Visible,'compact scale row opens side list')
 firesignal(p.UIElements.ScaleOptions['110%'].Row.MouseButton1Click);task.wait(.3)
 check(p.ScaleControl.Value=='110%' and math.abs(d.Library.UIScaleObj.Scale-1.1)<.001,'scale list click applies DPI')
 p.ScaleControl:Select('100%');task.wait(.3)
 d.Library:SetTheme('Light')
 local note=d.Library:Notify({Title='Link copied',Content='Discord store link copied to clipboard.',Icon='clipboard-check',IconSize=36,Duration=2})
 task.wait(.6)
 local icon=note.UIElements.Icon
 check(icon.AbsoluteSize.X==36 and icon.AbsoluteSize.Y==36,'notification icon is large')
 check(icon.ImageLabel.ImageColor3==d.Library:GetThemes().Light.Text,'notification icon contrast in Light')
 local body=note.UIElements.Main
 check(math.abs(icon.AbsolutePosition.Y+icon.AbsoluteSize.Y/2-body.AbsolutePosition.Y-body.AbsoluteSize.Y/2)<1,'notification icon centred on title/body')
 check(icon.AbsolutePosition.X+icon.AbsoluteSize.X<note.UIElements.TextContainer.AbsolutePosition.X+14,'notification icon/text separation')
end)
p:Close();d.Library:SetTheme('Dark');d.Player:Select()
return{status=ok and 'pass' or 'fail',passed=passed,error=not ok and tostring(err)or nil}
