local M=require('../src/modules/HUDModel')
local count=0
local function check(v,msg)assert(v,msg);count+=1 end
local fields=M.Defaults();check(fields.FPS and fields.Ping and fields.Time and fields.Day and fields.Build,'useful defaults');check(not fields.Memory and not fields.VAR and not fields.Executor,'optional telemetry');check(fields.Loss==nil and fields.Timeout==nil,'no placeholder network fields')
check(#M.Selected(fields)==8,'eight default fields')
local selected=M.FromSelection({'FPS','Build','Executor'});check(selected.FPS and selected.Build and selected.Executor and not selected.Time,'multi selection')
check(M.Validate(selected),'valid map');check(not M.Validate({Fake=true}),'unknown field');check(not M.Validate({FPS=1}),'boolean only');check(not M.FromSelection({'Unknown'}),'invalid selection');check(#M.Selected(M.FromSelection({}))==0,'empty selection')
local build={syntheticplatinum27='Nightly'};check(M.Build('syntheticplatinum27',build)=='Nightly','exact username');check(M.Build('SYNTHETICPLATINUM27',build)=='Nightly','case insensitive');check(M.Build('syntheticplatinum270',build)=='Release','not substring');check(M.Build('Other',build)=='Release','fallback');check(M.Build('Other',build,'Stable')=='Stable','custom fallback')
local time,day=M.Clock({hour=9,min=5,wday=2});check(time=='09:05'and day=='Monday','local clock formatting');time,day=M.Clock({hour=23,min=59,wday=1});check(time=='23:59'and day=='Sunday','Sunday')
for i,name in ipairs({'Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'})do local _,actual=M.Clock({hour=12,min=0,wday=i});check(actual==name,'full weekday '..name)end
check(M.ById.FPS.Icon=='monitor'and M.ById.FPS.Icon~=M.ById.Ping.Icon,'FPS monitor differs from ping');check(M.ById.Platform.Reserve=='Sirius','Sirius brand width')
local x=0;for i=1,60 do local old=x;x=M.Ease(x,1,1/60,13);check(x>=old and x<=1,'monotonic reveal')end;check(x==1,'snaps residual');for i=1,60 do x=M.Ease(x,0,1/60,13)end;check(x==0,'hide finishes')
local a,b=0,0;for i=1,60 do a=M.Ease(a,1,1/60,5)end;for i=1,120 do b=M.Ease(b,1,1/120,5)end;check(math.abs(a-b)<.0001,'frame rate independent')
print('HUDModel: '..count..' assertions passed')
