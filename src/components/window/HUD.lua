-- Reference-inspired Roblox watermark and active-hotkey list. Display only:
-- no game logic, server changes or fabricated network statistics.
local Creator=require('../../modules/Creator')
local Geometry=require('../../modules/HUDGeometry')
local Drag=require('./HUDDrag')
local Shadow=require('../ui/PopupShadow')
local Run=game:GetService('RunService')
local Players=game:GetService('Players')
local Stats=game:GetService('Stats')
local New=Creator.New
local HUD={}
function HUD.New(Window,WindUI,Config)
 Config=Config or {}
 local self={Destroyed=false,WatermarkEnabled=Config.Watermark~=false,KeylistEnabled=Config.Keylist~=false,Rows={},Metrics={FPS=0,VAR=0}}
 local signals={}
 local function connect(s,f)local c=s:Connect(f);signals[#signals+1]=c;return c end
 local gui=New('ScreenGui',{Name='WindUI/HUD',Parent=WindUI.ScreenGui.Parent,IgnoreGuiInset=true,ScreenInsets='None',DisplayOrder=WindUI.ScreenGui.DisplayOrder-1,Enabled=WindUI.ScreenGui.Enabled})
 local function corner(p,n)New('UICorner',{Parent=p,CornerRadius=UDim.new(0,n)})end
 local function text(p,name,value,x,y,w,h,size,secondary,bold)
  return New('TextLabel',{Parent=p,Name=name,Text=value,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundTransparency=1,BorderSizePixel=0,TextStrokeTransparency=1,TextSize=size or 14,TextXAlignment='Left',TextTruncate='AtEnd',FontFace=Font.new(Creator.Font,bold and Enum.FontWeight.SemiBold or Enum.FontWeight.Medium),ThemeTag={TextColor3=secondary and'Placeholder'or'Text'},ZIndex=5})
 end
 local function icon(p,name,x,y,n)
  local im=Creator.Image(name,name,0,Window.Folder,'HUDIcon',true,false,'Primary');im.Parent=p;im.Position=UDim2.fromOffset(x,y);im.Size=UDim2.fromOffset(n,n);im.ZIndex=5;im.ImageLabel.ZIndex=5;return im
 end
 local watermark=New('CanvasGroup',{Parent=gui,Name='Watermark',Size=UDim2.fromOffset(640,34),GroupTransparency=1,Visible=false,BackgroundTransparency=.18,ThemeTag={BackgroundColor3='Dialog'},ZIndex=3});corner(watermark,17);Shadow.New(watermark)
 local content=New('Frame',{Parent=watermark,Name='Content',Position=UDim2.fromOffset(12,0),Size=UDim2.new(1,-24,1,0),BackgroundTransparency=1,ZIndex=4})
 local layout=New('UIListLayout',{Parent=content,FillDirection='Horizontal',VerticalAlignment='Center',Padding=UDim.new(0,12),SortOrder='LayoutOrder'})
 local cells={}
 local function cell(name,symbol,initial)
  local frame=New('Frame',{Parent=content,Name=name,Size=UDim2.fromOffset(80,34),LayoutOrder=#cells+1,BackgroundTransparency=1,ZIndex=4})
  if symbol then icon(frame,symbol,0,9,16)end
  local label=text(frame,'Value',initial,symbol and 22 or 0,0,120,34,14,true,false)
  local c={Frame=frame,Label=label,Symbol=symbol,Text=''};cells[#cells+1]=c;return c
 end
 local fps=cell('FPS','chart-no-axes-column-increasing','— FPS')
 local ping=cell('Ping','signal','— MS')
 local variance=cell('Variance','activity','— VAR')
 local loss=cell('Loss','wifi','— LOSS')
 local timeout=cell('Timeout','unplug','— TIMEOUT')
 local name=Config.Name or Players.LocalPlayer.DisplayName
 local username=cell('Username','user-round',name)
 local badge=New('TextLabel',{Parent=content,Name='Platform',Text='RB',Size=UDim2.fromOffset(24,34),LayoutOrder=20,BackgroundTransparency=1,TextStrokeTransparency=1,TextSize=15,FontFace=Font.new(Creator.Font,Enum.FontWeight.Bold),ThemeTag={TextColor3='Primary'},ZIndex=5})
 local avatar=New('ImageLabel',{Parent=content,Name='Avatar',Image='rbxthumb://type=AvatarHeadShot&id='..Players.LocalPlayer.UserId..'&w=150&h=150',Size=UDim2.fromOffset(24,24),LayoutOrder=21,BackgroundTransparency=1,ZIndex=5});corner(avatar,12)
 local keylist=New('CanvasGroup',{Parent=gui,Name='Keylist',Size=UDim2.fromOffset(180,34),BackgroundTransparency=1,GroupTransparency=1,Visible=false,ZIndex=3})
 local header=New('Frame',{Parent=keylist,Name='Header',Size=UDim2.new(1,0,0,34),BackgroundTransparency=.18,ThemeTag={BackgroundColor3='Dialog'},ZIndex=4});corner(header,9)
 icon(header,'list-tree',12,8,18);text(header,'Title',Config.KeylistTitle or'Hotkeys',40,0,128,34,17,false,true)
 local body=New('Frame',{Parent=keylist,Name='Body',Position=UDim2.fromOffset(0,38),Size=UDim2.fromOffset(180,0),BackgroundTransparency=.3,ThemeTag={BackgroundColor3='Dialog'},ClipsDescendants=true,ZIndex=4});corner(body,8)
 -- Shadow follows the visible header/body as one group, without a white border.
 Shadow.New(keylist,{IgnoreBackground=true})
 self.UIElements={Gui=gui,Watermark=watermark,Content=content,Cells=cells,Keylist=keylist,Header=header,Body=body,Avatar=avatar,Badge=badge}
 local drag=Drag.New(Window,WindUI,gui);self.Drag=drag
 local defaults={Watermark={X=.985,Y=.025,Anchor=1},Keylist={X=.08,Y=.38,Anchor=0}}
 drag:Add('Watermark',watermark,defaults.Watermark,true)
 drag:Add('Keylist',keylist,defaults.Keylist,false)
 local measureCache,pendingMeasure={},{}
 local function measure(value,size,bold)
  local key=value..'/'..size..tostring(bold)
  if measureCache[key]then return measureCache[key]end
  if not pendingMeasure[key]then
   pendingMeasure[key]=true
   task.spawn(function()
    local params=Instance.new('GetTextBoundsParams');params.Text=value;params.Font=Font.new(Creator.Font,bold and Enum.FontWeight.SemiBold or Enum.FontWeight.Medium);params.Size=size;params.Width=10000
    local ok,bounds=pcall(function()return game:GetService('TextService'):GetTextBoundsAsync(params)end)
    measureCache[key]=ok and math.ceil(bounds.X)or math.ceil(#value*size*.58)
    pendingMeasure[key]=nil
   end)
  end
  return math.ceil(#value*size*.58)
 end
 local function setCell(c,value,maxWidth)
  if c.Text~=value then c.Text=value;c.Label.Text=value end
  local width=math.min(maxWidth or 180,measure(value,14,false))
  c.Label.Size=UDim2.fromOffset(width,34);c.Frame.Size=UDim2.fromOffset(width+(c.Symbol and 22 or 0),34)
 end
 local function resizeWatermark()
  local width=24+24+24+12*(#cells+1)
  for _,c in ipairs(cells)do width+=c.Frame.Size.X.Offset end
  local scale=math.clamp((gui.AbsoluteSize.X-24)/math.max(width-24,1),.05,1)
  local us=content:FindFirstChildOfClass('UIScale')
  if not us then us=New('UIScale',{Parent=content})end;us.Scale=scale
  watermark.Size=UDim2.fromOffset(math.ceil((width-24)*scale+24),34*scale)
  content.Size=UDim2.new(1,-24,0,34);drag:Layout(drag.Widgets.Watermark)
 end
 local function readPing()
  local ok,n=pcall(function()return Stats.Network.ServerStatsItem['Data Ping']:GetValue()end)
  if ok and type(n)=='number'and n>=0 and n<math.huge then return n end
  ok,n=pcall(function()return Players.LocalPlayer:GetNetworkPing()*1000 end)
  if ok and type(n)=='number'and n>=0 and n<math.huge then return n end
 end
 local function finite(n)return type(n)=='number'and n==n and n>=0 and n<math.huge end
 function self:UpdateMetrics()
  if self.Destroyed then return end
  local metrics=self.Metrics;metrics.Ping=readPing();metrics.Loss=nil;metrics.Timeout=nil
  if type(Config.MetricsProvider)=='function'then
   local ok,extra=pcall(Config.MetricsProvider)
   if ok and type(extra)=='table'then for _,key in ipairs({'Ping','Loss','Timeout'})do if finite(extra[key])then metrics[key]=extra[key]end end end
  end
  setCell(fps,string.format('%d FPS',math.floor(metrics.FPS+.5)))
  setCell(ping,metrics.Ping and string.format('%d MS',math.floor(metrics.Ping+.5))or'— MS')
  setCell(variance,string.format('%.1f VAR',metrics.VAR))
  setCell(loss,metrics.Loss and string.format('%.1f%% LOSS',metrics.Loss)or'— LOSS')
  setCell(timeout,metrics.Timeout and string.format('%.1fs TIMEOUT',metrics.Timeout)or'— TIMEOUT')
  setCell(username,name,132);resizeWatermark()
 end
 local function rowFor(id,entry,binding)
  local row=self.Rows[id];if row then return row end
  local frame=New('CanvasGroup',{Parent=body,Name='Binding_'..id,Size=UDim2.new(1,0,0,26),BackgroundTransparency=1,GroupTransparency=1,ZIndex=5})
  local label=text(frame,'Feature',entry.Owner.Title or'Feature',12,0,126,26,15,false,false)
  local track=New('Frame',{Parent=frame,Name='Value',Position=UDim2.new(1,-34,0,7),Size=UDim2.fromOffset(22,12),BackgroundTransparency=0,ThemeTag={BackgroundColor3='Text'},ZIndex=6});corner(track,6)
  local thumb=New('Frame',{Parent=track,Name='Thumb',Size=UDim2.fromOffset(8,8),Position=UDim2.fromOffset(12,2),ThemeTag={BackgroundColor3='Dialog'},ZIndex=7});corner(thumb,4)
  row={Frame=frame,Label=label,Track=track,Thumb=thumb,Progress=0,Entry=entry,Binding=binding}
  self.Rows[id]=row;return row
 end
 local function active(e,b,index)
  if e.Available and not e.Available()then return false end
  local on=b.Active
  if b.Mode=='Always'then
   on=true;for i=index+1,#e.Bindings do if e.Bindings[i].Mode=='Always'then on=false;break end end
  end
  if not on then return false end
  if e.Read and e.Read()~=b.Value then return false end
  return true
 end
 local elapsed,frameElapsed,frameCount=0,0,0
 local samples={};local sampleIndex=0
 connect(Run.RenderStepped,function(dt)
  if self.Destroyed then return end
  dt=math.max(dt,.000001);frameElapsed+=dt;frameCount+=1;elapsed+=dt
  sampleIndex=sampleIndex%60+1;samples[sampleIndex]=dt*1000
  if elapsed>=.25 then
   self.Metrics.FPS=frameCount/frameElapsed
   local sum=0;for _,n in ipairs(samples)do sum+=n end;local mean=sum/#samples;local varianceSum=0;for _,n in ipairs(samples)do varianceSum+=(n-mean)^2 end
   self.Metrics.VAR=math.sqrt(varianceSum/#samples);elapsed=0;frameElapsed=0;frameCount=0
   self:UpdateMetrics()
  end
  local open=not Window.Closed and Window.UIElements.Main.Visible and Window.UIElements.Main.Main.Visible
  local ordered,seen={},{};local count=0;local width=180
  for _,e in ipairs(Window.FeatureUI.Model.Entries)do for i,b in ipairs(e.Bindings)do
   local id=tostring(b.Id);seen[id]=true;local row=rowFor(id,e,b);local target=active(e,b,i)
   row.Progress+=((target and 1 or 0)-row.Progress)*(1-math.exp(-12*math.min(dt,.1)))
   if target then count+=1 end
   row.Label.Text=e.Owner.Title or'Feature';row.Label.Size=UDim2.new(1,-58,0,26)
   if row.Progress>.003 then width=math.max(width,math.min(300,measure(row.Label.Text,15,false)+58))end
   row.Frame.GroupTransparency=1-row.Progress
   row.Thumb.Position=UDim2.fromOffset(b.Value and 12 or 2,2)
   ordered[#ordered+1]=row
  end end
  for id,row in pairs(self.Rows)do if not seen[id]then row.Frame:Destroy();self.Rows[id]=nil end end
  local height=0;for _,row in ipairs(ordered)do row.Frame.Position=UDim2.fromOffset(0,height);height+=26*row.Progress;row.Frame.Visible=row.Progress>.003 end
  width=math.min(width,math.max(80,gui.AbsoluteSize.X-16))
  body.Size=UDim2.fromOffset(width,height);body.Visible=height>.1
  keylist.Size=UDim2.fromOffset(width,34+(height>.1 and 4+height or 0))
  local animate=1-math.exp(-10*math.min(dt,.1))
  local function fade(frame,shown)
   if shown then frame.Visible=true end
   frame.GroupTransparency+=( (shown and 0 or 1)-frame.GroupTransparency)*animate
   if not shown and frame.GroupTransparency>.995 then frame.Visible=false end
  end
  fade(watermark,self.WatermarkEnabled)
  fade(keylist,self.KeylistEnabled and(open or count>0 or height>.1))
  drag:Layout(drag.Widgets.Keylist)
 end)
 connect(WindUI.ScreenGui:GetPropertyChangedSignal('Enabled'),function()gui.Enabled=WindUI.ScreenGui.Enabled;if not gui.Enabled then drag:Cancel()end end)
 connect(gui:GetPropertyChangedSignal('AbsoluteSize'),function()resizeWatermark()end)
 function self:SetWatermarkEnabled(v)self.WatermarkEnabled=v==true;return self end
 function self:SetKeylistEnabled(v)self.KeylistEnabled=v==true;return self end
 function self:ResetPositions()for id,state in pairs(defaults)do drag:SetState(id,state)end;return self end
 function self:Export()return {Version=1,Watermark=self.WatermarkEnabled,Keylist=self.KeylistEnabled,Positions={Watermark=drag:GetState('Watermark'),Keylist=drag:GetState('Keylist')}}end
 function self:Import(data)
  if type(data)~='table'then return false,'Invalid HUD config'end
  if data.Positions~=nil then
   if type(data.Positions)~='table'then return false,'Invalid HUD positions'end
   for id,state in pairs(data.Positions)do if not defaults[id]or not Geometry.Valid(state)then return false,'Invalid HUD anchor'end end
  end
  if data.Watermark~=nil and type(data.Watermark)~='boolean'then return false,'Invalid watermark state'end
  if data.Keylist~=nil and type(data.Keylist)~='boolean'then return false,'Invalid keylist state'end
  if data.Positions then for id,state in pairs(data.Positions)do drag:SetState(id,state)end end
  if data.Watermark~=nil then self.WatermarkEnabled=data.Watermark end
  if data.Keylist~=nil then self.KeylistEnabled=data.Keylist end;return true
 end
 function self:GetMetrics()local out={};for k,v in pairs(self.Metrics)do out[k]=v end;return out end
 function self:Destroy()
  if self.Destroyed then return end;self.Destroyed=true
  for _,c in ipairs(signals)do c:Disconnect()end;drag:Destroy();gui:Destroy()
 end
 connect(Window.UIElements.Main.Destroying,function()self:Destroy()end)
 self:UpdateMetrics()
 return self
end
return HUD
