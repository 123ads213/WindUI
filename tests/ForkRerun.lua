-- Studio/executor QA: provide the two source globals documented in FORK.md.
task.spawn(function()
 local e=getgenv();local passed=0
 local function check(v,label) assert(v,label);passed+=1 end
 local build=assert(e.__WindUIForkBuild,'Set __WindUIForkBuild to the current dist/main.lua source')
 local example=assert(e.__WindUIForkExampleSource,'Set __WindUIForkExampleSource to the current ForkExample source')
 local function run(source)
  e.__WindUIForkInjectedLibrary=assert(loadstring(build))()
  return assert(loadstring(source or example))()
 end
 local function roots()
  local d=assert(e.WindUIForkDemo);local n=0
  for _,r in ipairs(d.Library.ScreenGui.Parent:GetChildren())do if r.Name=='WindUI' then n+=1 end end
  return n
 end
 local ok,err=pcall(function()
  for i=1,3 do run();task.wait(.8);check(roots()==1,'one window after rerun '..i) end
  local broken=example:gsub('local Visuals = Window:Tab',"error('intentional QA setup failure')\nlocal Visuals = Window:Tab",1)
  local success=pcall(function()run(broken)end)
  check(not success,'controlled setup failure')
  check(e.WindUIForkDemo and e.WindUIForkDemo.Window~=nil,'failed setup is registered for cleanup')
  run();task.wait(.8);check(roots()==1,'failed setup cleaned on next run')
  task.spawn(function()run()end);task.wait(.05);task.spawn(function()run()end);task.wait(2)
  check(roots()==1,'concurrent reruns settle to one window')
  local cursors=0;for _,r in ipairs(e.WindUIForkDemo.Library.ScreenGui.Parent:GetChildren())do if r.Name=='WindUI/Cursor'then cursors+=1 end end
  check(cursors==1,'cursor roots cleaned across reruns')
 end)
 e.__WindUIForkReruns={status=ok and 'pass' or 'fail',passed=passed,error=not ok and tostring(err) or nil}
end)
