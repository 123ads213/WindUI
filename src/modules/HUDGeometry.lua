-- Reference-style normalized widget anchors, bounds and watermark snap rulers.
local G={}
local function clamp(n,a,b)return math.clamp(n,a,math.max(a,b))end
function G.Clamp(x,y,w,h,vw,vh)return clamp(x,0,vw-w),clamp(y,0,vh-h)end
function G.Position(state,w,h,vw,vh)
 return G.Clamp((state.X or 0)*vw-(state.Anchor or 0)*w,(state.Y or 0)*vh,w,h,vw,vh)
end
function G.Store(x,y,w,h,vw,vh,anchor)
 x,y=G.Clamp(x,y,w,h,vw,vh);anchor=anchor or 0
 return {X=clamp((x+anchor*w)/math.max(vw,1),0,1),Y=clamp(y/math.max(vh,1),0,1),Anchor=anchor}
end
function G.Release(x,y,w,h,vw,vh,align)
 local anchor=align and math.clamp(math.floor((x+w*.5)/math.max(vw/3,1)),0,2)/2 or 0
 return G.Store(x,y,w,h,vw,vh,anchor)
end
function G.Snap(x,y,w,h,vw,vh,bypass)
 local hits={Center=false,Top=false,Bottom=false}
 if not bypass then
  if math.abs(x+w/2-vw/2)<10 then x=vw/2-w/2;hits.Center=true end
  if math.abs(y+h/2-32)<10 then y=32-h/2;hits.Top=true
  elseif math.abs(y+h/2-(vh-32))<10 then y=vh-32-h/2;hits.Bottom=true end
 end
 x,y=G.Clamp(x,y,w,h,vw,vh);return x,y,hits
end
function G.Valid(s)
 local function finite(n)return type(n)=='number'and n==n and math.abs(n)<math.huge end
 return type(s)=='table'and finite(s.X)and finite(s.Y)and s.X>=0 and s.X<=1 and s.Y>=0 and s.Y<=1 and(s.Anchor==0 or s.Anchor==.5 or s.Anchor==1)
end
return G
