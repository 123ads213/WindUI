-- Live Roblox QA: restores user settings and removes its unique temporary config.
local d=assert(getgenv().WindUIForkDemo)
local h,w=d.HUD,d.Window
local u=h.UIElements
local input=game:GetService('UserInputService')
local saved={HUD=h:Export(),Theme=d.Library:GetCurrentTheme(),Hotkeys=d.ShowPlayers:GetHotkeys(),Value=d.ShowPlayers.Value,Closed=w.Closed,Title=d.ShowPlayers.Title}
local passed=0
local function check(v,msg)assert(v,msg);passed+=1 end
local qa,qaName,previousConfig
local function wait()task.wait(.5)end
local function bounds(frame)
 local p,z=frame.AbsolutePosition-u.Gui.AbsolutePosition,frame.AbsoluteSize;local v=u.Gui.AbsoluteSize
 return p.X>=-1 and p.Y>=-1 and p.X+z.X<=v.X+1 and p.Y+z.Y<=v.Y+1
end
local ok,err=pcall(function()
 w:Open();d.Profile:Close();w.FeatureUI:CloseAll();h:SetWatermarkEnabled(true);h:SetKeylistEnabled(true);h:SetKeylistMode('Value');wait()
 local m=h:GetMetrics();check(m.FPS>0 and m.FPS<5000,'live FPS');check(m.VAR>=0,'frame-time variance');check(m.Loss==nil and m.Timeout==nil,'unavailable statistics not fabricated')
 check(u.Fields.Loss==nil and u.Fields.Timeout==nil,'no fake network fields')
 check(m.Build=='Nightly'and u.Fields.Build.Label.Text=='Nightly','username-specific build')
 check(u.Fields.Time.Label.Text:match('^%d%d:%d%d$')and #u.Fields.Day.Label.Text>=6,'local time and full weekday');check(u.Fields.Platform.Label.Text=='Sirius','Sirius branding');check(u.Fields.FPS.Label.Position.X.Offset==22 and u.Fields.Ping.Label.Position.X.Offset==22,'8px icon text gap')
 check(u.Fields.Executor.Available and type(m.Executor)=='string','executor identity available')
 local originalFields=h:GetFields();h:SetFields({'FPS','Ping','Build'});task.wait(.1);local intermediate=u.Watermark.AbsoluteSize.X;task.wait(.8);check(intermediate>u.Watermark.AbsoluteSize.X,'field removal animates width')
 check(#d.WatermarkFields.Value==3,'field control mirrors API changes');local stable=u.Watermark.AbsoluteSize.X;local maxDelta=0;for i=1,70 do game:GetService('RunService').RenderStepped:Wait();maxDelta=math.max(maxDelta,math.abs(u.Watermark.AbsoluteSize.X-stable))end;check(maxDelta<.05,'telemetry changes never resize the pill')
 h:SetField('Executor',true);task.wait(.07);check(u.Fields.Executor.Progress>0 and u.Fields.Executor.Progress<1,'field reveal interpolates');task.wait(.8);check(u.Fields.Executor.Frame.Visible,'executor field selectable')
 h:SetFields({});task.wait(.8);check(not u.Watermark.Visible,'empty selection hides watermark');check(not h:SetFields({'Fake field'})and #h:GetFields()==0,'invalid selection atomic');h:SetFields(originalFields);task.wait(.8)
 check(bounds(u.Watermark)and bounds(u.Keylist),'widgets within viewport')
 check(u.Header.Title.FontFace.Family=='rbxassetid://12187365364','native font retained')
 check(u.Watermark:FindFirstChildOfClass('UIStroke')==nil,'no white border')
 d.ShowPlayers:SetHotkeys({});wait();check(u.Keylist.Visible and not u.Body.Visible,'empty header visible with menu')
 w:Close();task.wait(.8);check(not u.Keylist.Visible and u.Watermark.Visible,'empty keylist hidden with closed menu')
 w:Open();wait();d.ShowPlayers:SetHotkeys({{Key='F6',Mode='Hold',Value=true}});d.ShowPlayers:Set(false)
 local model=w.FeatureUI.Model;model:Input('F6',true);wait();local id=tostring(d.ShowPlayers.HotkeyEntry.Bindings[1].Id);local r=h.Rows[id]
 check(r and r.Progress>.95 and r.Frame.Visible,'active hold appears');check(r.Label.Text==saved.Title,'actual feature name')
 check(r.Track.Visible and not r.Value.Visible,'Classic indicator-only row');check(u.Header.AbsoluteSize.X>=140 and u.Header.AbsoluteSize.Y==30,'content-sized header');h:SetKeylistMode('Key');wait();check(h.KeylistMode=='Classic'and r.Track.Visible,'legacy API cannot change Classic');check(h:Import({KeylistMode='Value'})and h.KeylistMode=='Classic','legacy config normalizes to Classic')
 w:Close();wait();check(u.Keylist.Visible and u.Body.Visible,'active key survives menu close')
 model:Input('F6',false);task.wait(1.4);check(not u.Keylist.Visible,'hold release fades out')
 w:Open();wait();d.ShowPlayers:SetHotkeys({{Key='F6',Mode='Toggle',Value=false}});d.ShowPlayers:Set(true);model:Input('F6',true);model:Input('F6',false);wait()
 id=tostring(d.ShowPlayers.HotkeyEntry.Bindings[1].Id);r=h.Rows[id];check(r.Progress>.95 and d.ShowPlayers.Value==false,'disabled-value binding listed');check(r.Value.Text=='OFF','disabled value text')
 model:Input('F6',true);model:Input('F6',false);wait();check(r.Progress<.01,'toggle second press removes active row')
 d.ShowPlayers:SetHotkeys({{Key='Unbound',Mode='Always',Value=true},{Key='Unbound',Mode='Always',Value=false}});wait()
 local total=0;for _,row in pairs(h.Rows)do if row.Progress>.9 then total+=1 end end;check(total==1 and not d.ShowPlayers.Value,'last Always wins without duplicate rows')
 local old=d.ShowPlayers.Title;d.ShowPlayers:SetTitle('Dynamic hotkey title');wait();id=tostring(d.ShowPlayers.HotkeyEntry.Bindings[2].Id);check(h.Rows[id].Label.Text=='Dynamic hotkey title','title updates live');d.ShowPlayers:SetTitle(old)
 -- Synthetic input uses raw InputObject.Position, matching actual client coordinates.
 h:ResetPositions();wait()
 local f=u.Watermark;local p=f.AbsolutePosition+Vector2.new(60,15)
 local down={UserInputType=Enum.UserInputType.MouseButton1,Position=Vector3.new(p.X,p.Y,0)}
 firesignal(f.InputBegan,down);check(h.Drag.Active==h.Drag.Widgets.Watermark,'watermark drag begins')
 check((h.Drag.Offset-Vector2.new(60,15)).Magnitude<1,'grab offset has no inset jump')
 local before=f.Position;local target=p+Vector2.new(-175,115)
 firesignal(input.InputChanged,{UserInputType=Enum.UserInputType.MouseMovement,Position=Vector3.new(target.X,target.Y,0)})
 check(math.abs(f.Position.X.Offset-before.X.Offset+175)<=1 and math.abs(f.Position.Y.Offset-before.Y.Offset-115)<=1,'direct dragging follows cursor')
 firesignal(input.InputEnded,down);check(h.Drag.Active==nil and d.Library.CurrentInput==nil,'drag release clears shared input')
 check(h.Drag:GetState('Watermark').Anchor==1,'right third chooses right anchor')
 local v=u.Gui.AbsoluteSize;local z=f.AbsoluteSize
 local centerX=(v.X-z.X)/2;local topY=32-z.Y/2
 h.Drag:SetState('Watermark',{X=(centerX+5)/v.X,Y=(topY+4)/v.Y,Anchor=0});wait()
 p=f.AbsolutePosition+Vector2.new(30,10);down={UserInputType=Enum.UserInputType.MouseButton1,Position=Vector3.new(p.X,p.Y,0)};firesignal(f.InputBegan,down)
 firesignal(input.InputChanged,{UserInputType=Enum.UserInputType.MouseMovement,Position=Vector3.new(p.X,p.Y,0)})
 check(h.Drag.Hits and h.Drag.Hits.Center and h.Drag.Hits.Top,'center and top snap');task.wait(.15)
 check(u.Gui.HUDGuideCenter.BackgroundTransparency<.95,'snap ruler visible')
 firesignal(input.InputEnded,down);check(h.Drag:GetState('Watermark').Anchor==.5,'center third chooses center anchor')
 p=f.AbsolutePosition+Vector2.new(30,10);down={UserInputType=Enum.UserInputType.MouseButton1,Position=Vector3.new(p.X,p.Y,0)};firesignal(f.InputBegan,down);firesignal(input.WindowFocusReleased);check(h.Drag.Active==nil,'focus loss releases drag')
 w:Close();wait();firesignal(f.InputBegan,down);check(h.Drag.Active==nil,'drag disabled with menu closed');w:Open();wait()
 h.Drag:SetState('Keylist',{X=.1,Y=.3,Anchor=0});wait();local k=u.Keylist;p=k.AbsolutePosition+Vector2.new(30,10);down={UserInputType=Enum.UserInputType.MouseButton1,Position=Vector3.new(p.X,p.Y,0)};firesignal(k.InputBegan,down)
 check(h.Drag.Active==h.Drag.Widgets.Keylist,'keylist drag begins');firesignal(input.InputChanged,{UserInputType=Enum.UserInputType.MouseMovement,Position=Vector3.new(-9999,-9999,0)});firesignal(input.InputEnded,down);check(k.Position.X.Offset==0 and k.Position.Y.Offset==0,'screen edges clamp')
 h:SetWatermarkEnabled(false);h:SetKeylistEnabled(false);task.wait(.8);check(not u.Watermark.Visible and not u.Keylist.Visible,'independent visibility switches');h:SetWatermarkEnabled(true);h:SetKeylistEnabled(true);wait()
 local numeric=d.General:Slider({Title='HUD QA numeric',Value={Min=0,Max=100,Default=10},HotkeyCallback=function()end,Hotkeys={{Key='F7',Mode='Always',Value=true}}});wait();local nid=tostring(numeric.HotkeyEntry.Bindings[1].Id);check(h.Rows[nid].Value.Text=='10','numeric feature value on left');numeric:Destroy();task.wait(.1);check(h.Rows[nid]and h.Rows[nid].Progress>0,'deleted row fades instead of popping');task.wait(.8);check(h.Rows[nid]==nil,'deleted row cleaned after fade');
 local beforeExport=h:Export();check(not h:Import({Watermark=false,Fields={Fake=true}})and h.WatermarkEnabled,'invalid fields atomic');local valid=h:Import({Watermark=false,Positions={Watermark={X=0/0,Y=0,Anchor=0}}});check(not valid and h.WatermarkEnabled,'invalid config rejected atomically')
 local cm=w.ConfigManager;previousConfig=w.CurrentConfig;qaName='__hud_qa_'..d.Library.GenerateGUID();qa=cm:CreateConfig(qaName);d.WatermarkFields:Select(h:GetFields());local data=qa:Save();check(data.__hud.Positions.Watermark.Anchor==.5,'HUD included in config')
 local disk=game:GetService('HttpService'):JSONDecode(readfile(qa.Path));check(disk.__hud.Version==2 and disk.__hud.Fields.Time and disk.__hud.Keylist,'actual JSON persisted')
 h:ResetPositions();h:SetWatermarkEnabled(false);qa:Load();wait();check(h.WatermarkEnabled and h.Drag:GetState('Watermark').Anchor==.5,'actual config Load restores HUD');check(#d.WatermarkFields.Value==#h:GetFields(),'controls mirror imported HUD config')
 for _,theme in ipairs({'Dark','Light','Ocean','Forest','Ember','Orchid','Paper'})do
  d.Library:SetTheme(theme);task.wait(.12);local t=d.Library:GetThemes()[theme]
  check(u.Watermark.BackgroundColor3==(theme=='Dark'and Color3.new(0,0,0)or t.Dialog) and u.Header.Title.TextColor3==t.Text,'HUD follows '..theme);check(u.Gui.HUDGuideCenter.BackgroundColor3==Color3.new(1,1,1)and h.Drag.Widgets.Watermark.Highlight.BackgroundColor3==Color3.new(1,1,1),'white guides and highlights in '..theme)
 end
 d.Library:SetTheme('Dark');h:SetKeylistMode('Classic');task.wait(.9);check(u.Watermark.BackgroundColor3==Color3.new(0,0,0)and u.Watermark.BackgroundTransparency==0,'opaque black Dark watermark');check(u.Header.AbsoluteSize.X>=140 and math.abs(u.Header.AbsoluteSize.Y-30)<.05,'reference header dimensions: '..tostring(u.Header.AbsoluteSize)..' mode '..h.KeylistMode);local classicRow;for _,row in pairs(h.Rows)do if row.Progress>.9 then classicRow=row end end;check(classicRow and classicRow.Track.Visible and not classicRow.Value.Visible and classicRow.Label.Position.X.Offset==42 and classicRow.Track.Position.X.Offset==6 and classicRow.Track.Size.X.Offset==18 and classicRow.Track.Size.Y.Offset==10,'reference left-side indicator restored');check(u.Body.BackgroundTransparency==1 and u.Header.BackgroundTransparency==0,'opaque header and transparent bindings');check(classicRow.Frame.BackgroundTransparency==1 and classicRow.Label.TextSize==14 and classicRow.Frame.Size.Y.Offset>29.9,'larger binding without background');local hs=u.Gui.KeylistShadowSurface;check(hs.Size==u.Header.Size,'shadow only covers header');check(classicRow.IndicatorSurface.Size.X.Offset==30 and classicRow.NameSurface.Position.X.Offset==34 and classicRow.NameSurface.Size.X.Offset<200,'separate snug binding surfaces');check(u.Body.Position.Y.Offset==32,'bindings closer to header');local hw=u.Header.Size.X.Offset;d.ShowPlayers:SetTitle('A much longer binding name');wait();check(u.Header.Size.X.Offset==hw,'long binding never stretches header');d.ShowPlayers:SetTitle(saved.Title);
 d.Library:SetTheme('Light');task.wait(.15);check(u.Gui.HUDGuideCenter.BackgroundColor3==Color3.new(1,1,1),'light guides are white');check(h.Drag.Widgets.Watermark.Highlight.BackgroundColor3==Color3.new(1,1,1),'light drag highlight is white')
end)
if qa then pcall(function()qa:Delete();w.ConfigManager.Configs[qaName]=nil end);w.CurrentConfig=previousConfig end
h.Drag:Cancel();d.ShowPlayers:SetTitle(saved.Title);d.ShowPlayers:SetHotkeys(saved.Hotkeys);d.ShowPlayers:Set(saved.Value);h:Import(saved.HUD);d.WatermarkFields:Select(h:GetFields());d.Library:SetTheme(saved.Theme)
if saved.Closed then w:Close()else w:Open()end
return {status=ok and'pass'or'fail',passed=passed,error=not ok and tostring(err)or nil}
