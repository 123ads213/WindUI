-- Soft native WindUI shadow, outside CanvasGroup clipping; no white outline.
local Creator=require('../../modules/Creator')
local Shadow={}
function Shadow.New(panel)
 local shadow=Creator.New('ImageLabel',{Name=panel.Name..'Shadow',Parent=panel.Parent,Image='rbxassetid://8992230677',BackgroundTransparency=1,
  ScaleType='Slice',SliceCenter=Rect.new(99,99,99,99),ImageTransparency=1,ThemeTag={ImageColor3='WindowShadow'},ZIndex=math.max(1,panel.ZIndex-1),Active=false})
 local signals={}
 local function sync()
  if not shadow.Parent or not panel.Parent then return end
  shadow.AnchorPoint=panel.AnchorPoint
  shadow.Position=panel.Position+UDim2.fromOffset(-40+80*panel.AnchorPoint.X,-40+80*panel.AnchorPoint.Y)
  shadow.Size=panel.Size+UDim2.fromOffset(80,80)
  shadow.Visible=panel.Visible
  local fade=panel:IsA('CanvasGroup')and panel.GroupTransparency or 0
  -- Same dark sliced shadow and central strength as the main window.
  shadow.ImageTransparency=1-.4*(1-fade)*(1-panel.BackgroundTransparency)
 end
 for _,key in ipairs({'Position','Size','Visible','AnchorPoint','BackgroundTransparency'})do signals[#signals+1]=panel:GetPropertyChangedSignal(key):Connect(sync)end
 if panel:IsA('CanvasGroup')then signals[#signals+1]=panel:GetPropertyChangedSignal('GroupTransparency'):Connect(sync)end
 signals[#signals+1]=panel.Destroying:Connect(function()for _,c in ipairs(signals)do c:Disconnect()end;shadow:Destroy()end)
 sync();return shadow
end
return Shadow
