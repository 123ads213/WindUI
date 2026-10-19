-- Run in the Roblox client with ColorValue required/inlined by the test runner.
local CV=require('../src/modules/ColorValue')
local d=assert(getgenv().WindUIForkDemo)
local passed=0
local function check(v,msg)assert(v,msg);passed+=1 end
local function near(a,b)return math.abs(a-b)<.006 end
local function same(a,b)return near(a.R,b.R)and near(a.G,b.G)and near(a.B,b.B)end
local c=d.GradientColor
local original=c:Export()
local previousConfig=d.Window.CurrentConfig
local cleanup
local ok,err=pcall(function()
 for _,rgb in ipairs({Color3.new(0,0,0),Color3.new(1,1,1),Color3.fromRGB(255,0,100),Color3.fromRGB(64,128,192)})do
  for _,fmt in ipairs({'HEX','RGB','HSV','HSL'})do
   for _,t in ipairs({0,.3,1})do
    local parsed,alpha=CV.Parse(CV.Format(rgb,t,fmt),fmt)
    check(parsed and same(parsed,rgb)and near(alpha,t),'format round trip '..fmt..'/'..t)
   end
  end
 end
 for _,text in ipairs({'#12345','#QQQQQQ','rgb(256,0,0)','rgb(-1,0,0)','hsv(361,20,20)','hsl(40,110,20)','rgb(0,0,0,2)','rgba(1,2)','not a color','hsv(nan,1,1)'})do
  check(not CV.Parse(text,'HEX'),'invalid color rejected: '..text)
 end
 local parsed,t=CV.Parse('#0f08','HEX');check(same(parsed,Color3.new(0,1,0))and near(t,1-136/255),'short hex with alpha')
 parsed,t=CV.Parse('rgba(100%, 0%, 50%, 25%)','HEX');check(same(parsed,Color3.new(1,0,.5))and t==.75,'percent RGB and alpha')
 check(not CV.Normalize({{Position=0,Color=Color3.new()},{Position=0,Color=Color3.new()}}),'duplicate stops rejected')
 check(not CV.Decode({Stops={{Color='oops'}}}),'invalid config rejected')
 local single=assert(CV.Normalize(Color3.new(1,0,0),nil,1));local cs,ts=CV.Sequences(single)
 check(#cs.Keypoints==2 and ts.Keypoints[1].Value==1,'solid sequence and full transparency')
 local state=CV.Clone(single)
 while #state.Stops<16 do check(CV.Add(state)~=nil and CV.Normalize(state)~=nil,'add valid stop '..#state.Stops)end
 check(not CV.Add(state),'16 color limit')
 while #state.Stops>1 do check(CV.Remove(state,1)and CV.Normalize(state)~=nil,'remove maintains endpoints')end
 check(not CV.Remove(state,1),'cannot delete only color')
 local before=c:Export();check(not c:Update('bad')and c:Export().Stops[1].Color==before.Stops[1].Color,'invalid Update leaves state unchanged')
 check(not c:Import({Stops={{Color='bad'}}}),'invalid Import rejected')
 d.Profile:Close();d.Profile:SetTransparency(0);d.Library:SetTheme('Dark');d.Themes:Select();task.wait(.4)
 local e=c:Open();task.wait(.2);check(e.Opened and e.UIElements.Panel.Visible,'popup opens')
 local chip=e.UIElements.Stops:FindFirstChild('Stop_1');firesignal(chip.MouseButton2Click);task.wait(.18);check(e.UIElements.Actions.Visible,'right click swatch opens Copy/Paste');check(e.UIElements.Actions.Copy.Label.FontFace.Weight==Enum.FontWeight.Medium,'native medium font');e:ShowActions(false)
 local n=#c:GetValue().Stops;firesignal(e.UIElements.Add.MouseButton1Click);check(#c:GetValue().Stops==n+1,'plus adds a color')
 firesignal(e.UIElements.Remove.MouseButton1Click);check(#c:GetValue().Stops==n,'remove selected color')
 e.Selected=2;e:Refresh();check(e:ApplyText('#FF800080'),'text accepted')
 local selected=c:GetValue().Stops[2];check(same(selected.Color,Color3.fromRGB(255,128,0))and near(selected.Transparency,127/255),'selected color alpha updated')
 check(d.Calls.GradientColor and same(d.Calls.GradientColor.Stops[2].Color,selected.Color),'third callback argument is gradient')
 local detached=c:GetValue();detached.Stops[2].Color=Color3.new();check(not same(c:GetValue().Stops[2].Color,Color3.new()),'returned values detached')
 for _,fmt in ipairs({'RGB','HSV','HSL','HEX'})do
  firesignal(e.UIElements.Format.MouseEnter);task.wait(.18);check(e.UIElements.Formats.Visible,'hover format list');check(math.abs(e.UIElements.Formats.AbsolutePosition.X-e.UIElements.Format.AbsolutePosition.X)<2,'formats align to HEX trigger')
  firesignal(e.UIElements.Formats[fmt].MouseButton1Click);task.wait(.18);check(e.Format==fmt and not e.UIElements.Formats.Visible,'select format '..fmt)
 end
 e.UIElements.Opacity.Text='0%';firesignal(e.UIElements.Opacity.FocusLost,false);check(c:GetValue().Stops[2].Transparency==1,'0% opacity')
 e.UIElements.Opacity.Text='100%';firesignal(e.UIElements.Opacity.FocusLost,false);check(c:GetValue().Stops[2].Transparency==0,'100% opacity')
 local ui=e.UIElements
 local function position(p,x,y)return Vector3.new(p.AbsolutePosition.X+p.AbsoluteSize.X*x,p.AbsolutePosition.Y+p.AbsoluteSize.Y*y,0)end
 local inp={UserInputType=Enum.UserInputType.MouseButton1,KeyCode=Enum.KeyCode.Unknown,Position=position(ui.SV,.7,.25)}
 firesignal(ui.SV.InputBegan,inp);firesignal(game:GetService('UserInputService').InputEnded,inp)
 local h,s,v=c:GetValue().Stops[2].Color:ToHSV();check(near(s,.7)and near(v,.75),'SV drag maps correctly')
 inp.Position=position(ui.Alpha,.3,.5);firesignal(ui.Alpha.InputBegan,inp);firesignal(game:GetService('UserInputService').InputEnded,inp)
 check(near(c:GetValue().Stops[2].Transparency,.7),'alpha drag maps correctly')
 check(d.Library.CurrentInput==nil,'drag releases shared input')
 check(ui.ColorText.BorderSizePixel==0 and ui.ColorText.TextStrokeTransparency==1,'no color text border/stroke')
 c:Open();d.Player:Select();task.wait(.25);check(not e.Opened,'switching page closes editor');d.Themes:Select();task.wait(.3);c:Open()
 local cm=d.Window.ConfigManager;local name='__fork10_color_qa_'..d.Library.GenerateGUID();local cfg=cm:CreateConfig(name)
 cleanup=function()cfg:Delete();cm.Configs[name]=nil;d.Window.CurrentConfig=previousConfig end
 cfg:Register('gradient',c);cfg:Register('solid',d.SolidColor);local saved=cfg:Save()
 local disk=game:GetService('HttpService'):JSONDecode(readfile(cfg.Path));check(#disk.__elements.gradient.gradient.Stops==2,'gradient actually saved to disk')
 c:Reset(false);d.SolidColor:Update(Color3.new());cfg:Load();task.wait(.1)
 check(near(c:GetValue().Stops[2].Transparency,.7)and #c:GetValue().Stops==2,'gradient actual file round trip')
 check(same(d.SolidColor.Default,Color3.fromRGB(42,148,255))and near(d.SolidColor.Transparency,.15),'solid file round trip')
 cm.Parser.Colorpicker.Load(d.SolidColor,{__type='Colorpicker',value='FF0000',transparency=0});check(same(d.SolidColor.Default,Color3.new(1,0,0))and d.SolidColor.Transparency==0,'legacy solid config compatible')
 e:Open(c.UIElements.Colorpicker);c:Lock();task.wait(.2);check(not e.Opened and not ui.Panel.Visible,'locking closes editor');c:Unlock()
 for _,scale in ipairs({.75,1,1.25})do
  d.Window:SetUIScale(scale);task.wait(.3);c:Open();e:ShowFormats(true);task.wait(.2)
  local origin,z=d.Library.ScreenGui.AbsolutePosition,d.Library.ScreenGui.AbsoluteSize
  for _,p in ipairs({ui.Panel,ui.Formats})do local a,b=p.AbsolutePosition,p.AbsoluteSize;check(a.X>=origin.X and a.Y>=origin.Y and a.X+b.X<=origin.X+z.X+1 and a.Y+b.Y<=origin.Y+z.Y+1,'picker fits viewport at scale '..scale)end
  e:Close()
 end
 d.Window:SetUIScale(1);task.wait(.3);c:Open();task.wait(.2);firesignal(ui.Reset.MouseButton1Click)
 check(c:Export().Stops[1].Color==original.Stops[1].Color and near(c:GetValue().Stops[2].Transparency,.2),'reset default gradient')
 firesignal(game:GetService('UserInputService').InputBegan,{UserInputType=Enum.UserInputType.Keyboard,KeyCode=Enum.KeyCode.Escape,Position=Vector3.zero},false);task.wait(.2);check(not e.Opened and not ui.Panel.Visible,'close fades then hides')
 d.Profile:SetTransparency(1);task.wait(.2);local blur=d.Window.UIElements.Main:FindFirstChild('Blur',true);check(blur and blur.ImageTransparency==1,'main shadow vanishes at transparency 1')
 local at=game:GetService('UserInputService'):GetMouseLocation()+d.Library.ScreenGui.AbsolutePosition
 d.ShowPlayers:OpenHotkeys(at);task.wait(.2);local p=d.Window.FeatureUI.UIElements.Context
 check(math.abs(p.AbsolutePosition.X-at.X-6)<2 and math.abs(p.AbsolutePosition.Y-at.Y-6)<2,'hotkeys open six pixels from cursor')
 check(p:FindFirstChildOfClass('UIStroke')==nil and d.Profile.UIElements.Menu:FindFirstChildOfClass('UIStroke')==nil,'popup white outlines removed')
end)
if cleanup then pcall(cleanup)end
c:Unlock();c:Import(original);d.SolidColor:Reset(false);if c.Editor then c.Editor:Close()end;d.Profile:SetTransparency(0);d.Window:SetUIScale(1);d.Window.FeatureUI:CloseAll();d.Library:SetTheme('Dark')
return {status=ok and 'pass' or 'fail',passed=passed,error=not ok and tostring(err)or nil}
