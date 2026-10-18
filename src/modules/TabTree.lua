-- Pure selection routing for nested tabs. Does not alter UI or stored tab state.
local Tree = {}
local function leaf(node)
    if not node or node.Locked then return nil end
    local children = node.SubTabs or {}
    if #children == 0 then return node end
    if node.LastSubTab and table.find(children, node.LastSubTab) then
        local remembered = leaf(node.LastSubTab)
        if remembered then return remembered end
    end
    for _, child in ipairs(children) do
        if child ~= node.LastSubTab then
            local result = leaf(child)
            if result then return result end
        end
    end
    return nil
end
function Tree.Resolve(node)
    local parent = node and node.ParentTab
    while parent do
        if parent.Locked then return nil end
        parent = parent.ParentTab
    end
    return leaf(node)
end
return Tree
