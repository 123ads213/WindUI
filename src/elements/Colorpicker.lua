-- WindUI color element with a multi-stop editor; first two callback args remain compatible.
local Creator=require('../modules/Creator')
local ColorValue=require('../modules/ColorValue')
local Popup=require('../components/window/ColorPopup')
local New=Creator.New
local Element={}
function Element:New(Config)
 local initial=assert(ColorValue.Normalize(Config.Gradient or Config.Default or Config.Value or Color3.new(1,1,1),nil,Config.Transparency))
 local state=ColorValue.Clone(initial)
 local self={__type='Colorpicker',Tab=Config.Tab,Title=Config.Title or'Colorpicker',Desc=Config.Desc,Locked=Config.Locked or false,LockedTitle=Config.LockedTitle,
  Default=state.Stops[1].Color,Transparency=state.Stops[1].Transparency,Callback=Config.Callback or function()end,UIElements={},IsShowed=false,AllowGradient=Config.AllowGradient~=false}
 self.ColorpickerFrame=require('../components/window/Element')({Title=self.Title,Desc=self.Desc,Parent=Config.Parent,TextOffset=44,Hover=false,Tab=Config.Tab,Index=Config.Index,Window=Config.Window,ElementTable=self,ParentConfig=Config,Tags=Config.Tags})
 local preview=New('TextButton',{Name='ColorPreview',Parent=self.ColorpickerFrame.UIElements.Main,Text='',AutoButtonColor=false,Size=UDim2.fromOffset(30,30),AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,0,.5,0),BackgroundTransparency=1,ZIndex=3})
 local checker=New('ImageLabel',{Parent=preview,Name='Checker',Image='rbxassetid://14204231522',ScaleType='Tile',TileSize=UDim2.fromOffset(12,12),Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(160,160,160),ZIndex=3})
 New('UICorner',{Parent=checker,CornerRadius=UDim.new(0,7)})
 local fill=New('Frame',{Parent=checker,Name='Color',Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=4})
 New('UICorner',{Parent=fill,CornerRadius=UDim.new(0,7)})
 local gradient=New('UIGradient',{Parent=fill})
 self.UIElements.Colorpicker=preview;self.UIElements.Preview=fill;self.UIElements.Gradient=gradient
 local editor
 function self:GetValue()return ColorValue.Clone(state)end
 function self:GetGradient()return #state.Stops>1 and ColorValue.Clone(state)or nil end
 function self:GetColorSequence()local c,t=ColorValue.Sequences(state);return c,t,state.Rotation end
 function self:SetState(value,callback)
  local normalized,err=ColorValue.Normalize(value)
  if not normalized then return false,err end
  if not self.AllowGradient and #normalized.Stops>1 then return false,'Gradients are disabled on this element'end
  state=normalized;self.Default=state.Stops[1].Color;self.Transparency=state.Stops[1].Transparency;self.Gradient=self:GetGradient()
  gradient.Color,gradient.Transparency=ColorValue.Sequences(state);gradient.Rotation=state.Rotation
  if editor then editor:Refresh()end
  if callback then Creator.SafeCallback(self.Callback,self.Default,self.Transparency,self:GetGradient())end
  return true
 end
 function self:SetGradient(value,callback)return self:SetState(value,callback)end
 function self:Update(color,transparency)
  local normalized,err=ColorValue.Normalize(color,nil,transparency==nil and self.Transparency or transparency)
  if not normalized then return false,err end
  return self:SetState(normalized,false)
 end
 function self:Set(color,transparency)return self:Update(color,transparency)end
 function self:Reset(callback)return self:SetState(initial,callback~=false)end
 function self:Export()return ColorValue.Encode(state)end
 function self:Import(data)
  local value,err=ColorValue.Decode(data);if not value then return false,err end;return self:SetState(value,false)
 end
 function self:Lock()self.Locked=true;if editor then editor:Close()end;return self.ColorpickerFrame:Lock(self.LockedTitle)end
 function self:Unlock()self.Locked=false;return self.ColorpickerFrame:Unlock()end
 function self:Open()
  if self.Locked or Config.Window.Destroyed then return end
  if not editor then editor=Popup.New(self,Config.Window,Config.WindUI);self.Editor=editor end
  editor:Open(preview);return editor
 end
 preview.MouseButton1Click:Connect(function()self:Open()end)
 self.ColorpickerFrame.UIElements.Main.Destroying:Connect(function()if editor then editor:Destroy()end end)
 self:SetState(state,false)
 if self.Locked then self:Lock()end
 return self.__type,self
end
return Element
