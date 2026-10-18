local Tree = require('../src/modules/TabTree')
local cases = 0
local function check(v) assert(v); cases += 1 end
local function node(parent, locked)
    local n={ParentTab=parent, SubTabs={}, Locked=locked}
    if parent then table.insert(parent.SubTabs,n) end
    return n
end
local visuals=node(nil)
local player=node(visuals)
local world=node(visuals)
check(Tree.Resolve(visuals)==player)
visuals.LastSubTab=world
check(Tree.Resolve(visuals)==world)
check(Tree.Resolve(player)==player)
world.Locked=true
check(Tree.Resolve(visuals)==player)
player.Locked=true
check(Tree.Resolve(visuals)==nil)
world.Locked=false
visuals.Locked=true
check(Tree.Resolve(world)==nil)
visuals.Locked=false
local lighting=node(world)
local atmosphere=node(world)
check(Tree.Resolve(visuals)==lighting)
world.LastSubTab=atmosphere
check(Tree.Resolve(visuals)==atmosphere)
lighting.Locked=true;atmosphere.Locked=true;player.Locked=false
check(Tree.Resolve(visuals)==player)
visuals.LastSubTab={} -- A stale remembered child must not hijack routing.
check(Tree.Resolve(visuals)==player)
check(Tree.Resolve(nil)==nil)
local flat=node(nil)
check(Tree.Resolve(flat)==flat)
print('PASS TabTree: '..cases..' selection-routing cases')
