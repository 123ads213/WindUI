-- Saturation/value map from upstream WindUI, plus gradient stops and text formats.
local Creator=require('../../modules/Creator')
local CV=require('../../modules/ColorValue')
local Shadow=require('../ui/PopupShadow')
local Input=game:GetService('UserInputService')
local New,Tween=Creator.New,Creator.Tween
local Popup={}
function Popup.New(Element,Window,WindUI)
 local self={Opened=false,Destroyed=false,Selected=1,Format='HEX',UIElements={}}
 local host=Window.UIElements.Main.Main
 local signals={}
 local function connect(signal,fn)local c=signal:Connect(fn);signals[#signals+1]=c;return c end
 local function corner(p,n)New('UICorner',{Parent=p,CornerRadius=UDim.new(0,n)})end
 local function label(p,name,text,x,y,w,h,size,secondary)
  return New('TextLabel',{Parent=p,Name=name,Text=text,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundTransparency=1,TextSize=size or 15,TextStrokeTransparency=1,TextXAlignment='Left',TextTruncate='AtEnd',FontFace=Font.new(Creator.Font,Enum.FontWeight.Medium),ThemeTag={TextColor3=secondary and'Placeholder'or'Text'},ZIndex=704})
 end
 local function icon(p,name,x,y,size)
  local im=Creator.Image(name,name,0,Window.Folder,'ColorIcon',true,false,'Icon');im.Parent=p;im.Position=UDim2.fromOffset(x,y);im.Size=UDim2.fromOffset(size,size);im.ZIndex=705;im.ImageLabel.ZIndex=705;return im
 end
 local panel=New('CanvasGroup',{Parent=host,Name='GradientColorpicker',Size=UDim2.fromOffset(292,396),BackgroundTransparency=0,ThemeTag={BackgroundColor3='Dialog'},GroupTransparency=1,Visible=false,ZIndex=700,Active=true});corner(panel,14);Shadow.New(panel)
 local function button(parent,name,title,x,y,w,h,fn,symbol)
  local b=New('TextButton',{Parent=parent,Name=name,Text='',Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundTransparency=1,BorderSizePixel=0,TextStrokeTransparency=1,AutoButtonColor=false,ThemeTag={BackgroundColor3='ElementBackground'},ZIndex=703});corner(b,7)
  if title~=''then local t=label(b,'Label',title,8,0,w-16,h,14);t.TextXAlignment='Center'end
  if symbol then icon(b,symbol,(w-18)/2,(h-18)/2,18)end
  b.MouseEnter:Connect(function()if name=='Format'then Tween(b.Label,.12,{TextTransparency=0}):Play()else Tween(b,.12,{BackgroundTransparency=0}):Play()end end)
  b.MouseLeave:Connect(function()if name=='Format'then Tween(b.Label,.12,{TextTransparency=.12}):Play()else Tween(b,.12,{BackgroundTransparency=1}):Play()end end)
  if fn then b.MouseButton1Click:Connect(fn)end;return b
 end
 local stops=New('ScrollingFrame',{Parent=panel,Name='Stops',Position=UDim2.fromOffset(14,10),Size=UDim2.fromOffset(226,32),CanvasSize=UDim2.new(),AutomaticCanvasSize='X',ScrollingDirection='X',ScrollBarThickness=2,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=703})
 local add=button(panel,'AddStop','',252,10,26,28,function()self:AddStop()end,'plus')
 local map=New('ImageButton',{Parent=panel,Name='SV',Position=UDim2.fromOffset(14,48),Size=UDim2.fromOffset(264,252),Image='rbxassetid://4155801252',AutoButtonColor=false,BackgroundColor3=Color3.fromHSV(0,1,1),BorderSizePixel=0,ZIndex=703});corner(map,8)
 local cursor=New('Frame',{Parent=map,Name='Cursor',Size=UDim2.fromOffset(10,10),AnchorPoint=Vector2.new(.5,.5),BackgroundTransparency=1,ZIndex=705});corner(cursor,5);New('UIStroke',{Parent=cursor,Thickness=2,Color=Color3.new(1,1,1)})
 local function bar(name,y,checker)
  local b=New('TextButton',{Parent=panel,Name=name,Text='',AutoButtonColor=false,Position=UDim2.fromOffset(14,y-7),Size=UDim2.fromOffset(264,24),BackgroundTransparency=1,ZIndex=703})
  local track=New('Frame',{Parent=b,Name='Track',Position=UDim2.fromOffset(0,7),Size=UDim2.new(1,0,0,10),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=703});corner(track,5)
  if checker then local check=New('ImageLabel',{Parent=track,Name='Checker',Image='rbxassetid://14204231522',ScaleType='Tile',TileSize=UDim2.fromOffset(10,10),Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ZIndex=703});corner(check,5)end
  local fill=New('Frame',{Parent=track,Name='Fill',Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=704});corner(fill,5)
  local grad=New('UIGradient',{Parent=fill})
  local thumb=New('Frame',{Parent=track,Name='Thumb',Size=UDim2.fromOffset(5,16),Position=UDim2.new(0,0,.5,-8),AnchorPoint=Vector2.new(.5,0),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=705});corner(thumb,2)
  New('UIStroke',{Parent=thumb,Thickness=1,Color=Color3.new(0,0,0),Transparency=.5})
  return b,grad,thumb
 end
 local hue,hueGradient,hueThumb=bar('Hue',312,false)
 local hueKeys={};for i=0,6 do hueKeys[#hueKeys+1]=ColorSequenceKeypoint.new(i/6,Color3.fromHSV(i/6,1,1))end;hueGradient.Color=ColorSequence.new(hueKeys)
 local alpha,alphaGradient,alphaThumb=bar('Alpha',336,true)
 alphaGradient.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)})
 local format=button(panel,'Format','HEX',14,356,54,32,function()self:ShowFormats(true)end)
 local arrow=icon(format,'chevron-down',0,8,16)
 format.Label.Position=UDim2.fromOffset(18,0);format.Label.Size=UDim2.new(1,-18,1,0);format.Label.TextSize=14;format.Label.TextTransparency=.12
 local input=New('TextBox',{Parent=panel,Name='ColorText',Position=UDim2.fromOffset(72,356),Size=UDim2.fromOffset(132,32),BackgroundTransparency=.45,BorderSizePixel=0,TextStrokeTransparency=1,ThemeTag={BackgroundColor3='LabelBackground',TextColor3='Text',PlaceholderColor3='Placeholder'},ClearTextOnFocus=false,FontFace=Font.new(Creator.Font,Enum.FontWeight.Medium),TextSize=14,Text='',TextXAlignment='Left',ZIndex=704});corner(input,6);New('UIPadding',{Parent=input,PaddingLeft=UDim.new(0,7),PaddingRight=UDim.new(0,5)})
 local opacity=New('TextBox',{Parent=panel,Name='Opacity',Position=UDim2.fromOffset(208,356),Size=UDim2.fromOffset(44,32),BackgroundTransparency=.45,BorderSizePixel=0,TextStrokeTransparency=1,ThemeTag={BackgroundColor3='LabelBackground',TextColor3='Text'},ClearTextOnFocus=false,FontFace=Font.new(Creator.Font,Enum.FontWeight.Medium),TextSize=14,Text='',ZIndex=704});corner(opacity,6)
 local status=label(panel,'Status','',14,396,264,20,14,true);status.Visible=false
 local reset=button(panel,'Reset','',256,356,22,32,function()Element:Reset();self.Selected=1;self:Refresh()end,'rotate-ccw')
 local formats=New('CanvasGroup',{Parent=host,Name='ColorFormats',Size=UDim2.fromOffset(100,140),GroupTransparency=1,Visible=false,BackgroundTransparency=0,ThemeTag={BackgroundColor3='Dialog'},ZIndex=710,Active=true});corner(formats,9);Shadow.New(formats)
 local context=New('CanvasGroup',{Parent=host,Name='ColorActions',Size=UDim2.fromOffset(148,116),GroupTransparency=1,Visible=false,BackgroundTransparency=0,ThemeTag={BackgroundColor3='Dialog'},ZIndex=720,Active=true});corner(context,9);Shadow.New(context)
 local copy=button(context,'Copy','Copy',6,6,136,32,function()self:Copy();self:ShowActions(false)end,'copy')
 local paste=button(context,'Paste','Paste',6,42,136,32,function()self:Paste();self:ShowActions(false)end,'clipboard-paste')
 local remove=button(context,'Remove','Delete color',6,78,136,32,function()self:RemoveStop();self:ShowActions(false)end,'trash-2')
 for _,b in ipairs({copy,paste,remove})do
  b.ZIndex=721;b.Label.ZIndex=723;b.Label.TextXAlignment='Left';b.Label.Position=UDim2.fromOffset(36,0);b.Label.Size=UDim2.new(1,-42,1,0);b.Label.TextSize=15
  for _,im in ipairs(b:GetChildren())do if im:IsA('Frame')then im.Position=UDim2.fromOffset(10,8);im.ZIndex=722;if im:FindFirstChild('ImageLabel')then im.ImageLabel.ZIndex=722 end end end
 end
 status:GetPropertyChangedSignal('Text'):Connect(function()
  status.Visible=status.Text~=''
  if panel.Parent then panel.Size=UDim2.fromOffset(292,status.Visible and 424 or 396)end
 end)
 local targets,tweens={},{}
 local function show(p,v)
  if self.Destroyed or targets[p]==v then return end;targets[p]=v
  if tweens[p]then tweens[p]:Cancel()end;if v then p.Visible=true end
  local t=Tween(p,.16,{GroupTransparency=v and 0 or 1});tweens[p]=t;t:Play()
  if not v then task.delay(.17,function()if not self.Destroyed and tweens[p]==t then p.Visible=false end end)end
 end
 local function effectiveScale()return WindUI.UIScaleObj.Scale end
 local function place(p,x,y)
  local s=effectiveScale();local origin=WindUI.ScreenGui.AbsolutePosition;local z=WindUI.ScreenGui.AbsoluteSize;local w,h=p.Size.X.Offset*s,p.Size.Y.Offset*s
  x=math.clamp(x,origin.X+8,math.max(origin.X+8,origin.X+z.X-w-8));y=math.clamp(y,origin.Y+8,math.max(origin.Y+8,origin.Y+z.Y-h-8))
  p.Position=UDim2.fromOffset((x-host.AbsolutePosition.X)/s,(y-host.AbsolutePosition.Y)/s)
 end
 function self:ShowFormats(v)
  if not self.Opened then return end
  if v then
   show(context,false)
   local a,z=format.AbsolutePosition,format.AbsoluteSize;local scale=effectiveScale()
   local y=a.Y+z.Y+4*scale
   local origin,size=WindUI.ScreenGui.AbsolutePosition,WindUI.ScreenGui.AbsoluteSize
   if y+140*scale>origin.Y+size.Y-8 then y=a.Y-144*scale end
   place(formats,a.X,y);show(formats,true)
  else show(formats,false)end
 end
 function self:ShowActions(v,anchor)
  if not self.Opened then return end
  if v then
   show(formats,false);local a,z=anchor.AbsolutePosition,anchor.AbsoluteSize
   place(context,a.X,a.Y+z.Y+5*effectiveScale());show(context,true)
  else show(context,false)end
 end
 for i,name in ipairs({'HEX','RGB','HSV','HSL'})do
  local b=button(formats,name,name,6,6+(i-1)*32,88,30,function()self.Format=name;self:Refresh();self:ShowFormats(false)end)
  b.ZIndex=711;b.Label.ZIndex=712;b.Label.TextSize=15
 end
 connect(format.MouseEnter,function()self:ShowFormats(true)end)
 local overFormat,overFormats=false,false
 connect(format.MouseEnter,function()overFormat=true end)
 connect(format.MouseLeave,function()overFormat=false;task.delay(.22,function()if not self.Destroyed and not overFormat and not overFormats then self:ShowFormats(false)end end)end)
 connect(formats.MouseEnter,function()overFormats=true end)
 connect(formats.MouseLeave,function()overFormats=false;task.delay(.22,function()if not self.Destroyed and not overFormat and not overFormats then self:ShowFormats(false)end end)end)
 local drag,dragInput
 local chips={}
 local h,s,v=0,0,1
 local refreshing=false
 local function checker(parent,name,x,color,t)
  local b=New('TextButton',{Parent=parent,Name=name,Text='',AutoButtonColor=false,Position=UDim2.fromOffset(x,2),Size=UDim2.fromOffset(24,24),BackgroundTransparency=1,ZIndex=704})
  local c=New('ImageLabel',{Parent=b,Image='rbxassetid://14204231522',ScaleType='Tile',TileSize=UDim2.fromOffset(10,10),Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ZIndex=704});corner(c,6)
  local f=New('Frame',{Parent=c,Size=UDim2.fromScale(1,1),BackgroundColor3=color,BackgroundTransparency=t,BorderSizePixel=0,ZIndex=705});corner(f,6)
  return b,f
 end
 function self:Refresh()
  if self.Destroyed then return end;refreshing=true
  local state=Element:GetValue();self.Selected=math.clamp(self.Selected,1,#state.Stops);local stop=state.Stops[self.Selected]
  if not drag then h,s,v=stop.Color:ToHSV()end;map.BackgroundColor3=Color3.fromHSV(h,1,1);cursor.Position=UDim2.fromScale(s,1-v)
  hueThumb.Position=UDim2.new(h,0,.5,-8);alphaThumb.Position=UDim2.new(1-stop.Transparency,0,.5,-8);alphaGradient.Color=ColorSequence.new(stop.Color)
  if not input:IsFocused()then input.Text=CV.Format(stop.Color,stop.Transparency,self.Format)end
  if not opacity:IsFocused()then opacity.Text=tostring(math.round((1-stop.Transparency)*100))..'%'end
  format.Label.Text=self.Format
  if #chips~=#state.Stops then
   for _,child in ipairs(stops:GetChildren())do child:Destroy()end;table.clear(chips)
   for i,item in ipairs(state.Stops)do
    local chip,fill=checker(stops,'Stop_'..i,(i-1)*36,item.Color,item.Transparency)
    local selected=New('Frame',{Parent=chip,Name='Selected',Position=UDim2.new(.5,-7,1,2),Size=UDim2.fromOffset(14,2),BackgroundTransparency=0,BorderSizePixel=0,ThemeTag={BackgroundColor3='Text'},ZIndex=706});corner(selected,1)
    chips[i]={Button=chip,Fill=fill,Selected=selected}
    chip.MouseButton1Click:Connect(function()self.Selected=i;self:ShowActions(false);self:Refresh()end)
    chip.MouseButton2Click:Connect(function()self.Selected=i;self:Refresh();self:ShowActions(true,chip)end)
   end
  end
  for i,item in ipairs(state.Stops)do chips[i].Fill.BackgroundColor3=item.Color;chips[i].Fill.BackgroundTransparency=item.Transparency;chips[i].Selected.Visible=i==self.Selected end
  add.Visible=Element.AllowGradient;remove.Visible=#state.Stops>1
  status.Text='';status.Visible=false;panel.Size=UDim2.fromOffset(292,396)
  refreshing=false
 end
 local function commit(color,transparency)
  local state=Element:GetValue();local stop=state.Stops[self.Selected];if color then stop.Color=color end;if transparency~=nil then stop.Transparency=math.clamp(transparency,0,1)end
  Element:SetState(state,true)
 end
 function self:AddStop()
  if not Element.AllowGradient then return end
  local state=Element:GetValue();local selected,err=CV.Add(state);if not selected then status.Text=err;return end
  self.Selected=selected;Element:SetState(state,true);task.defer(function()if not self.Destroyed then stops.CanvasPosition=Vector2.new(math.max(0,(self.Selected-1)*36-190),0)end end)
 end
 function self:RemoveStop()
  local state=Element:GetValue();if CV.Remove(state,self.Selected)then self.Selected=math.min(self.Selected,#state.Stops);Element:SetState(state,true)end
 end
 function self:ApplyText(text)
  local color,t,err=CV.Parse(text,self.Format)
  if not color then status.Text=err or'Invalid color';return false end
  local stop=Element:GetValue().Stops[self.Selected]
  local alpha=t==nil and stop.Transparency or t
  -- Enter and FocusLost may both fire; apply an actual change only once.
  if color~=stop.Color or math.abs(alpha-stop.Transparency)>1e-6 then commit(color,alpha)end
  input.Text=CV.Format(color,alpha,self.Format);status.Text='';return true
 end
 function self:CommitText()return self:ApplyText(input.Text)end
 connect(input.FocusLost,function()if self.Opened then self:CommitText()end end)
 connect(input.InputBegan,function(key)
  if self.Opened and(key.KeyCode==Enum.KeyCode.Return or key.KeyCode==Enum.KeyCode.KeypadEnter)then self:CommitText()end
 end)
 connect(opacity.FocusLost,function()
  local n=tonumber((opacity.Text:gsub('%%','')));if n and n==n and n>=0 and n<=100 then commit(nil,1-n/100)else status.Text='Opacity must be 0–100%'end
 end)
 function self:Copy(localOnly)
  local stop=Element:GetValue().Stops[self.Selected]
  local text=CV.Format(stop.Color,stop.Transparency,self.Format)
  -- Menu-local clipboard works even when the executor cannot read the OS clipboard.
  WindUI.ColorClipboard={Color=stop.Color,Transparency=stop.Transparency}
  local copyFn=setclipboard or toclipboard
  local copied=false
  if not localOnly and type(copyFn)=='function'then copied=pcall(copyFn,text)end
  status.Text=copied and'Color copied'or'Color copied in menu'
  return true
 end
 function self:Paste(text)
  if type(text)=='string'then return self:ApplyText(text)end
  local reader=getclipboard or get_clipboard or readclipboard or(type(syn)=='table'and syn.read_clipboard)
  if type(reader)=='function'then
   local ok,value=pcall(reader)
   if ok and type(value)=='string'and value:match('%S')then return self:ApplyText(value)end
  end
  local cached=WindUI.ColorClipboard
  if type(cached)=='table'and typeof(cached.Color)=='Color3'and type(cached.Transparency)=='number'then
   commit(cached.Color,cached.Transparency)
   input.Text=CV.Format(cached.Color,cached.Transparency,self.Format)
   return true
  end
  -- Defer until the context-menu click has finished so it cannot steal focus.
  status.Text='External color: Ctrl+V here, then Enter'
  task.defer(function()
   if self.Destroyed or not self.Opened then return end
   input:CaptureFocus();input.CursorPosition=#input.Text+1;input.SelectionStart=1
  end)
  return false,'keyboard-paste-required'
 end
 local token={}
 local function stopDrag()drag=nil;dragInput=nil;if WindUI.CurrentInput==token then WindUI.CurrentInput=nil end end
 local function point(inputObject)
  -- InputObject.Position is already inset-adjusted; GetMouseLocation is not.
  if inputObject then return Vector2.new(inputObject.Position.X,inputObject.Position.Y)end
  return Input:GetMouseLocation()+WindUI.ScreenGui.AbsolutePosition
 end
 local function read(inputObject)
  if not drag then return end
  local at=point(inputObject)
  if drag=='SV'then
   s=math.clamp((at.X-map.AbsolutePosition.X)/map.AbsoluteSize.X,0,1);v=1-math.clamp((at.Y-map.AbsolutePosition.Y)/map.AbsoluteSize.Y,0,1);commit(Color3.fromHSV(h,s,v))
  elseif drag=='Hue'then
   h=math.clamp((at.X-hue.AbsolutePosition.X)/hue.AbsoluteSize.X,0,1);commit(Color3.fromHSV(h,s,v))
  else commit(nil,1-math.clamp((at.X-alpha.AbsolutePosition.X)/alpha.AbsoluteSize.X,0,1))end
 end
 local function bindDrag(control,kind)
  connect(control.InputBegan,function(inputObject)
   if inputObject.UserInputType~=Enum.UserInputType.MouseButton1 and inputObject.UserInputType~=Enum.UserInputType.Touch then return end
   if not self.Opened or Element.Locked or(WindUI.CurrentInput and WindUI.CurrentInput~=token)then return end
   WindUI.CurrentInput=token;drag=kind;dragInput=inputObject;self:ShowFormats(false);read(inputObject)
  end)
 end
 bindDrag(map,'SV');bindDrag(hue,'Hue');bindDrag(alpha,'Alpha')
 connect(Input.InputChanged,function(inputObject)if drag and((dragInput.UserInputType==Enum.UserInputType.Touch and inputObject==dragInput)or(dragInput.UserInputType==Enum.UserInputType.MouseButton1 and inputObject.UserInputType==Enum.UserInputType.MouseMovement))then read(inputObject)end end)
 connect(Input.InputEnded,function(inputObject)if drag and(inputObject==dragInput or(dragInput.UserInputType==Enum.UserInputType.MouseButton1 and inputObject.UserInputType==Enum.UserInputType.MouseButton1))then stopDrag()end end)
 local function inside(p,at)return p.Visible and at.X>=p.AbsolutePosition.X and at.X<=p.AbsolutePosition.X+p.AbsoluteSize.X and at.Y>=p.AbsolutePosition.Y and at.Y<=p.AbsolutePosition.Y+p.AbsoluteSize.Y end
 connect(Input.InputBegan,function(inputObject)
  if not self.Opened then return end
  if inputObject.KeyCode==Enum.KeyCode.Escape then self:Close();return end
  if inputObject.UserInputType==Enum.UserInputType.MouseButton1 or inputObject.UserInputType==Enum.UserInputType.MouseButton2 then
   local at=point(inputObject);if not inside(panel,at)and not inside(formats,at)and not inside(context,at)and not inside(Element.UIElements.Colorpicker,at)then self:Close()end
  end
 end)
 function self:Open(anchor)
  if self.Destroyed or Element.Locked then return end
  if Window.ActiveColorPopup and Window.ActiveColorPopup~=self then Window.ActiveColorPopup:Close()end
  Window.ActiveColorPopup=self
  if Window.Profile then Window.Profile:Close()end
  if Window.FeatureUI then Window.FeatureUI:CloseAll();Window.FeatureUI:HideDescription()end
  local s=effectiveScale();local a,z=anchor.AbsolutePosition,anchor.AbsoluteSize;local x=a.X+z.X+8*s
  if x+292*s>WindUI.ScreenGui.AbsolutePosition.X+WindUI.ScreenGui.AbsoluteSize.X-8 then x=a.X-300*s end
  place(panel,x,a.Y);self.Opened=true;Element.IsShowed=true;self:Refresh();show(panel,true)
 end
 function self:Close()
  if self.Destroyed then return end
  self.Opened=false;Element.IsShowed=false;stopDrag();show(formats,false);show(context,false);show(panel,false)
  if Window.ActiveColorPopup==self then Window.ActiveColorPopup=nil end
 end
 connect(Input.WindowFocusReleased,function()self:Close()end)
 connect(WindUI.ScreenGui:GetPropertyChangedSignal('Enabled'),function()if not WindUI.ScreenGui.Enabled then self:Close()end end)
 connect(host:GetPropertyChangedSignal('Visible'),function()if not host.Visible then self:Close()end end)
 connect(Window.UIElements.Main:GetPropertyChangedSignal('Position'),function()self:Close()end)
 connect(Window.UIElements.Main:GetPropertyChangedSignal('Size'),function()self:Close()end)
 local tabPage=Element.Tab
 if tabPage and tabPage.UIElements and tabPage.UIElements.ContainerFrameCanvas then connect(tabPage.UIElements.ContainerFrameCanvas:GetPropertyChangedSignal('Visible'),function()if not tabPage.UIElements.ContainerFrameCanvas.Visible then self:Close()end end)end
 connect(WindUI.UIScaleObj:GetPropertyChangedSignal('Scale'),function()self:Close()end)
 connect(WindUI.ScreenGui:GetPropertyChangedSignal('AbsoluteSize'),function()self:Close()end)
 function self:Destroy()
  if self.Destroyed then return end;self:Close();self.Destroyed=true
  for _,c in ipairs(signals)do c:Disconnect()end
  for _,t in pairs(tweens)do t:Cancel()end;panel:Destroy();formats:Destroy();context:Destroy()
 end
 connect(Window.UIElements.Main.Destroying,function()self:Destroy()end)
 self.UIElements={Panel=panel,Stops=stops,Add=add,SV=map,Cursor=cursor,Hue=hue,Alpha=alpha,ColorText=input,Opacity=opacity,Format=format,Formats=formats,Status=status,Reset=reset,Copy=copy,Paste=paste,Remove=remove,Actions=context}
 return self
end
return Popup
