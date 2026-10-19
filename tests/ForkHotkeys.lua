-- Synthetic UI/API checks. Only a unique, temporary QA config is written/deleted.
local d=assert(getgenv().WindUIForkDemo)
local w,f,t=d.Window,d.Window.FeatureUI,d.ShowPlayers
local input=game:GetService('UserInputService')
local passed=0
local function check(v,msg)assert(v,msg);passed+=1 end
local saved=t:GetHotkeys();local savedValue=t.Value
local qaConfig
local previousConfig=w.CurrentConfig
local cleanupConfig
local ok,err=pcall(function()
 d.Profile:Close();d.Library:SetTheme('Dark');d.Profile:SetTransparency(0);d.Player:Select();task.wait(.3)
 check(not d.Big.SliderFrame.UIElements.Desc.Visible,'inline description removed')
 firesignal(d.Big.ElementFrame.MouseEnter);task.wait(.5)
 check(f.UIElements.Tooltip.Visible and f.UIElements.TooltipBody.Text==d.Big.Desc,'hover description text')
 check(f.UIElements.TooltipTitle.Text=='Distance'and f.UIElements.TooltipBody.TextSize==14,'title and readable body')
 firesignal(d.Big.ElementFrame.MouseLeave);task.wait(.2);check(not f.UIElements.Tooltip.Visible,'leave fades tooltip')
 local original=d.Big.Desc;d.Big:SetDesc('Updated hover description.');d.Big:ShowDescription();task.wait(.15)
 check(f.UIElements.TooltipBody.Text=='Updated hover description.'and not d.Big.SliderFrame.UIElements.Desc.Visible,'SetDesc preserves tooltip mode');d.Big:SetDesc(original);f:HideDescription()
 firesignal(t.ElementFrame.MouseButton2Click);task.wait(.2)
 check(f.UIElements.Context.Visible,'right-click opens feature context')
 local context=f.UIElements.Context
 check(#t:GetHotkeys()==2,'multiple initial bindings')
 local row=context.Bindings:FindFirstChild('Binding_'..t.HotkeyEntry.Bindings[1].Id)
 firesignal(row.MouseEnter);task.wait(.2)
 check(f.UIElements.Editor.Visible and f.UIElements.Context.Visible,'hover side editor preserves first list')
 check(f.UIElements.Editor:FindFirstChild('Visible')==nil,'no Visible control')
 local vt=f.UIElements.Editor.Value.ValueToggle
 check(vt.AbsoluteSize.X==40 and vt.Thumb.AbsoluteSize.X==18,'native clean Value toggle')
 firesignal(f.UIElements.Editor.Value.MouseButton1Click);check(t:GetHotkeys()[1].Value==false,'Value toggle changes boolean')
 firesignal(f.UIElements.Editor.Mode.MouseEnter);task.wait(.2);check(f.UIElements.Modes.Visible,'mode hover list')
 firesignal(f.UIElements.Modes.Hold.MouseButton1Click);check(t:GetHotkeys()[1].Mode=='Hold','mode selection')
 firesignal(f.UIElements.Editor.Key.MouseButton1Click);check(f.Picking~=nil,'capture started')
 firesignal(input.InputBegan,{UserInputType=Enum.UserInputType.Keyboard,KeyCode=Enum.KeyCode.Escape,Position=Vector3.zero},false)
 check(f.Picking==nil and t:GetHotkeys()[1].Key=='K','Escape cancels capture without key mutation')
 firesignal(f.UIElements.Editor.Key.MouseButton1Click)
 firesignal(input.InputBegan,{UserInputType=Enum.UserInputType.Keyboard,KeyCode=Enum.KeyCode.F9,Position=Vector3.zero},false)
 check(t:GetHotkeys()[1].Key=='F9'and f.Picking==nil,'capture updates selected binding')
 firesignal(context.NewHotkey.MouseButton1Click);check(#t:GetHotkeys()==3,'new binding appended')
 firesignal(f.UIElements.Editor.Delete.MouseButton1Click);check(#t:GetHotkeys()==2,'delete only selected binding')
 t:SetHotkeys({{Key='K',Mode='Toggle',Value=false},{Key='L',Mode='Hold',Value=true}});f:CloseAll();task.wait(.2)
 local m=f.Model
 t:Set(true);m:Input('K',true);check(not t.Value,'Toggle Disabled first press');m:Input('K',false);m:Input('K',true);check(t.Value,'Toggle Disabled second press');m:Input('K',false)
 m:Input('L',true);check(t.Value,'Hold enabled down');m:Input('L',false);check(not t.Value,'Hold enabled release')
 t:Set(false);m:Input('K',true,true);check(not t.Value,'processed input ignored')
 t:Lock();m:Input('L',true);check(not t.Value,'locked toggle ignores bindings');t:Unlock();m:Input('L',false)
 m:Input('L',true);m:Blur();check(not t.Value,'blur releases Hold')
 t:SetHotkeys({{Key='K',Mode='Always',Value=true}});check(t.Value,'Always applies immediately');t:Set(false);task.wait(.12);check(t.Value,'Always enforces after manual change')
 t:SetHotkeys({{Key='K',Mode='Toggle',Value=false},{Key='L',Mode='Hold',Value=true}});t:Set(false)
 local cm=assert(w.ConfigManager);previousConfig=w.CurrentConfig
 local name='__fork9_qa_'..d.Library.GenerateGUID();qaConfig=cm:CreateConfig(name);cleanupConfig=function()qaConfig:Delete();cm.Configs[name]=nil;w.CurrentConfig=previousConfig end
 qaConfig:Register('qa_toggle',t);qaConfig:Register('qa_slider',d.Big)
 local out=qaConfig:Save();check(out.__elements.qa_toggle.value==false and #out.__elements.qa_toggle.hotkeys==2,'Save retains false value and all bindings')
 local json=game:GetService('HttpService'):JSONDecode(readfile(qaConfig.Path));check(json.__elements.qa_toggle.hotkeys[1].Value==false and json.__elements.qa_toggle.hotkeys[2].Mode=='Hold','actual JSON preserves false/mode')
 t:ResetHotkeys();t:Set(true);d.Big:Set(123);qaConfig:Load();task.wait(.25)
 check(not t.Value and #t:GetHotkeys()==2 and t:GetHotkeys()[1].Value==false,'actual file Load round trip')
 check(d.Big:Get()==500000,'ordinary slider value still loads')
 local parser=cm.Parser.Toggle;t:SetHotkeys(saved);parser.Load(t,{__type='Toggle',value=false});check(not t.Value and #t:GetHotkeys()==#saved,'legacy config loads without erasing configured hotkeys')
 t:OpenHotkeys(Vector2.new(1650,650));task.wait(.2);firesignal(f.UIElements.Context.Reset.MouseButton1Click);check(#t:GetHotkeys()==0,'Reset removes every feature binding')
 for i=1,10 do t:AddHotkey({Key='F'..i,Mode=i%2==0 and'Hold'or'Toggle',Value=i%2==0})end
 w:ShowHotkeys();task.wait(.25)
 check(f.UIElements.All.Visible and f.UIElements.All.Entries.AutomaticCanvasSize==Enum.AutomaticSize.Y,'All Hotkeys scrollable')
 check(#f.UIElements.All.Entries:GetChildren()==10,'all feature bindings listed')
 check(f.UIElements.All.Entries.AbsoluteCanvasSize.Y>f.UIElements.All.Entries.AbsoluteSize.Y,'large list actually scrolls')
 firesignal(f.UIElements.All.Close.MouseButton1Click);task.wait(.2);check(not f.UIElements.All.Visible,'All Hotkeys closes')
 for _,theme in ipairs({'Dark','Light','Ocean','Forest','Ember','Orchid','Paper'})do
  d.Library:SetTheme(theme);t:OpenHotkeys(Vector2.new(1650,650));f:Edit(t.HotkeyEntry,t.HotkeyEntry.Bindings[1],context);task.wait(.15)
  check(context.BackgroundColor3==d.Library:GetThemes()[theme].Dialog and f.UIElements.Editor.Key.Label.TextColor3==d.Library:GetThemes()[theme].Text,'popup contrast follows '..theme)
 end
 for _,s in ipairs({.75,1,1.25})do
  w:SetUIScale(s);task.wait(.15);local origin=d.Library.ScreenGui.AbsolutePosition;local z=d.Library.ScreenGui.AbsoluteSize
  t:OpenHotkeys(origin+z-Vector2.new(4,4));f:Edit(t.HotkeyEntry,t.HotkeyEntry.Bindings[1],context);task.wait(.15)
  local good=true;for _,p in ipairs({context,f.UIElements.Editor})do local a,b=p.AbsolutePosition,p.AbsoluteSize;good=good and a.X>=origin.X and a.Y>=origin.Y and a.X+b.X<=origin.X+z.X+1 and a.Y+b.Y<=origin.Y+z.Y+1 end
  check(good,'context/editor viewport bounds at DPI '..s)
 end
 f:CloseAll();w:SetUIScale(1)
 t:OpenHotkeys(Vector2.new(1650,650));task.wait(.2);w:Close();task.wait(.5)
 check(not context.Visible and not f.UIElements.Editor.Visible,'closed window finishes dismissing transient panels')
 w:Open();task.wait(1);check(not context.Visible and f.Picking==nil,'reopen has no stale context or capture')
 local oldTitle=t.Title;t:SetTitle('Updated feature title');check(t.Title=='Updated feature title','dynamic title metadata updates');t:SetTitle(oldTitle)
 local test=d.Player:Toggle({Title='Temporary cleanup QA',Value=false,Hotkeys={{Key='F8',Mode='Always',Value=true}}})
 local n=#m.Entries;test:Destroy();task.wait(.1);check(#m.Entries==n-1,'destroy unregisters feature bindings')
end)
if cleanupConfig then pcall(cleanupConfig)end
t:Unlock();t:SetHotkeys(saved);t:Set(savedValue);d.Big:Set(500000);f:CloseAll();f:HideDescription();w:SetUIScale(1);d.Library:SetTheme('Dark');d.Player:Select()
return {status=ok and'pass'or'fail',passed=passed,error=not ok and tostring(err)or nil}
