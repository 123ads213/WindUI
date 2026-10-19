-- Canonical color/gradient data, validation and editable text formats.
local C={MaxStops=16}
local function finite(n)return type(n)=='number'and n==n and math.abs(n)<math.huge end
local function clamp(n,lo,hi)return math.clamp(n,lo,hi)end
local function alpha(n,default)if not finite(n)then return default or 0 end;return clamp(n,0,1)end
function C.Clone(state)
 local out={Rotation=state.Rotation,Stops={}}
 for _,s in ipairs(state.Stops)do out.Stops[#out.Stops+1]={Position=s.Position,Color=s.Color,Transparency=s.Transparency}end
 return out
end
function C.Normalize(value,defaultColor,transparency)
 if typeof(value)=='Color3' or value==nil then return {Rotation=0,Stops={{Position=0,Color=value or defaultColor or Color3.new(1,1,1),Transparency=alpha(transparency)}}}end
 if type(value)~='table'then return nil,'Expected a color or gradient table'end
 local list=value.Stops or value;local stops={}
 if #list<1 or #list>C.MaxStops then return nil,'Use 1–16 gradient stops'end
 for i,s in ipairs(list)do
  if typeof(s)=='Color3' then s={Color=s}end
  if type(s)~='table'or typeof(s.Color)~='Color3'then return nil,'Every stop needs a Color3'end
  local p=s.Position;if p==nil then p=#list==1 and 0 or(i-1)/(#list-1)end
  if not finite(p)or p<0 or p>1 then return nil,'Stop positions must be within 0–1'end
  if s.Transparency~=nil and not finite(s.Transparency)then return nil,'Invalid transparency'end
  stops[#stops+1]={Position=p,Color=s.Color,Transparency=alpha(s.Transparency)}
 end
 table.sort(stops,function(a,b)return a.Position<b.Position end)
 for i=2,#stops do if stops[i].Position-stops[i-1].Position<.0001 then return nil,'Stop positions must be distinct'end end
 if #stops>1 and(stops[1].Position~=0 or stops[#stops].Position~=1)then return nil,'A gradient needs endpoints at 0 and 1'end
 local rotation=value.Rotation or 0;if not finite(rotation)then return nil,'Invalid gradient angle'end
 return {Rotation=rotation%360,Stops=stops}
end
function C.Sequences(state)
 local colors,alphas={},{}
 for _,s in ipairs(state.Stops)do colors[#colors+1]=ColorSequenceKeypoint.new(s.Position,s.Color);alphas[#alphas+1]=NumberSequenceKeypoint.new(s.Position,s.Transparency)end
 if #colors==1 then colors[1]=ColorSequenceKeypoint.new(0,state.Stops[1].Color);colors[2]=ColorSequenceKeypoint.new(1,state.Stops[1].Color);alphas[1]=NumberSequenceKeypoint.new(0,state.Stops[1].Transparency);alphas[2]=NumberSequenceKeypoint.new(1,state.Stops[1].Transparency)end
 return ColorSequence.new(colors),NumberSequence.new(alphas)
end
function C.Encode(state)
 local out={Rotation=state.Rotation,Stops={}}
 for _,s in ipairs(state.Stops)do out.Stops[#out.Stops+1]={Position=s.Position,Color=s.Color:ToHex(),Transparency=s.Transparency}end;return out
end
function C.Decode(data)
 if type(data)~='table'or type(data.Stops)~='table'then return nil,'Invalid saved gradient'end
 local out={Rotation=data.Rotation,Stops={}}
 for _,s in ipairs(data.Stops)do
  if type(s)~='table'or type(s.Color)~='string'or not s.Color:match('^%x%x%x%x%x%x$')then return nil,'Invalid saved color'end
  out.Stops[#out.Stops+1]={Position=s.Position,Color=Color3.fromHex(s.Color),Transparency=s.Transparency}
 end
 return C.Normalize(out)
end
function C.Add(state)
 if #state.Stops>=C.MaxStops then return nil,'Maximum 16 colors'end
 if #state.Stops==1 then local s=state.Stops[1];state.Stops[2]={Position=1,Color=s.Color,Transparency=s.Transparency};return 2 end
 local gap,index=-1,1
 for i=1,#state.Stops-1 do local d=state.Stops[i+1].Position-state.Stops[i].Position;if d>gap then gap=d;index=i end end
 local a,b=state.Stops[index],state.Stops[index+1];table.insert(state.Stops,index+1,{Position=(a.Position+b.Position)/2,Color=a.Color:Lerp(b.Color,.5),Transparency=(a.Transparency+b.Transparency)/2});return index+1
end
function C.Remove(state,index)
 if #state.Stops<=1 then return false end
 table.remove(state.Stops,index)
 if #state.Stops==1 then state.Stops[1].Position=0 else state.Stops[1].Position=0;state.Stops[#state.Stops].Position=1 end;return true
end
local function rgb(c)return math.round(c.R*255),math.round(c.G*255),math.round(c.B*255)end
local function hsl(c)
 local hi,lo=math.max(c.R,c.G,c.B),math.min(c.R,c.G,c.B);local l=(hi+lo)/2;local d=hi-lo
 local h=select(1,c:ToHSV());return h,d==0 and 0 or d/(1-math.abs(2*l-1)),l
end
local function fromHSL(h,s,l)
 local v=l+s*math.min(l,1-l);return Color3.fromHSV(h,v==0 and 0 or 2*(1-l/v),v)
end
function C.Format(color,t,format)
 local opacity=1-alpha(t);local r,g,b=rgb(color)
 if format=='RGB'then return string.format('rgba(%d, %d, %d, %.3g)',r,g,b,opacity)end
 local h,s,v
 if format=='HSL'then h,s,v=hsl(color)else h,s,v=color:ToHSV()end
 if format=='HSV'or format=='HSL'then return string.format('%s(%.1f, %.1f%%, %.1f%%, %.3g)',format:lower(),h*360,s*100,v*100,opacity)end
 return '#'..color:ToHex():upper()..string.format('%02X',math.round(opacity*255))
end
function C.Parse(text,format)
 if type(text)~='string'then return nil,nil,'Enter a color'end
 text=text:match('^%s*(.-)%s*$');local hex=text:match('^#(%x+)$')or((format=='HEX'and text:match('^%x+$'))and text)
 if hex then
  if #hex==3 or #hex==4 then local h='';for i=1,#hex do local a=hex:sub(i,i);h..=a..a end;hex=h end
  if #hex~=6 and #hex~=8 then return nil,nil,'Use #RGB, #RGBA, #RRGGBB or #RRGGBBAA'end
  return Color3.fromHex(hex:sub(1,6)),#hex==8 and(1-tonumber(hex:sub(7,8),16)/255)or nil
 end
 local prefix,body=text:lower():match('^(%a+)%s*%((.-)%)$');body=body or text
 local mode=prefix and(prefix=='rgba'and'RGB'or prefix:upper())or format
 if mode~='RGB'and mode~='HSV'and mode~='HSL'then return nil,nil,'Choose Hex, RGB, HSV or HSL'end
 local values={};for part in body:gmatch('[^,%s]+')do local percent=part:sub(-1)=='%';local n=tonumber(percent and part:sub(1,-2)or part);if not finite(n)then return nil,nil,'Invalid color number'end;values[#values+1]={n=n,p=percent}end
 if #values~=3 and #values~=4 then return nil,nil,'Expected 3 channels and optional alpha'end
 local a=values[4];local opacity=a and(a.p and a.n/100 or a.n)or nil
 if opacity and(opacity<0 or opacity>1)then return nil,nil,'Alpha must be within 0–1 or 0–100%'end
 local x,y,z=values[1],values[2],values[3];local color
 if mode=='RGB'then
  local function channel(v)local n=v.p and v.n/100 or v.n/255;if n<0 or n>1 then return nil end;return n end
  local r,g,b=channel(x),channel(y),channel(z);if not r or not g or not b then return nil,nil,'RGB channels must be 0–255 or percentages'end;color=Color3.new(r,g,b)
 else
  local s,v=y.n/100,z.n/100;if x.p or x.n<0 or x.n>360 or s<0 or s>1 or v<0 or v>1 then return nil,nil,'Hue: 0–360; other channels: 0–100%'end
  color=mode=='HSV'and Color3.fromHSV((x.n%360)/360,s,v)or fromHSL((x.n%360)/360,s,v)
 end
 return color,opacity and(1-opacity)or nil
end
return C
