-- Pure presentation/settings model. No executor calls or game-side actions.
local M={}
M.Fields={
 {Id='FPS',Label='FPS',Icon='chart-no-axes-column-increasing',Reserve='888 FPS',Default=true},
 {Id='Ping',Label='Ping',Icon='signal',Reserve='888 MS',Default=true},
 {Id='Username',Label='Username',Icon='user-round',Default=true},
 {Id='Time',Label='Time',Reserve='00:00',Default=true},
 {Id='Day',Label='Weekday',Reserve='Wed',Default=true},
 {Id='Avatar',Label='Avatar',Default=true},
 {Id='Platform',Label='Logo',Reserve='RB',Default=true},
 {Id='Build',Label='Build',Default=true},
 {Id='Executor',Label='Executor',Icon='terminal'},
 {Id='VAR',Label='Frame variance',Icon='activity',Reserve='99.9 VAR'},
 {Id='Memory',Label='Memory',Icon='memory-stick',Reserve='9999 MB'},
 {Id='Uptime',Label='Session time',Icon='timer',Reserve='00:00:00'},
 {Id='Place',Label='Place ID',Icon='map-pin'},
}
M.ById={};M.ByLabel={}
for _,f in ipairs(M.Fields)do M.ById[f.Id]=f;M.ByLabel[f.Label]=f end
function M.Defaults()local out={};for _,f in ipairs(M.Fields)do out[f.Id]=f.Default==true end;return out end
function M.Validate(fields)
 if type(fields)~='table'then return false end
 for k,v in pairs(fields)do if not M.ById[k]or type(v)~='boolean'then return false end end
 return true
end
function M.Selected(fields)local out={};for _,f in ipairs(M.Fields)do if fields[f.Id]then out[#out+1]=f.Label end end;return out end
function M.FromSelection(list)
 if type(list)~='table'then return nil end
 local out={};for _,f in ipairs(M.Fields)do out[f.Id]=false end
 for _,label in ipairs(list)do local f=M.ByLabel[label];if not f then return nil end;out[f.Id]=true end
 return out
end
function M.Ease(current,target,dt,speed)
 local n=current+(target-current)*(1-math.exp(-(speed or 14)*math.clamp(dt,0,.1)))
 return math.abs(n-target)<.0002 and target or n
end
function M.Build(username,builds,fallback)
 local normalized=string.lower(username or'')
 for name,label in pairs(builds or{})do if type(name)=='string'and type(label)=='string'and string.lower(name)==normalized then return label end end
 return fallback or'Release'
end
function M.Clock(t)
 return string.format('%02d:%02d',t.hour,t.min),({'Sun','Mon','Tue','Wed','Thu','Fri','Sat'})[t.wday]or'—'
end
return M
