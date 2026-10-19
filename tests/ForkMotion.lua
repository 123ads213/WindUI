-- Live UI animation, long color preview, shadow and split HUD surface regression.
local d=assert(getgenv().WindUIForkDemo);local w=d.Window;local f=w.FeatureUI;local t=d.ShowPlayers
local saved={Keys=t:GetHotkeys(),Value=t.Value,Theme=d.Library:GetCurrentTheme(),Tab=w.TabModule.SelectedTab,Color=d.GradientColor:Export(),HUD=d.HUD:Export()}
local passed=0;local function check(v,msg)assert(v,msg);passed+=1 end
local ok,err=pcall(function()
 w:Open();d.Profile:Close();d.Player:Select();d.Library:SetTheme('Dark')
 t:SetHotkeys({{Key='K',Mode='Toggle',Value=true}});t:OpenHotkeys(Vector2.new(1700,480));task.wait(.65)
 local c=f.UIElements.Context;local id=t.HotkeyEntry.Bindings[1].Id;local stable=c.Bindings:FindFirstChild('Binding_'..id)
 firesignal(c.NewHotkey.MouseButton1Click)
 local added=t.HotkeyEntry.Bindings[2].Id;local row=c.Bindings:FindFirstChild('Binding_'..added)
 check(row and row.GroupTransparency==1,'new row starts invisible');check(stable==c.Bindings:FindFirstChild('Binding_'..id),'old row is retained')
 task.wait(.05);check(row.GroupTransparency>0 and row.GroupTransparency<1 and row.Size.Y.Offset>0 and row.Size.Y.Offset<38,'new row interpolates opacity and height')
 check(c.Size.Y.Offset>188 and c.Size.Y.Offset<226,'panel grows smoothly')
 task.wait(.65);check(row.GroupTransparency==0 and row.Size.Y.Offset==38,'new row reaches full size')
 firesignal(f.UIElements.Editor.Delete.MouseButton1Click)
 check(row.Parent~=nil,'delete retains row for animation');task.wait(.05)
 check(row.GroupTransparency>0 and row.GroupTransparency<1 and row.Size.Y.Offset<38,'delete fades and collapses')
 task.wait(.65);check(row.Parent==nil and #t:GetHotkeys()==1,'deleted row cleaned up')
 for i=1,6 do firesignal(c.NewHotkey.MouseButton1Click)end;task.wait(.65)
 check(#t:GetHotkeys()==7 and c.Bindings.AbsoluteCanvasSize.Y>c.Bindings.AbsoluteSize.Y,'animated list still scrolls')
 local shadow=c.Parent:FindFirstChild('FeatureHotkeysShadow')
 check(shadow and shadow.Visible and shadow.ImageTransparency<.4 and shadow.ImageColor3==Color3.new(0,0,0),'dark hotkey panel shadow is strong and visible')
 f:CloseAll();d.Themes:Select();task.wait(.4)
 local e=d.GradientColor:Open();task.wait(.3)
 for _,fmt in ipairs({'HEX','RGB','HSV','HSL'})do
  e.Format=fmt;e:Refresh();task.wait(.03)
  local input,preview=e.UIElements.ColorText,e.UIElements.ColorPreview
  check(preview.Visible and input.TextTransparency==1 and preview.Text==input.Text,'complete underlying data with preview '..fmt)
  check(preview.TextTruncate==Enum.TextTruncate.AtEnd and input.ClipsDescendants and preview.ClipsDescendants,'all formats ellipsize and clip '..fmt)
  local before=input.Text;input:CaptureFocus();task.wait(.05)
  check(not preview.Visible and input.TextTransparency==0 and input.Text==before,'focus exposes full editable '..fmt)
  input:ReleaseFocus();task.wait(.08)
  check(preview.Visible and input.Text==before,'blur retains exact color '..fmt)
 end
 local cs=e.UIElements.Panel.Parent:FindFirstChild('GradientColorpickerShadow');check(cs and cs.Visible and cs.ImageTransparency<.45,'color panel shadow visible')
 e:Close();d.HUD:SetKeylistEnabled(true);d.HUD.Drag:SetState('Keylist',{X=.2,Y=.3,Anchor=0});t:SetHotkeys({{Key='Unbound',Mode='Always',Value=true}});task.wait(.7)
 local h=d.HUD;local r=h.Rows[tostring(t.HotkeyEntry.Bindings[1].Id)]
 check(h.UIElements.Header.Size.X.Offset>=140,'header extended')
 check(h.UIElements.Body.Position.Y.Offset==32,'rows moved closer to header')
 check(r.IndicatorSurface.Size==UDim2.fromOffset(30,30)and r.NameSurface.Position.X.Offset==34,'separate indicator square and name plate')
 check(r.NameSurface.Size.X.Offset==r.Label.Size.X.Offset+16,'name plate fits text with padding')
 check(r.IndicatorSurface.BackgroundColor3==Color3.new(0,0,0)and r.NameSurface.BackgroundColor3==Color3.new(0,0,0),'dark surfaces are black')
 d.Library:SetTheme('Light');task.wait(.15);check(r.IndicatorSurface.BackgroundColor3==d.Library:GetThemes().Light.Dialog,'surfaces follow Light theme')
end)
f:CloseAll();if d.GradientColor.Editor then d.GradientColor.Editor:Close()end
d.GradientColor:Import(saved.Color);t:SetHotkeys(saved.Keys);t:Set(saved.Value);d.HUD:Import(saved.HUD);d.Library:SetTheme(saved.Theme);w:SelectTab(saved.Tab)
return {status=ok and'pass'or'fail',passed=passed,error=not ok and tostring(err)or nil}
