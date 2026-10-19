-- WindUI themed hover descriptions and per-feature context hotkeys.
local Creator=require('../../modules/Creator')
local Model=require('../../modules/HotkeyModel')
local Shadow=require('../ui/PopupShadow')
local New,Tween=Creator.New,Creator.Tween
local Input=game:GetService('UserInputService')
local Run=game:GetService('RunService')
local FeatureUI={}
function FeatureUI.New(Window,WindUI)
 local self={Model=Model.New(),UIElements={},Destroyed=false,Picking=nil}
 local signals,registrations={},{}
 local host=Window.UIElements.Main.Main
 local function connect(signal,fn)local c=signal:Connect(fn);signals[#signals+1]=c;return c end
 local function scale()return WindUI.UIScaleObj.Scale end
 local function corner(p,n)New('UICorner',{Parent=p,CornerRadius=UDim.new(0,n)})end
 local function label(p,name,title,x,y,w,h,size,secondary)
  return New('TextLabel',{Parent=p,Name=name,Text=title,Position=UDim2.fromOffset(x,y),Size=UDim2.new(w<0 and 1 or 0,w,0,h),BackgroundTransparency=1,TextSize=math.max(size or 15,15),TextStrokeTransparency=1,TextXAlignment='Left',TextYAlignment='Center',TextTruncate='AtEnd',FontFace=Font.new(Creator.Font,Enum.FontWeight.Medium),ThemeTag={TextColor3=secondary and'Placeholder'or'Text'},ZIndex=502})
 end
 local function icon(p,name,x,y,n)
  local im=Creator.Image(name,name,0,Window.Folder,'HotkeyIcon',true,false,'Icon');im.Parent=p;im.Position=UDim2.fromOffset(x,y);im.Size=UDim2.fromOffset(n,n);im.ZIndex=503;im.ImageLabel.ZIndex=503;return im
 end
 local function panel(name,width,height)
  local f=New('CanvasGroup',{Parent=host,Name=name,Size=UDim2.fromOffset(width,height),Visible=false,GroupTransparency=1,ThemeTag={BackgroundColor3='Dialog'},ZIndex=500,Active=true})
  corner(f,12);Shadow.New(f)
  return f
 end
 local tweens,targets={},{}
 local function show(f,value)
  if self.Destroyed or targets[f]==value then return end
  targets[f]=value
  if tweens[f]then tweens[f]:Cancel()end
  if value then f.Visible=true end
  local t=Tween(f,.16,{GroupTransparency=value and 0 or 1});tweens[f]=t;t:Play()
  if not value then task.delay(.17,function()if not self.Destroyed and tweens[f]==t then f.Visible=false end end)end
 end
 local function place(f,x,y)
  local s=scale();local origin=WindUI.ScreenGui.AbsolutePosition;local size=WindUI.ScreenGui.AbsoluteSize
  local w,h=f.Size.X.Offset*s,f.Size.Y.Offset*s
  x=math.clamp(x,origin.X+8,math.max(origin.X+8,origin.X+size.X-w-8));y=math.clamp(y,origin.Y+8,math.max(origin.Y+8,origin.Y+size.Y-h-8))
  f.Position=UDim2.fromOffset((x-host.AbsolutePosition.X)/s,(y-host.AbsolutePosition.Y)/s)
 end
 local function beside(f,anchor)
  local s=scale();local a,z=anchor.AbsolutePosition,anchor.AbsoluteSize
  local x=a.X+z.X+6*s
  if x+f.Size.X.Offset*s>WindUI.ScreenGui.AbsolutePosition.X+WindUI.ScreenGui.AbsoluteSize.X-8 then x=a.X-f.Size.X.Offset*s-6*s end
  place(f,x,a.Y)
 end
 local function separator(p,y)
  New('Frame',{Parent=p,Position=UDim2.fromOffset(14,y),Size=UDim2.new(1,-28,0,1),BorderSizePixel=0,BackgroundTransparency=.93,ThemeTag={BackgroundColor3='Text'},ZIndex=502})
 end
 local function button(p,name,title,symbol,y,fn)
  local b=New('TextButton',{Parent=p,Name=name,Text='',Size=UDim2.new(1,-16,0,38),Position=UDim2.fromOffset(8,y),AutoButtonColor=false,BackgroundTransparency=1,ThemeTag={BackgroundColor3='ElementBackground'},ZIndex=501})
  corner(b,8);if symbol then icon(b,symbol,10,9,20)end
  label(b,'Label',title,symbol and 40 or 12,0,-(symbol and 52 or 24),38,15)
  b.MouseEnter:Connect(function()Tween(b,.12,{BackgroundTransparency=0}):Play()end)
  b.MouseLeave:Connect(function()Tween(b,.12,{BackgroundTransparency=1}):Play()end)
  if fn then b.MouseButton1Click:Connect(fn)end
  return b
 end
 local tip=panel('FeatureDescription',330,92)
 local tipTitle=label(tip,'Title','',14,10,-28,22,15)
 local tipBody=label(tip,'Description','',14,36,-28,42,14,true);tipBody.TextWrapped=true;tipBody.TextTruncate='AtEnd';tipBody.TextYAlignment='Top'
 local context=panel('FeatureHotkeys',232,188)
 local editor=panel('HotkeyEditor',264,198)
 local modes=panel('HotkeyModes',156,130)
 local all=panel('AllHotkeys',580,420)
 self.UIElements={Tooltip=tip,TooltipTitle=tipTitle,TooltipBody=tipBody,Context=context,Editor=editor,Modes=modes,All=all}
 local activeEntry,activeBinding,activeRow
 local hoverSerial=0
 function self:HideDescription()hoverSerial+=1;show(tip,false)end
 function self:Describe(content,frame)
  if self.Picking or context.Visible or all.Visible or Window.Closed or Window.Destroyed then return end
  local request=hoverSerial
  local desc=frame.Desc
  if not desc or desc==''then return end
  tipTitle.Text=content.Title or frame.Title or'Feature';tipBody.Text=desc
  local s=scale();local width=math.min(330,math.max(220,WindUI.ScreenGui.AbsoluteSize.X/s-32))
  local params=Instance.new('GetTextBoundsParams');params.Text=desc;params.Font=tipBody.FontFace;params.Size=14;params.Width=width-28
  local ok,bounds=pcall(function()return game:GetService('TextService'):GetTextBoundsAsync(params)end)
  local height=ok and math.min(180,math.max(20,bounds.Y+2))or 60
  if self.Destroyed or not frame.UIElements.Main.Parent or request~=hoverSerial then return end
  tip.Size=UDim2.fromOffset(width,height+50);tipBody.Size=UDim2.new(1,-28,0,height)
  beside(tip,frame.UIElements.Main);show(tip,true)
 end
 local contextList=New('ScrollingFrame',{Parent=context,Name='Bindings',Position=UDim2.fromOffset(0,8),Size=UDim2.new(1,0,1,-142),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ThemeTag={ScrollBarImageColor3='Icon'},CanvasSize=UDim2.new(),AutomaticCanvasSize='Y',ZIndex=501})
 local editorKey,editorMode,editorValue,valueTrack,valueDot
 local valueTween
 local rebuildContext,refreshEditor,refreshAll
 local function clearChildren(f)for _,child in ipairs(f:GetChildren())do child:Destroy()end end
 local function validKey(value)
  if typeof(value)=='EnumItem'then value=value.Name end
  if type(value)~='string'then return'Unbound'end
  if value=='MouseButton1'or value=='MouseButton2'or value=='MouseButton3'then return value end
  local ok,item=pcall(function()return Enum.KeyCode[value]end)
  return ok and item and item~=Enum.KeyCode.Unknown and item~=Enum.KeyCode.Escape and value or'Unbound'
 end
 local function keyName(input)
  if input.UserInputType==Enum.UserInputType.Keyboard then return input.KeyCode.Name end
  if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.MouseButton2 or input.UserInputType==Enum.UserInputType.MouseButton3 then return input.UserInputType.Name end
 end
 function self:CancelCapture()self.Picking=nil;if editorKey then editorKey.Value.Text=activeBinding and activeBinding.Key or'Unbound'end end
 function self:Close()
  self:CancelCapture();activeEntry=nil;activeBinding=nil
  show(context,false);show(editor,false);show(modes,false)
 end
 function self:Edit(e,b,row)
  self:CancelCapture();activeEntry=e;activeBinding=b;activeRow=row
  refreshEditor();beside(editor,row or context);show(editor,true);show(modes,false)
 end
 refreshEditor=function()
  if not activeBinding then return end
  editorKey.Value.Text=self.Picking and'Press a key…'or activeBinding.Key
  editorMode.Value.Text=activeBinding.Mode
  if valueTween then valueTween:Cancel()end
  valueTrack.BackgroundColor3=Creator.GetThemeProperty(activeBinding.Value and'Toggle'or'Button',Creator.Theme)
  valueTween=Tween(valueDot,.16,{Position=UDim2.new(activeBinding.Value and 1 or 0,activeBinding.Value and -20 or 2,.5,-9)});valueTween:Play()
 end
 editorKey=button(editor,'Key','Key','keyboard',8,function()
  if activeBinding then self.Picking={Entry=activeEntry,Binding=activeBinding};editorKey.Value.Text='Press a key…'end
 end)
 local keyValue=label(editorKey,'Value','Unbound',80,0,-114,38,14,true);keyValue.TextXAlignment='Right'
 editorMode=button(editor,'Mode','Mode','repeat-2',50,function()beside(modes,editorMode);show(modes,not modes.Visible)end)
 editorMode.MouseEnter:Connect(function()if activeBinding then beside(modes,editorMode);show(modes,true)end end)
 local mv=label(editorMode,'Value','Toggle',90,0,-126,38,14,true);mv.TextXAlignment='Right';icon(editorMode,'chevron-right',220,11,16)
 editorValue=button(editor,'Value','Value','link',92,function()
  if activeBinding then self.Model:Update(activeEntry,activeBinding,{Value=not activeBinding.Value});refreshEditor();refreshAll()end
 end)
 valueTrack=New('Frame',{Parent=editorValue,Name='ValueToggle',Position=UDim2.new(1,-52,.5,-11),Size=UDim2.fromOffset(40,22),BorderSizePixel=0,ZIndex=503});corner(valueTrack,11)
 valueDot=New('Frame',{Parent=valueTrack,Name='Thumb',Size=UDim2.fromOffset(18,18),Position=UDim2.new(1,-20,.5,-9),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=504});corner(valueDot,9)
 separator(editor,140)
 button(editor,'Delete','Delete','trash-2',150,function()
  if activeBinding then self.Model:Remove(activeEntry,activeBinding);self:CancelCapture();activeBinding=nil;show(editor,false);show(modes,false);rebuildContext();refreshAll()end
 end)
 for i,mode in ipairs({'Toggle','Hold','Always'})do
  button(modes,mode,mode,nil,8+(i-1)*38,function()
   if activeBinding then self.Model:Update(activeEntry,activeBinding,{Mode=mode});refreshEditor();rebuildContext();refreshAll()end;show(modes,false)
  end)
 end
 local allButton=button(context,'AllHotkeys','All Hotkeys','list',46,function()self:ShowAll()end)
 local newButton=button(context,'NewHotkey','New Hotkey','circle-plus',88,function()
  if activeEntry then local b=self.Model:Add(activeEntry);rebuildContext();self:Edit(activeEntry,b,contextList:FindFirstChild('Binding_'..b.Id));refreshAll()end
 end)
 local resetButton=button(context,'Reset','Reset','rotate-ccw',140,function()
  if activeEntry then self.Model:Reset(activeEntry);self:CancelCapture();activeBinding=nil;show(editor,false);show(modes,false);rebuildContext();refreshAll()end
 end)
 local sep=New('Frame',{Parent=context,Name='Separator',Size=UDim2.new(1,-28,0,1),Position=UDim2.fromOffset(14,132),BackgroundTransparency=.93,BorderSizePixel=0,ThemeTag={BackgroundColor3='Text'},ZIndex=502})
 rebuildContext=function()
  clearChildren(contextList)
  if not activeEntry then return end
  local count=#activeEntry.Bindings;local visible=math.min(5,math.max(1,count));local listHeight=visible*38
  context.Size=UDim2.fromOffset(232,listHeight+150);contextList.Size=UDim2.new(1,0,0,listHeight)
  allButton.Position=UDim2.fromOffset(8,listHeight+12);newButton.Position=UDim2.fromOffset(8,listHeight+54)
  sep.Position=UDim2.fromOffset(14,listHeight+100);resetButton.Position=UDim2.fromOffset(8,listHeight+106)
  if count==0 then label(contextList,'Empty','No hotkeys yet',20,0,-40,38,14,true)end
  for i,b in ipairs(activeEntry.Bindings)do
   local row=button(contextList,'Binding_'..b.Id,b.Key,'keyboard',0)
   row.Position=UDim2.fromOffset(8,(i-1)*38)
   icon(row,'chevron-right',190,11,16)
   row.MouseEnter:Connect(function()self:Edit(activeEntry,b,row)end)
   row.MouseButton1Click:Connect(function()self:Edit(activeEntry,b,row)end)
  end
  -- Recreated rows may invalidate the anchor; retain editor selection without jumping.
  if activeBinding then activeRow=contextList:FindFirstChild('Binding_'..activeBinding.Id)end
 end
 function self:Open(e,point)
  if Window.ActiveColorPopup then Window.ActiveColorPopup:Close()end
  self:Close();show(all,false);self:HideDescription();activeEntry=e;rebuildContext()
  local at=point or (Input:GetMouseLocation()+WindUI.ScreenGui.AbsolutePosition);place(context,at.X+6,at.Y+6);show(context,true)
 end
 label(all,'Title','All Hotkeys',20,12,-80,32,20)
 local close=button(all,'Close','','x',12,function()self:CloseAll()end);close.Size=UDim2.fromOffset(36,32);close.Position=UDim2.new(1,-48,0,12);close.Label:Destroy();for _,child in ipairs(close:GetChildren())do if child:IsA('GuiObject')then child.Position=UDim2.fromOffset(8,6)end end
 local columns=New('Frame',{Parent=all,Position=UDim2.fromOffset(32,52),Size=UDim2.new(1,-64,0,28),BackgroundTransparency=1,ZIndex=502})
 for _,c in ipairs({{'Feature',0,.40},{'Key',.41,.22},{'Mode',.64,.16},{'Value',.81,.19}})do local t=label(columns,c[1],c[1],0,0,0,28,13,true);t.Position=UDim2.fromScale(c[2],0);t.Size=UDim2.fromScale(c[3],1)end
 separator(all,84)
 local scroll=New('ScrollingFrame',{Parent=all,Name='Entries',Position=UDim2.fromOffset(12,94),Size=UDim2.new(1,-24,1,-110),CanvasSize=UDim2.new(),AutomaticCanvasSize='Y',BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ThemeTag={ScrollBarImageColor3='Icon'},ZIndex=501})
 refreshAll=function()
  clearChildren(scroll);local n=0
  for _,e in ipairs(self.Model.Entries)do for _,b in ipairs(e.Bindings)do
   local row=button(scroll,'Hotkey_'..b.Id,e.Owner.Title or'Feature',nil,n*48,function()self:Open(e,all.AbsolutePosition);self:Edit(e,b,context)end)
   row.Label.Size=UDim2.new(.40,-16,0,38)
   local key=label(row,'Key',b.Mode=='Always'and'—'or b.Key,0,0,0,38,14,true);key.Position=UDim2.fromScale(.41,0);key.Size=UDim2.fromScale(.22,1)
   local mode=label(row,'Mode',b.Mode,0,0,0,38,14);mode.Position=UDim2.fromScale(.64,0);mode.Size=UDim2.fromScale(.16,1)
   local value=label(row,'Value',b.Value and'Enabled'or'Disabled',0,0,0,38,13,true);value.Position=UDim2.fromScale(.81,0);value.Size=UDim2.fromScale(.19,1)
   n+=1
  end end
  if n==0 then label(scroll,'Empty','No hotkeys. Right-click a toggle to add one.',12,24,-24,40,15,true)end
 end
 function self:ShowAll()
  if Window.ActiveColorPopup then Window.ActiveColorPopup:Close()end
  self:Close();self:HideDescription();refreshAll()
  local s=scale();all.Size=UDim2.fromOffset(math.min(580,WindUI.ScreenGui.AbsoluteSize.X/s-24),math.min(420,WindUI.ScreenGui.AbsoluteSize.Y/s-24))
  local a=Window.UIElements.Main.AbsolutePosition;local z=Window.UIElements.Main.AbsoluteSize
  place(all,a.X+(z.X-all.Size.X.Offset*s)/2,a.Y+(z.Y-all.Size.Y.Offset*s)/2);show(all,true)
 end
 function self:CloseAll()show(all,false);self:Close()end
 function self:Register(content,frame,config)
  local main=frame.UIElements.Main
  local tooltip=(config.DescMode or Window.DescriptionMode)=='Tooltip'
  local record={Signals={}}
  local function bind(sig,fn)local c=sig:Connect(fn);record.Signals[#record.Signals+1]=c end
  if tooltip then
   bind(main.MouseEnter,function()
    hoverSerial+=1;local id=hoverSerial
    task.delay(.35,function()if not self.Destroyed and id==hoverSerial and main.Parent and main.Visible then self:Describe(content,frame)end end)
   end)
   bind(main.MouseLeave,function()self:HideDescription()end)
   function content:ShowDescription()self.__FeatureUI:Describe(self,frame)end
   content.__FeatureUI=self
  end
  local supports=(content.__type=='Toggle'and config.Hotkeys~=false)or type(config.HotkeyCallback)=='function'
  if supports then
   local entry=self.Model:Register(content,function(value)
    if config.HotkeyCallback then Creator.SafeCallback(config.HotkeyCallback,value);content.HotkeyValue=value else content:Set(value,true,true)end
   end,function()if config.HotkeyCallback then return content.HotkeyValue end;return content.Value end,function()return main.Parent~=nil and not content.Locked and not Window.Destroyed end)
   record.Entry=entry;content.HotkeyEntry=entry
   function content:GetHotkeys()return self.__HotkeyController.Model:Export(entry)end
   function content:SetHotkeys(rows)
    local clean={};if type(rows)=='table'then for _,b in ipairs(rows)do if type(b)=='table'then clean[#clean+1]={Key=validKey(b.Key),Mode=b.Mode,Value=b.Value}end end end
    self.__HotkeyController.Model:Import(entry,clean);refreshAll();if activeEntry==entry then rebuildContext();show(editor,false);show(modes,false)end
    return self
   end
   function content:AddHotkey(data)
    data=data or {};local b=self.__HotkeyController.Model:Add(entry,{Key=validKey(data.Key),Mode=data.Mode,Value=data.Value});if activeEntry==entry then rebuildContext()end;refreshAll();return b
   end
   function content:ResetHotkeys()self:SetHotkeys({});return self end
   function content:OpenHotkeys(point)self.__HotkeyController:Open(entry,point)end
   content.__HotkeyController=self
   bind(main.MouseButton2Click,function()if not content.Locked then self:Open(entry)end end)
   if type(config.Hotkeys)=='table'then content:SetHotkeys(config.Hotkeys)end
  end
  registrations[content]=record
  bind(main.Destroying,function()
   if record.Entry then if activeEntry==record.Entry then self:Close()end;self.Model:Unregister(record.Entry)end
   for _,c in ipairs(record.Signals)do c:Disconnect()end;registrations[content]=nil;self:HideDescription();if not self.Destroyed then refreshAll()end
  end)
 end
 connect(Input.InputBegan,function(input,processed)
  local key=keyName(input)
  if self.Picking then
   if input.UserInputType~=Enum.UserInputType.Keyboard and not key then return end
   local capture=self.Picking
   if key=='Escape'then self:CancelCapture();return end
   key=(key=='Backspace'or key=='Delete')and'Unbound'or validKey(key)
   if key~='Unbound'or input.KeyCode==Enum.KeyCode.Backspace or input.KeyCode==Enum.KeyCode.Delete then
    self.Model:Update(capture.Entry,capture.Binding,{Key=key});self:CancelCapture();refreshEditor();rebuildContext();refreshAll()
   end;return
  end
  if key=='Escape'then self:CloseAll();self:HideDescription();return end
  local mouse=input.UserInputType~=Enum.UserInputType.Keyboard
  local at=Vector2.new(input.Position.X,input.Position.Y)
  local function inside(f)return f.Visible and at.X>=f.AbsolutePosition.X and at.X<=f.AbsolutePosition.X+f.AbsoluteSize.X and at.Y>=f.AbsolutePosition.Y and at.Y<=f.AbsolutePosition.Y+f.AbsoluteSize.Y end
  if mouse and (inside(context)or inside(editor)or inside(modes)or inside(all))then return end
  if mouse and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.MouseButton2)then self:CloseAll()end
  if key then self.Model:Input(key,true,processed or Input:GetFocusedTextBox()~=nil or context.Visible or editor.Visible or all.Visible)end
 end)
 connect(Input.InputEnded,function(input)local key=keyName(input);if key then self.Model:Input(key,false,false)end end)
 connect(Input.WindowFocusReleased,function()self.Model:Blur();self:CloseAll();self:HideDescription()end)
 local elapsed=0
 connect(Run.Heartbeat,function(dt)
  elapsed+=dt;if elapsed<.05 then return end;elapsed=0
  for _,e in ipairs(self.Model.Entries)do self.Model:Enforce(e)end
  if Window.Closed or not WindUI.ScreenGui.Enabled or not host.Visible then self:CloseAll();self:HideDescription()end
 end)
 connect(Window.UIElements.Main:GetPropertyChangedSignal('Position'),function()self:CloseAll();self:HideDescription()end)
 local themeSignal=Creator:OnThemeChange(function()if activeBinding then refreshEditor()end end)
 connect(WindUI.ScreenGui:GetPropertyChangedSignal('AbsoluteSize'),function()self:CloseAll();self:HideDescription()end)
 connect(WindUI.UIScaleObj:GetPropertyChangedSignal('Scale'),function()self:CloseAll();self:HideDescription()end)
 function self:Destroy()
  if self.Destroyed then return end;self.Destroyed=true;hoverSerial+=1;self.Picking=nil
  if themeSignal then themeSignal:Disconnect()end
  if valueTween then valueTween:Cancel()end
  for _,c in ipairs(signals)do c:Disconnect()end
  for _,r in pairs(registrations)do for _,c in ipairs(r.Signals)do c:Disconnect()end end
  table.clear(self.Model.Entries)
  for _,f in ipairs({tip,context,editor,modes,all})do if tweens[f]then tweens[f]:Cancel()end;f:Destroy()end
 end
 connect(Window.UIElements.Main.Destroying,function()self:Destroy()end)
 return self
end
return FeatureUI
