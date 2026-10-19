-- Compact, theme-aware presentation HUD. Telemetry is read-only and optional.
local Creator=require('../../modules/Creator')
local Geometry=require('../../modules/HUDGeometry')
local Model=require('../../modules/HUDModel')
local NumberFormat=require('../../modules/NumberFormat')
local Drag=require('./HUDDrag')
local Shadow=require('../ui/PopupShadow')
local Run=game:GetService('RunService')
local Players=game:GetService('Players')
local Stats=game:GetService('Stats')
local New=Creator.New
local HUD={}
function HUD.New(Window,WindUI,Config)
 Config=Config or {}
 local fields=Model.Defaults()
 if Model.Validate(Config.Fields)then for k,v in pairs(Config.Fields)do fields[k]=v end end
 local self={Destroyed=false,WatermarkEnabled=Config.Watermark~=false,KeylistEnabled=Config.Keylist~=false,Fields=fields,Rows={},Metrics={FPS=0,VAR=0},KeylistMode='Classic'}
 local signals={};local player=Players.LocalPlayer;local started=os.clock()
 local function connect(s,f)local c=s:Connect(f);signals[#signals+1]=c;return c end
 local gui=New('ScreenGui',{Name='WindUI/HUD',Parent=WindUI.ScreenGui.Parent,IgnoreGuiInset=true,ScreenInsets='None',DisplayOrder=WindUI.ScreenGui.DisplayOrder-1,Enabled=WindUI.ScreenGui.Enabled})
 local function corner(p,n)New('UICorner',{Parent=p,CornerRadius=UDim.new(0,n)})end
 local function text(p,name,value,x,y,w,h,size,secondary,bold)
  return New('TextLabel',{Parent=p,Name=name,Text=value,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundTransparency=1,BorderSizePixel=0,TextStrokeTransparency=1,TextSize=size or 14,TextXAlignment='Left',TextTruncate='AtEnd',FontFace=Font.new(Creator.Font,bold and Enum.FontWeight.SemiBold or Enum.FontWeight.Medium),ThemeTag={TextColor3=secondary and'Placeholder'or'Text'},ZIndex=5})
 end
 local function icon(p,name,x,y,n,tone)
  local im=Creator.Image(name,name,0,Window.Folder,'HUDIcon',true,false,tone or'Primary');im.Parent=p;im.Position=UDim2.fromOffset(x,y);im.Size=UDim2.fromOffset(n,n);im.ZIndex=5;im.ImageLabel.ZIndex=5;return im
 end
 local measureCache,pendingMeasure={},{}
 local function measure(value,size,bold)
  local key=value..'/'..size..tostring(bold)
  if measureCache[key]then return measureCache[key]end
  if not pendingMeasure[key]then
   pendingMeasure[key]=true
   task.spawn(function()
    local params=Instance.new('GetTextBoundsParams');params.Text=value;params.Font=Font.new(Creator.Font,bold and Enum.FontWeight.SemiBold or Enum.FontWeight.Medium);params.Size=size;params.Width=10000
    local ok,bounds=pcall(function()return game:GetService('TextService'):GetTextBoundsAsync(params)end)
    measureCache[key]=ok and math.ceil(bounds.X)or math.ceil(#value*size*.55);pendingMeasure[key]=nil
   end)
  end
  return math.ceil(#value*size*.55)
 end
 local watermark=New('CanvasGroup',{Parent=gui,Name='Watermark',Size=UDim2.fromOffset(480,34),GroupTransparency=1,Visible=false,BackgroundTransparency=0,ThemeTag={BackgroundColor3='Dialog'},ZIndex=3});corner(watermark,7);Shadow.New(watermark,{Opacity=.32})
 local content=New('Frame',{Parent=watermark,Name='Content',Position=UDim2.fromOffset(8,0),Size=UDim2.fromOffset(464,34),BackgroundTransparency=1,ZIndex=4})
 local contentScale=New('UIScale',{Parent=content,Scale=1})
 local cells,byId={},{}
 local buildName=Model.Build(player.Name,Config.Builds,Config.Build or'Release')
 local executorName
 do
  local identify=identifyexecutor or getexecutorname
  if type(identify)=='function'then local ok,n=pcall(identify);if ok and type(n)=='string'and #n>0 then executorName=n end end
 end
 local values={FPS='— FPS',Ping='— MS',Username=Config.Name or player.DisplayName,Time='00:00',Day='Monday',Build=buildName,Platform='Sirius',Executor=executorName or'Unavailable',VAR='— VAR',Memory='— MB',Uptime='00:00:00',Place=tostring(game.PlaceId)}
 for _,def in ipairs(Model.Fields)do
  local frame=New('CanvasGroup',{Parent=content,Name=def.Id,Size=UDim2.fromOffset(0,34),BackgroundTransparency=1,GroupTransparency=1,Visible=false,ClipsDescendants=true,ZIndex=4})
  local c={Id=def.Id,Def=def,Frame=frame,Progress=0,Width=24,TargetWidth=24,Available=def.Id~='Executor'or executorName~=nil}
  if def.Id=='Avatar'then
   c.Avatar=New('ImageLabel',{Parent=frame,Name='Image',Image='rbxthumb://type=AvatarHeadShot&id='..player.UserId..'&w=150&h=150',Position=UDim2.fromOffset(0,6),Size=UDim2.fromOffset(22,22),BackgroundTransparency=1,ZIndex=5});corner(c.Avatar,11)
  else
   if def.Icon then icon(frame,def.Icon,0,10,14,'Placeholder')end
   c.Label=text(frame,'Value',values[def.Id],def.Icon and 22 or 0,0,160,34,14,def.Id=='Build',def.Id=='Platform')
   c.Label.TextTransparency=.12
   if def.Id=='Platform'then Creator.AddThemeObject(c.Label,{TextColor3='Text'})end
  end
  cells[#cells+1]=c;byId[def.Id]=c
 end
 local keylist=New('CanvasGroup',{Parent=gui,Name='Keylist',Size=UDim2.fromOffset(164,30),BackgroundTransparency=1,GroupTransparency=1,Visible=false,ZIndex=3})
 local header=New('Frame',{Parent=keylist,Name='Header',Size=UDim2.fromOffset(118,30),BackgroundTransparency=.12,ThemeTag={BackgroundColor3='Dialog'},ZIndex=4});corner(header,9)
 local headerIcon=icon(header,'list-tree',11,8,14);text(header,'Title',Config.KeylistTitle or'Hotkeys',33,0,78,30,14,false,false)
 local body=New('Frame',{Parent=keylist,Name='Body',Position=UDim2.fromOffset(0,35),Size=UDim2.fromOffset(164,0),BackgroundTransparency=1,ClipsDescendants=true,ZIndex=4});corner(body,8)
 local keyShadowProxy=New('CanvasGroup',{Parent=gui,Name='KeylistShadowSurface',BackgroundTransparency=1,GroupTransparency=1,Visible=false,Size=UDim2.fromOffset(118,30),ZIndex=2,Active=false})
 Shadow.New(keyShadowProxy,{IgnoreBackground=true,Opacity=.22})
 self.UIElements={Gui=gui,Watermark=watermark,Content=content,Cells=cells,Fields=byId,Keylist=keylist,Header=header,Body=body,Avatar=byId.Avatar.Avatar,Badge=byId.Platform.Label}
 local drag=Drag.New(Window,WindUI,gui);self.Drag=drag
 local defaults={Watermark={X=.985,Y=.025,Anchor=1},Keylist={X=.08,Y=.38,Anchor=0}}
 drag:Add('Watermark',watermark,defaults.Watermark,true)
 drag:Add('Keylist',keylist,defaults.Keylist,false).HighlightFrame=header
 local function finite(n)return type(n)=='number'and n==n and n>=0 and n<math.huge end
 local function readPing()
  local ok,n=pcall(function()return Stats.Network.ServerStatsItem['Data Ping']:GetValue()end)
  if ok and finite(n)then return n end
  ok,n=pcall(function()return player:GetNetworkPing()*1000 end);if ok and finite(n)then return n end
 end
 function self:UpdateMetrics()
  if self.Destroyed then return end
  local m=self.Metrics;m.Ping=readPing();m.Executor=executorName;m.Build=buildName
  local ok,n=pcall(function()return Stats:GetTotalMemoryUsageMb()end);m.Memory=ok and finite(n)and n or nil
  if type(Config.MetricsProvider)=='function'then
   local good,extra=pcall(Config.MetricsProvider)
   if good and type(extra)=='table'then for _,key in ipairs({'FPS','Ping','VAR','Memory'})do if finite(extra[key])then m[key]=extra[key]end end end
  end
  -- Smoothed telemetry, reserved numeric columns: changing a number never resizes the pill.
  m.DisplayFPS=m.DisplayFPS and m.DisplayFPS+(m.FPS-m.DisplayFPS)*.35 or m.FPS
  if m.Ping then m.DisplayPing=m.DisplayPing and m.DisplayPing+(m.Ping-m.DisplayPing)*.3 or m.Ping end
  values.FPS=string.format('%d FPS',math.floor(m.DisplayFPS+.5));values.Ping=m.DisplayPing and string.format('%d MS',math.floor(m.DisplayPing+.5))or'— MS'
  values.VAR=string.format('%.1f VAR',m.VAR);values.Memory=m.Memory and string.format('%d MB',math.floor(m.Memory+.5))or'— MB'
  local clock,day=Model.Clock(os.date('*t'));values.Time=clock;values.Day=day
  local uptime=math.floor(os.clock()-started);values.Uptime=string.format('%02d:%02d:%02d',math.floor(uptime/3600),math.floor(uptime/60)%60,uptime%60)
  for _,c in ipairs(cells)do
   if c.Label then
    local val=values[c.Id];c.Label.Text=val
    local reserve=c.Def.Reserve or val
    local number=c.Id=='FPS'and m.DisplayFPS or c.Id=='Ping'and m.DisplayPing
    if number and number>=1000 then reserve=string.rep('8',math.min(6,#tostring(math.floor(number))))..(c.Id=='FPS'and' FPS'or' MS')end
    local cap=c.Id=='Username'and 154 or c.Id=='Executor'and 112 or 180
    c.TargetWidth=math.min(cap,measure(reserve,14,c.Id=='Platform'))+(c.Def.Icon and 22 or 0)+2
   else c.TargetWidth=22 end
  end
 end
 local function active(e,b,index)
  if e.Available and not e.Available()then return false end
  local on=b.Active
  if b.Mode=='Always'then on=true;for i=index+1,#e.Bindings do if e.Bindings[i].Mode=='Always'then on=false;break end end end
  return on and(not e.Read or e.Read()==b.Value)
 end
 local function bindingValue(e,b)
  local owner=e.Owner
  if self.KeylistMode=='Key'then return b.Key=='Unbound'and'—'or b.Key:gsub('MouseButton','M')end
  if type(owner.HotkeyLabel)=='function'then local ok,v=pcall(owner.HotkeyLabel,owner,b);if ok and v~=nil then return tostring(v)end end
  if type(owner.HotkeyLabel)=='string'then return owner.HotkeyLabel end
  if owner.__type~='Toggle'then
   local val=owner.Value
   if type(owner.Get)=='function'then local ok,v=pcall(owner.Get,owner);if ok then val=v end end
   if type(val)=='number'then return NumberFormat.Format(val)elseif type(val)=='string'then return val end
  end
  return b.Value and'ON'or'OFF'
 end
 local function rowFor(id)
  local row=self.Rows[id];if row then return row end
  local frame=New('CanvasGroup',{Parent=body,Name='Binding_'..id,Size=UDim2.new(1,0,0,25),BackgroundTransparency=.94,ThemeTag={BackgroundColor3='Dialog'},GroupTransparency=1,ClipsDescendants=true,ZIndex=5});corner(frame,5)
  local indicatorBack=New('Frame',{Parent=frame,Name='IndicatorSurface',Size=UDim2.fromOffset(26,26),BorderSizePixel=0,ThemeTag={BackgroundColor3='Dialog'},ZIndex=5});corner(indicatorBack,7)
  local nameBack=New('Frame',{Parent=frame,Name='NameSurface',Position=UDim2.fromOffset(30,0),Size=UDim2.fromOffset(100,26),BorderSizePixel=0,ThemeTag={BackgroundColor3='Dialog'},ZIndex=5});corner(nameBack,7)
  local value=text(frame,'Value','',8,0,30,25,13,true,false)
  local label=text(frame,'Feature','',42,0,120,25,14,false,false)
  local track=New('Frame',{Parent=frame,Name='Indicator',Position=UDim2.fromOffset(5,9),Size=UDim2.fromOffset(16,8),ThemeTag={BackgroundColor3='Text'},ZIndex=6});corner(track,4)
  local thumb=New('Frame',{Parent=track,Name='Thumb',Size=UDim2.fromOffset(4,4),Position=UDim2.fromOffset(10,2),ThemeTag={BackgroundColor3='Dialog'},ZIndex=7});corner(thumb,2)
  row={Frame=frame,Label=label,IndicatorSurface=indicatorBack,NameSurface=nameBack,Value=value,Track=track,Thumb=thumb,Progress=0,Leaving=false};self.Rows[id]=row;return row
 end
 local elapsed,frameElapsed,frameCount=0,0,0;local samples={};local sampleIndex=0;local wmAlpha,keyAlpha=0,0;local keyWidth=180;local lastClassic
 connect(Run.RenderStepped,function(dt)
  if self.Destroyed then return end
  dt=math.max(dt,.000001);frameElapsed+=dt;frameCount+=1;elapsed+=dt
  sampleIndex=sampleIndex%60+1;samples[sampleIndex]=dt*1000
  if elapsed>=.35 then
   self.Metrics.FPS=frameCount/frameElapsed
   local sum=0;for _,n in ipairs(samples)do sum+=n end;local mean=sum/#samples;local v=0;for _,n in ipairs(samples)do v+=(n-mean)^2 end
   self.Metrics.VAR=math.sqrt(v/#samples);elapsed=0;frameElapsed=0;frameCount=0;self:UpdateMetrics()
  end
  local x=0;local any=false
  for _,c in ipairs(cells)do
   local shown=self.Fields[c.Id]and c.Available
   any=any or shown;c.Progress=Model.Ease(c.Progress,shown and 1 or 0,dt,13);c.Width=Model.Ease(c.Width,c.TargetWidth,dt,15)
   local width=c.Width*c.Progress
   c.Frame.Position=UDim2.fromOffset(x,0);c.Frame.Size=UDim2.fromOffset(width,34);c.Frame.GroupTransparency=1-c.Progress;c.Frame.Visible=c.Progress>0
   if c.Label then c.Label.Size=UDim2.fromOffset(math.max(0,c.Width-(c.Def.Icon and 22 or 0)),34)end
   x+=(c.Width+6)*c.Progress
  end
  local width=math.max(16,x-6+16)
  wmAlpha=Model.Ease(wmAlpha,self.WatermarkEnabled and any and 1 or 0,dt,13)
  local fit=math.min(1,math.max(.05,(gui.AbsoluteSize.X-16)/width));local scale=fit*(.96+.04*wmAlpha)
  contentScale.Scale=scale;content.Position=UDim2.fromOffset(8*scale,-3*(1-wmAlpha));content.Size=UDim2.fromOffset(width-16,34)
  watermark.Size=UDim2.fromOffset(width*scale,34*scale);watermark.GroupTransparency=1-wmAlpha;watermark.Visible=wmAlpha>0;drag:Layout(drag.Widgets.Watermark)
  local themeName=WindUI:GetCurrentTheme();local theme=WindUI:GetThemes()[themeName]
  local surfaceColor=themeName=='Dark'and Color3.new(0,0,0)or theme.Dialog
  watermark.BackgroundColor3=surfaceColor;watermark.BackgroundTransparency=0
  local classic=true -- Classic is the only supported layout.
  header.BackgroundColor3=surfaceColor;header.BackgroundTransparency=0
  body.BackgroundColor3=surfaceColor;body.BackgroundTransparency=1
  if lastClassic~=classic then
   header.Size=UDim2.fromOffset(math.max(140,measure(header.Title.Text,14,false)+42),30)
   header.Title.Position=UDim2.fromOffset(classic and 34 or 33,0);header.Title.Size=classic and UDim2.new(1,-42,0,30)or UDim2.fromOffset(78,30)
   header.Title.TextSize=14;header.Title.FontFace=Font.new(Creator.Font,Enum.FontWeight.Medium)
   headerIcon.Position=UDim2.fromOffset(classic and 8 or 11,8);headerIcon.Size=UDim2.fromOffset(16,16)
   Creator.AddThemeObject(headerIcon.ImageLabel,{ImageColor3=classic and'Placeholder'or'Primary'})
   body.Position=UDim2.fromOffset(0,classic and 32 or 35);lastClassic=classic
  end
  header.Size=UDim2.fromOffset(math.max(140,measure(header.Title.Text,14,false)+42),30)
  local open=not Window.Closed and Window.UIElements.Main.Visible and Window.UIElements.Main.Main.Visible
  local ordered,seen={},{};local count=0;local targetWidth=classic and 160 or 148
  for _,e in ipairs(Window.FeatureUI.Model.Entries)do for i,b in ipairs(e.Bindings)do
   local id=tostring(b.Id);seen[id]=true;local row=rowFor(id);local target=active(e,b,i)
   row.Progress=Model.Ease(row.Progress,target and 1 or 0,dt,13);if target then count+=1 end
   row.Label.Text=e.Owner.Title or'Feature';row.Value.Text=bindingValue(e,b)
   row.Track.Visible=classic;row.Value.Visible=not classic;row.Thumb.Position=UDim2.fromOffset(b.Value and 10 or 2,2)
   row.Label.TextSize=13
   row.IndicatorSurface.BackgroundColor3=surfaceColor;row.NameSurface.BackgroundColor3=surfaceColor
   local nameWidth=math.min(254,measure(row.Label.Text,13,false))+16
   row.NameSurface.Size=UDim2.fromOffset(nameWidth,26)
   local valueWidth=math.clamp(measure(row.Value.Text,13,false)+4,27,64)
   row.Value.Size=UDim2.fromOffset(valueWidth,25)
   row.Label.Position=UDim2.fromOffset(classic and 38 or(12+valueWidth),0)
   row.Label.Size=UDim2.fromOffset(nameWidth-16,26);row.Label.ZIndex=6
   if row.Progress>0 then targetWidth=math.max(targetWidth,math.min(300,measure(row.Label.Text,13,false)+(classic and 46 or(20+valueWidth))))end
   ordered[#ordered+1]=row
  end end
  -- Retain removed bindings until their final fade/height collapse has finished.
  for id,row in pairs(self.Rows)do if not seen[id]then row.Progress=Model.Ease(row.Progress,0,dt,13);if row.Progress==0 then row.Frame:Destroy();self.Rows[id]=nil else ordered[#ordered+1]=row end end end
  keyWidth=Model.Ease(keyWidth,math.min(targetWidth,math.max(80,gui.AbsoluteSize.X-16)),dt,14)
  local surface=header.BackgroundColor3;local rowSurfaceAlpha=(surface.R*.2126+surface.G*.7152+surface.B*.0722)>.65 and .20 or .78
  local y=0;for _,row in ipairs(ordered)do
   row.Frame.BackgroundTransparency=classic and 1 or rowSurfaceAlpha
   row.Frame.Position=UDim2.fromOffset(6*(1-row.Progress),y);row.Frame.GroupTransparency=1-row.Progress;row.Frame.Size=UDim2.new(1,-6*(1-row.Progress),0,(classic and 26 or 25)*row.Progress);row.Frame.Visible=row.Progress>0;y+=(classic and 31 or 28)*row.Progress
  end
  local maxBody=math.max(0,gui.AbsoluteSize.Y-51);local height=math.min(math.max(0,y-(classic and 5 or 3)),maxBody)
  body.Size=UDim2.fromOffset(keyWidth,height);body.Visible=height>0
  keylist.Size=UDim2.fromOffset(keyWidth,(30)+(height>0 and (classic and 2 or 5)+height or 0))
  keyAlpha=Model.Ease(keyAlpha,self.KeylistEnabled and(open or count>0)and 1 or 0,dt,12)
  keylist.GroupTransparency=1-keyAlpha;keylist.Visible=keyAlpha>0;drag:Layout(drag.Widgets.Keylist)
  keyShadowProxy.Size=header.Size;keyShadowProxy.Position=keylist.Position;keyShadowProxy.GroupTransparency=1-keyAlpha;keyShadowProxy.Visible=keylist.Visible
 end)
 connect(WindUI.ScreenGui:GetPropertyChangedSignal('Enabled'),function()gui.Enabled=WindUI.ScreenGui.Enabled;if not gui.Enabled then drag:Cancel()end end)
 local function changed()if type(self.OnChanged)=='function'then pcall(self.OnChanged,self)end end
 function self:SetWatermarkEnabled(v)local n=v==true;if self.WatermarkEnabled~=n then self.WatermarkEnabled=n;changed()end;return self end
 function self:SetKeylistEnabled(v)local n=v==true;if self.KeylistEnabled~=n then self.KeylistEnabled=n;changed()end;return self end
 function self:SetField(id,v)
  if not Model.ById[id]or type(v)~='boolean'then return false end
  if self.Fields[id]~=v then self.Fields[id]=v;changed()end;return true
 end
 function self:SetFields(selection)
  local parsed=Model.FromSelection(selection);if not parsed then return false end
  for _,f in ipairs(Model.Fields)do if parsed[f.Id]~=self.Fields[f.Id]then self.Fields=parsed;changed();return true end end;return true
 end
 function self:GetFields()return Model.Selected(self.Fields)end
 function self:GetAvailableFields()local out={};for _,f in ipairs(Model.Fields)do out[#out+1]=f.Label end;return out end
 function self:SetKeylistMode(mode)
  if mode~='Key'and mode~='Value'and mode~='Classic'then return false end
  -- Keep old config/API callers compatible without enabling legacy layouts.
  self.KeylistMode='Classic';return true
 end
 function self:ResetPositions()for id,state in pairs(defaults)do drag:SetState(id,state)end;return self end
 function self:Export()
  local out={Version=2,Watermark=self.WatermarkEnabled,Keylist=self.KeylistEnabled,KeylistMode=self.KeylistMode,Fields={},Positions={Watermark=drag:GetState('Watermark'),Keylist=drag:GetState('Keylist')}}
  for k,v in pairs(self.Fields)do out.Fields[k]=v end;return out
 end
 function self:Import(data)
  if type(data)~='table'then return false,'Invalid HUD config'end
  if data.Positions~=nil then
   if type(data.Positions)~='table'then return false,'Invalid HUD positions'end
   for id,state in pairs(data.Positions)do if not defaults[id]or not Geometry.Valid(state)then return false,'Invalid HUD anchor'end end
  end
  if data.Watermark~=nil and type(data.Watermark)~='boolean'then return false,'Invalid watermark state'end
  if data.Keylist~=nil and type(data.Keylist)~='boolean'then return false,'Invalid keylist state'end
  if data.Fields~=nil and not Model.Validate(data.Fields)then return false,'Invalid HUD fields'end
  if data.KeylistMode~=nil and data.KeylistMode~='Key'and data.KeylistMode~='Value'and data.KeylistMode~='Classic'then return false,'Invalid keylist mode'end
  if data.Positions then for id,state in pairs(data.Positions)do drag:SetState(id,state)end end
  if data.Watermark~=nil then self.WatermarkEnabled=data.Watermark end
  if data.Keylist~=nil then self.KeylistEnabled=data.Keylist end
  if data.Fields then for k,v in pairs(data.Fields)do self.Fields[k]=v end end
  self.KeylistMode='Classic';changed();return true
 end
 function self:GetMetrics()local out={};for k,v in pairs(self.Metrics)do out[k]=v end;return out end
 function self:Destroy()
  if self.Destroyed then return end;self.Destroyed=true
  for _,c in ipairs(signals)do c:Disconnect()end;drag:Destroy();gui:Destroy()
 end
 connect(Window.UIElements.Main.Destroying,function()self:Destroy()end)
 self:UpdateMetrics();for _,c in ipairs(cells)do c.Width=c.TargetWidth end
 return self
end
return HUD
