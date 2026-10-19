-- UI copy/paste regression. Does not overwrite the user's OS clipboard.
local d=assert(getgenv().WindUIForkDemo)
local input=game:GetService('UserInputService')
local solid,gradient=d.SolidColor,d.GradientColor
local savedSolid,savedGradient=solid:Export(),gradient:Export()
local savedClipboard=d.Library.ColorClipboard
local savedTheme=d.Library:GetCurrentTheme()
local savedTab=d.Window.TabModule.SelectedTab
local passed=0
local function check(v,label)assert(v,label);passed+=1 end
local function near(a,b)return math.abs(a-b)<.00001 end
local function rgb(c,r,g,b)return near(c.R,r/255)and near(c.G,g/255)and near(c.B,b/255)end
local ok,err=pcall(function()
 d.Themes:Select();task.wait(.4)
 local e=solid:Open();task.wait(.2)
 e.Format='HEX';e:Refresh()
 e.UIElements.ColorText.Text='#12AB347F'
 firesignal(e.UIElements.ColorText.InputBegan,{UserInputType=Enum.UserInputType.Keyboard,KeyCode=Enum.KeyCode.Return})
 check(rgb(solid.Default,18,171,52)and near(solid.Transparency,128/255),'Enter commits HEX and alpha')
 check(e:Copy(true),'copy to menu clipboard without OS setter')
 local target=gradient:Open();target.Selected=2;target.Format='RGB';target:Refresh()
 local otherBefore=gradient:Export().Stops[1].Color
 check(target:Paste(),'one-click Paste uses menu clipboard without getclipboard')
 local stop=gradient:GetValue().Stops[2]
 check(rgb(stop.Color,18,171,52)and near(stop.Transparency,128/255),'cross-editor Paste preserves color and alpha')
 check(gradient:Export().Stops[1].Color==otherBefore,'Paste changes only selected gradient stop')
 target.Format='HSL';target:Refresh();check(target:Paste('FF800080'),'plain HEX pasted under HSL mode')
 check(rgb(gradient:GetValue().Stops[2].Color,255,128,0),'plain HEX autodetected')
 target.Format='HEX';check(target:Paste('rgba(255, 0, 128, 0.25)'),'RGBA pasted under HEX mode')
 check(near(gradient:GetValue().Stops[2].Transparency,.75),'RGBA alpha retained')
 local before=gradient:Export();check(not target:Paste('not a color'),'invalid paste rejected');task.wait(.08)
 check(target.UIElements.Status.Visible and target.UIElements.Status.Text~='','invalid paste has visible feedback')
 check(gradient:Export().Stops[2].Color==before.Stops[2].Color,'invalid paste leaves color unchanged')
 -- No internal color available: Paste must focus/select the actual field after menu closes.
 d.Library.ColorClipboard=nil;target.Format='HEX';target:Refresh()
 local chip=target.UIElements.Stops.Stop_2;firesignal(chip.MouseButton2Click);task.wait(.2)
 firesignal(target.UIElements.Paste.MouseButton1Click);task.wait(.25)
 check(target.Opened and target.UIElements.ColorText:IsFocused(),'fallback Paste retains TextBox focus')
 check(not target.UIElements.Actions.Visible,'Copy/Paste context closes after selection')
 check(target.UIElements.ColorText.SelectionStart==1,'fallback selects the whole old color')
 target.UIElements.ColorText.Text='#00CC66FF'
 target.UIElements.ColorText:ReleaseFocus(true);task.wait(.15)
 check(rgb(gradient:GetValue().Stops[2].Color,0,204,102),'fallback pasted text applies on Enter/FocusLost')
 -- Real focused keyboard Enter should apply the same path, not only direct method calls.
 target.UIElements.ColorText:CaptureFocus();task.wait(.05);target.UIElements.ColorText.Text='#44556680'
 local vim=game:GetService('VirtualInputManager')
 vim:SendKeyEvent(true,Enum.KeyCode.Return,false,game);vim:SendKeyEvent(false,Enum.KeyCode.Return,false,game);task.wait(.25)
 check(rgb(gradient:GetValue().Stops[2].Color,68,85,102),'real Enter event applies pasted color')
 check(near(gradient:GetValue().Stops[2].Transparency,127/255),'real Enter applies alpha')
end)
if solid.Editor then solid.Editor:Close()end;if gradient.Editor then gradient.Editor:Close()end
solid:Import(savedSolid);gradient:Import(savedGradient);d.Library.ColorClipboard=savedClipboard
d.Library:SetTheme(savedTheme);d.Window:SelectTab(savedTab)
return {status=ok and'pass'or'fail',passed=passed,error=not ok and tostring(err)or nil}
