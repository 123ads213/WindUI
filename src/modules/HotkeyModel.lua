-- Boolean feature bindings, independent from Roblox UI/input and JSON transport.
local Model={}
function Model.New()
 local self={Entries={},NextId=0}
 function self:Register(owner,apply,read,available)
  local e={Owner=owner,Apply=apply,Read=read,Available=available,Bindings={}};self.Entries[#self.Entries+1]=e;return e
 end
 local function allowed(e)return not e.Available or e.Available()end
 local function set(e,v)if allowed(e) and (not e.Read or e.Read()~=v)then e.Apply(v)end end
 function self:Enforce(e)
  if not allowed(e)then return end
  for i=#e.Bindings,1,-1 do local b=e.Bindings[i];if b.Mode=='Always'then set(e,b.Value);return end end
 end
 function self:Add(e,data)
  data=data or {};self.NextId+=1
  local b={Id=self.NextId,Key=type(data.Key)=='string'and data.Key or 'Unbound',Mode=data.Mode=='Hold'and'Hold'or data.Mode=='Always'and'Always'or'Toggle',Value=data.Value~=false,Active=false}
  e.Bindings[#e.Bindings+1]=b;self:Enforce(e);return b
 end
 function self:Release(e,b)
  if b.Mode=='Hold'and b.Active then b.Active=false;set(e,not b.Value)end
 end
 function self:Remove(e,b)
  self:Release(e,b);local i=table.find(e.Bindings,b);if i then table.remove(e.Bindings,i)end;self:Enforce(e)
 end
 function self:Reset(e)
  for _,b in ipairs(e.Bindings)do self:Release(e,b)end;table.clear(e.Bindings)
 end
 function self:Update(e,b,data)
  self:Release(e,b);b.Active=false;b.Down=false
  if data.Key then b.Key=data.Key end
  if data.Mode then b.Mode=data.Mode=='Hold'and'Hold'or data.Mode=='Always'and'Always'or'Toggle'end
  if type(data.Value)=='boolean'then b.Value=data.Value end;self:Enforce(e)
 end
 function self:Input(key,down,blocked)
  for _,e in ipairs(self.Entries)do
   for _,b in ipairs(e.Bindings)do
    if b.Key==key and b.Mode~='Always'then
     if down and not blocked and allowed(e) and not b.Down then
      b.Down=true
      if b.Mode=='Toggle'then b.Active=not b.Active;set(e,b.Active==b.Value)
      else b.Active=true;set(e,b.Value)end
     elseif not down then b.Down=false;self:Release(e,b)end
    end
   end;self:Enforce(e)
  end
 end
 function self:Blur()
  for _,e in ipairs(self.Entries)do for _,b in ipairs(e.Bindings)do b.Down=false;self:Release(e,b)end;self:Enforce(e)end
 end
 function self:Export(e)
  local rows={};for _,b in ipairs(e.Bindings)do rows[#rows+1]={Key=b.Key,Mode=b.Mode,Value=b.Value}end;return rows
 end
 function self:Import(e,rows)
  self:Reset(e)
  if type(rows)=='table'then for _,row in ipairs(rows)do if type(row)=='table'then self:Add(e,row)end end end
 end
 function self:Unregister(e)
  self:Reset(e);local i=table.find(self.Entries,e);if i then table.remove(self.Entries,i)end
 end
 return self
end
return Model
