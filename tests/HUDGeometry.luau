local G=require('../src/modules/HUDGeometry')
local count=0
local function eq(a,b)count+=1;assert(math.abs(a-b)<.000001,tostring(a)..' ~= '..tostring(b))end
local x,y=G.Clamp(-5,900,200,34,1000,600);eq(x,0);eq(y,566)
x,y=G.Clamp(100,100,1200,900,1000,600);eq(x,0);eq(y,0)
for _,anchor in ipairs({0,.5,1})do
 local s=G.Store(320,50,240,34,1000,600,anchor)
 x,y=G.Position(s,240,34,1000,600);eq(x,320);eq(y,50)
end
for _,pair in ipairs({{0,0},{400,.5},{750,1}})do local s=G.Release(pair[1],20,200,34,1000,600,true);eq(s.Anchor,pair[2]);x,y=G.Position(s,200,34,1000,600);eq(x,pair[1]);eq(y,20)end
local s=G.Release(750,20,200,34,1000,600,false);eq(s.Anchor,0)
s={X=.985,Y=.025,Anchor=1};x,y=G.Position(s,200,34,1000,600);eq(x,785);eq(y,15)
x,y=G.Position(s,300,34,1000,600);eq(x,685)
x,y=G.Position(s,300,34,2000,1200);eq(x,1670);eq(y,30)
local hits;x,y,hits=G.Snap(396,18,200,34,1000,600,false);eq(x,400);eq(y,15);assert(hits.Center and hits.Top)
x,y,hits=G.Snap(396,18,200,34,1000,600,true);eq(x,396);eq(y,18);assert(not hits.Center and not hits.Top)
x,y,hits=G.Snap(410,542,200,34,1000,600,false);eq(x,410);eq(y,551);assert(not hits.Center and hits.Bottom)
assert(G.Valid({X=0,Y=1,Anchor=.5}));assert(not G.Valid({X=0/0,Y=1,Anchor=0}));assert(not G.Valid({X=math.huge,Y=0,Anchor=0}));assert(not G.Valid({X=.5,Y=0,Anchor=.25}));assert(not G.Valid({X=-.1,Y=0,Anchor=0}))
print('HUDGeometry: '..count..' assertions passed')
