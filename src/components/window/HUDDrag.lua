-- Port of the supplied drag_widget: direct grab offset, menu-only drag,
-- normalized positions, watermark thirds alignment and Ctrl-bypassed rulers.
local Creator=require('../../modules/Creator')
local Geometry=require('../../modules/HUDGeometry')
local Input=game:GetService('UserInputService')
local Run=game:GetService('RunService')
local Drag={}
function Drag.New(Window,WindUI,gui)
 local self={Widgets={},Active=nil,Destroyed=false,UIElements={}}
 local signals={}
 local function connect(s,f)local c=s:Connect(f);signals[#signals+1]=c;return c end
 local function menuOpen()return not Window.Destroyed and not Window.Closed and WindUI.ScreenGui.Enabled and Window.UIElements.Main.Visible and Window.UIElements.Main.Main.Visible end
 local token={}
 local function size()local z=gui.AbsoluteSize;return z.X,z.Y end
 local function point(i)
  local p=i and Vector2.new(i.Position.X,i.Position.Y)or(Input:GetMouseLocation()+gui.AbsolutePosition)
  return p-gui.AbsolutePosition
 end
 local function inside(frame,p)
  local a,z=frame.AbsolutePosition-gui.AbsolutePosition,frame.AbsoluteSize
  return p.X>=a.X and p.Y>=a.Y and p.X<=a.X+z.X and p.Y<=a.Y+z.Y
 end
 local rulers={}
 for _,key in ipairs({'Center','Top','Bottom'})do
  rulers[key]=Creator.New('Frame',{Parent=gui,Name='HUDGuide'..key,BackgroundTransparency=1,ThemeTag={BackgroundColor3='Text'},BorderSizePixel=0,ZIndex=1})
 end
 self.UIElements.Guides=rulers
 local function cancel()
  if self.Active then
   local w=self.Active;local vw,vh=size();local p=w.Frame.Position;local z=w.Frame.AbsoluteSize
   w.State=Geometry.Release(p.X.Offset,p.Y.Offset,z.X,z.Y,vw,vh,w.Align)
   if w.OnChange then w.OnChange(w.State)end
  end
  self.Active=nil;self.Input=nil;self.Hits=nil
  if WindUI.CurrentInput==token then WindUI.CurrentInput=nil end
 end
 function self:Layout(w)
  local vw,vh=size();local z=w.Frame.AbsoluteSize
  local x,y=Geometry.Position(w.State,z.X,z.Y,vw,vh)
  w.Frame.Position=UDim2.fromOffset(math.round(x),math.round(y))
 end
 function self:Add(id,frame,state,align,onChange)
  local w={Id=id,Frame=frame,State=state,Align=align,OnChange=onChange,Hover=0,Held=0}
  self.Widgets[id]=w
  local highlight=Creator.New('Frame',{Parent=gui,Name=id..'DragHighlight',BackgroundTransparency=1,ThemeTag={BackgroundColor3='Text'},BorderSizePixel=0,ZIndex=1})
  Creator.New('UICorner',{Parent=highlight,CornerRadius=UDim.new(0,9)})
  w.Highlight=highlight
  connect(frame.InputBegan,function(i)
   if i.UserInputType~=Enum.UserInputType.MouseButton1 and i.UserInputType~=Enum.UserInputType.Touch then return end
   if not menuOpen()or not frame.Visible or self.Active or WindUI.CurrentInput or Input:GetFocusedTextBox()then return end
   local p=point(i);if inside(Window.UIElements.Main,p)then return end
   local a=frame.AbsolutePosition-gui.AbsolutePosition
   self.Active=w;self.Input=i;self.Offset=p-a;WindUI.CurrentInput=token
   local vw,vh=size();w.State=Geometry.Store(a.X,a.Y,frame.AbsoluteSize.X,frame.AbsoluteSize.Y,vw,vh,0)
  end)
  connect(frame:GetPropertyChangedSignal('AbsoluteSize'),function()if self.Active~=w then self:Layout(w)end end)
  self:Layout(w);return w
 end
 connect(Input.InputChanged,function(i)
  local w=self.Active;if not w then return end
  if not menuOpen()then cancel();return end
  if not((self.Input.UserInputType==Enum.UserInputType.Touch and i==self.Input)or(self.Input.UserInputType==Enum.UserInputType.MouseButton1 and i.UserInputType==Enum.UserInputType.MouseMovement))then return end
  local p=point(i)-self.Offset;local z=w.Frame.AbsoluteSize;local vw,vh=size();local x,y=p.X,p.Y
  if w.Align then x,y,self.Hits=Geometry.Snap(x,y,z.X,z.Y,vw,vh,Input:IsKeyDown(Enum.KeyCode.LeftControl)or Input:IsKeyDown(Enum.KeyCode.RightControl))
  else x,y=Geometry.Clamp(x,y,z.X,z.Y,vw,vh);self.Hits=nil end
  w.State=Geometry.Store(x,y,z.X,z.Y,vw,vh,0);self:Layout(w)
 end)
 connect(Input.InputEnded,function(i)if self.Active and(i==self.Input or(self.Input.UserInputType==Enum.UserInputType.MouseButton1 and i.UserInputType==Enum.UserInputType.MouseButton1))then cancel()end end)
 connect(Input.WindowFocusReleased,cancel)
 connect(gui:GetPropertyChangedSignal('AbsoluteSize'),function()cancel();for _,w in pairs(self.Widgets)do self:Layout(w)end end)
 connect(Run.RenderStepped,function(dt)
  if self.Destroyed then return end
  local open=menuOpen();if self.Active and(not open or not self.Active.Frame.Visible)then cancel()end
  local p=point();local alpha=1-math.exp(-4*math.min(dt,.1))
  for _,w in pairs(self.Widgets)do
   local visible=w.Frame.Visible and w.Frame.GroupTransparency<.99
   local hover=open and visible and not inside(Window.UIElements.Main,p)and(inside(w.Frame,p)or self.Active==w)
   w.Hover+=( (hover and 1 or 0)-w.Hover)*alpha
   w.Held+=( (self.Active==w and 1 or 0)-w.Held)*alpha
   w.Frame.Active=open and visible
   local a,z=w.Frame.Position,w.Frame.AbsoluteSize
   w.Highlight.Position=a-UDim2.fromOffset(3,3);w.Highlight.Size=UDim2.fromOffset(z.X+6,z.Y+6)
   w.Highlight.Visible=open and visible
   w.Highlight.BackgroundTransparency=1-(12+24*w.Hover)/255*(1-w.Frame.GroupTransparency)
  end
  local vw,vh=size()
  rulers.Center.Position=UDim2.fromOffset(math.floor(vw/2),0);rulers.Center.Size=UDim2.fromOffset(1,vh)
  rulers.Top.Position=UDim2.fromOffset(0,32);rulers.Top.Size=UDim2.fromOffset(vw,1)
  rulers.Bottom.Position=UDim2.fromOffset(0,vh-32);rulers.Bottom.Size=UDim2.fromOffset(vw,1)
  for key,line in pairs(rulers)do
   local active=self.Active and self.Active.Align and not Input:IsKeyDown(Enum.KeyCode.LeftControl)and not Input:IsKeyDown(Enum.KeyCode.RightControl)
   local target=active and(self.Hits and self.Hits[key]and .45 or .1)or 0
   local current=1-line.BackgroundTransparency;line.BackgroundTransparency=1-(current+(target-current)*(1-math.exp(-8*math.min(dt,.1))))
  end
 end)
 function self:SetState(id,state)
  local w=self.Widgets[id];if not w or not Geometry.Valid(state)then return false end
  if self.Active==w then cancel()end
  w.State={X=state.X,Y=state.Y,Anchor=state.Anchor};self:Layout(w);return true
 end
 function self:GetState(id)local s=self.Widgets[id].State;return {X=s.X,Y=s.Y,Anchor=s.Anchor}end
 function self:Cancel()cancel()end
 function self:Destroy()
  if self.Destroyed then return end;cancel();self.Destroyed=true
  for _,c in ipairs(signals)do c:Disconnect()end
  for _,w in pairs(self.Widgets)do w.Highlight:Destroy()end
  for _,line in pairs(rulers)do line:Destroy()end
 end
 return self
end
return Drag
