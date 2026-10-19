local M=require('../src/modules/HotkeyModel')
local count=0
local function check(v,label)assert(v,label);count+=1 end
local m=M.New();local value=false;local locked=false
local e=m:Register({},function(v)value=v end,function()return value end,function()return not locked end)
local a=m:Add(e,{Key='K',Mode='Toggle',Value=true})
m:Input('K',true);check(value,'Toggle Enabled first press');m:Input('K',true);check(value,'repeat suppressed');m:Input('K',false);m:Input('K',true);check(not value,'Toggle Enabled second press');m:Input('K',false)
m:Update(e,a,{Value=false});m:Input('K',true);check(not value,'Toggle Disabled first press');m:Input('K',false);m:Input('K',true);check(value,'Toggle Disabled second press');m:Input('K',false)
m:Update(e,a,{Mode='Hold',Value=false});m:Input('K',true);check(not value,'Hold disabled down');m:Input('K',false);check(value,'Hold disabled release')
m:Update(e,a,{Value=true});m:Input('K',true);check(value,'Hold enabled down');m:Blur();check(not value,'focus loss releases')
m:Input('K',true,true);check(not value,'processed input ignored');locked=true;m:Input('K',true);check(not value,'locked feature ignored');locked=false
m:Input('K',true);m:Remove(e,a);check(not value and #e.Bindings==0,'removal releases active hold')
local always=m:Add(e,{Mode='Always',Value=true});check(value,'Always immediate');value=false;m:Enforce(e);check(value,'Always enforced');local second=m:Add(e,{Key='L',Value=false,Mode='Always'});check(not value,'last Always wins');m:Remove(e,second);check(value,'earlier Always restored')
local saved=m:Export(e);check(saved[1].Mode=='Always' and saved[1].Value==true and saved[1].Active==nil,'only persistent fields exported');saved[1].Key='X';check(e.Bindings[1].Key~='X','export independent copy')
m:Import(e,{{Key='M',Mode='Hold',Value=false},{Key='N',Mode='Toggle',Value=true}});check(#e.Bindings==2 and e.Bindings[1].Key=='M','multiple import');local out=m:Export(e);check(out[1].Value==false and out[2].Mode=='Toggle','false survives round trip')
m:Reset(e);check(#e.Bindings==0,'reset all');m:Unregister(e);check(#m.Entries==0,'unregister')
print('PASS HotkeyModel:',count,'state and persistence assertions')
