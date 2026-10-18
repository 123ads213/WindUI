-- Synthetic API selection checks, not a physical input-device test.
local d=assert(getgenv().WindUIForkDemo)
local passed=0
local function check(v,label)assert(v,label);passed+=1 end
local ok,err=pcall(function()
 d.Player:Select();task.wait(.3)
 d.World:Select();task.wait(.05)
 local page=d.World.UIElements.ContainerFrameCanvas
 check(page.Visible and page.AnchorPoint.Y>0 and page.AnchorPoint.Y<.05,'intermediate page animation')
 task.wait(.3)
 check(page.AnchorPoint==Vector2.zero,'page animation settles')
 d.World:Select()
 check(page.AnchorPoint==Vector2.zero,'reselect does not restart')
 d.Player:Select();task.wait(.03);d.World:Select();task.wait(.03);d.General:Select();task.wait(.3)
 check(d.General.UIElements.ContainerFrameCanvas.Visible and not page.Visible and not d.Player.UIElements.ContainerFrameCanvas.Visible,'rapid switch ends on latest page')
 d.Themes:Select();task.wait(.3)
 check(d.Appearance.Opened and d.Window.CurrentTab==d.Themes.Index,'theme selection opens actual tab section')
 d.Player:Select();task.wait(.3)
 local frame=d.Big.SliderFrame
 local holder=frame.UIElements.Container.TitleFrame
 local image=holder:FindFirstChild('ElementIcon')
 -- Creator.Image assigns a content name rather than the role on some icon packs.
 if not image then for _,c in ipairs(holder:GetChildren())do if c:IsA('GuiObject') and c.Name~='TitleFrame' then image=c;break end end end
 check(frame.Image=='ruler' and image~=nil and image.Visible,'Distance title icon rendered')
 check(image.AbsoluteSize.X==24 and image.AbsoluteSize.Y==24,'title icon size')
 local title=frame.UIElements.Title
 local block=holder.TitleFrame
 check(math.abs(image.AbsolutePosition.Y+image.AbsoluteSize.Y/2-block.AbsolutePosition.Y-block.AbsoluteSize.Y/2)<1,'icon vertically centred on title and description')
 check(image.AbsolutePosition.X+image.AbsoluteSize.X<=title.AbsolutePosition.X+1,'title follows icon without overlap')
 check(title.AbsolutePosition.X+title.AbsoluteSize.X<=d.Big.UIElements.SliderContainer.AbsolutePosition.X+1,'text ends before numeric control')
end)
return{status=ok and 'pass' or 'fail',passed=passed,error=not ok and tostring(err)or nil}
