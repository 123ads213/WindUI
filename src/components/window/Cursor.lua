-- Optional filled white cursor; independent of menu DPI and theme.
local Cursor={}
function Cursor.New(Window,WindUI,Creator)
    local Input=game:GetService('UserInputService')
    local Run=game:GetService('RunService')
    local self={Enabled=false,Size=10,Destroyed=false,UIElements={}}
    local signals={}
    local focused=true
    local owned=false
    local previousIcon
    local gui,dot
    local function connect(signal,fn)local c=signal:Connect(fn);signals[#signals+1]=c;return c end
    local function release()
        if dot then dot.Visible=false end
        if owned then Input.MouseIconEnabled=previousIcon;owned=false end
    end
    local function update()
        local active=not self.Destroyed and self.Enabled and focused and Input.MouseEnabled and not Window.Destroyed and
            not Window.Closed and WindUI.ScreenGui.Enabled and Window.UIElements.Main.Visible and Window.UIElements.Main.Main.Visible
        if not active then release();return end
        if not gui then
            gui=Creator.New('ScreenGui',{Name='WindUI/Cursor',Parent=WindUI.ScreenGui.Parent,IgnoreGuiInset=true,ScreenInsets='None',DisplayOrder=1000000})
            dot=Creator.New('Frame',{Parent=gui,Name='Dot',Size=UDim2.fromOffset(self.Size,self.Size),AnchorPoint=Vector2.new(.5,.5),
                BorderSizePixel=0,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0,Active=false,ZIndex=10})
            Creator.New('UICorner',{Parent=dot,CornerRadius=UDim.new(1,0)})
            self.UIElements={Gui=gui,Dot=dot}
        end
        if not owned then previousIcon=Input.MouseIconEnabled;owned=true end
        Input.MouseIconEnabled=false
        local point=Input:GetMouseLocation()
        dot.Position=UDim2.fromOffset(point.X,point.Y);dot.Size=UDim2.fromOffset(self.Size,self.Size);dot.Visible=true
    end
    function self:Set(config)
        if self.Destroyed then return end
        if type(config)=='table'then
            self.Enabled=config.Enabled~=false
            local size=tonumber(config.Size)
            if size and size==size then self.Size=math.clamp(size,4,24)end
        else self.Enabled=config==true end
        update()
    end
    function self:Destroy()
        if self.Destroyed then return end
        self.Destroyed=true;release()
        for _,c in ipairs(signals)do c:Disconnect()end
        if gui then gui:Destroy()end
    end
    connect(Run.RenderStepped,update)
    connect(Input.WindowFocusReleased,function()focused=false;release()end)
    connect(Input.WindowFocused,function()focused=true;update()end)
    connect(Window.UIElements.Main.Main:GetPropertyChangedSignal('Visible'),update)
    connect(WindUI.ScreenGui:GetPropertyChangedSignal('Enabled'),update)
    connect(Window.UIElements.Main.Destroying,function()self:Destroy()end)
    return self
end
return Cursor
