--* use ../root.lua

E.Utils = {}

---@generic T
---@param orig T
---@param seen any
---@return T
function E.Utils.clone(orig, seen)
    seen = seen or {}
    if type(orig) ~= 'table' then return orig end
    if seen[orig] then return seen[orig] end

    local copy = {}
    seen[orig] = copy

    setmetatable(copy, E.Utils.clone(getmetatable(orig), seen))

    for k, v in next, orig, nil do
        copy[E.Utils.clone(k, seen)] = E.Utils.clone(v, seen)
    end

    return copy
end
