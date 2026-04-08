---@class Ref<T>
---@field isRef boolean
---@field use fun(self: Ref<T>, id: string, hook: fun(old: T, new: T), lazy: boolean?)
---@field set fun(self: Ref<T>, v: T)
---@field get fun(self: Ref<T>): T
---@field free fun(self: Ref<T>, id: string)

--- Constructs reactive reference to some value.
---@generic T
---@param init T Initial value
---@return Ref<T>
function Ref(init)
    local value = init
    local hooks = {}
    local self = {
        isRef = true
    }

    function self:use(id, hook, lazy)
        if lazy == nil or not lazy then
            hook(nil, value)
        end
        hooks[id] = hook
    end

    function self:free(id)
        hooks[id] = nil
    end

    function self:set(v)
        for _, hook in pairs(hooks) do
            hook(value, v)
        end
        value = v
    end

    function self:get()
        return value
    end

    return self
end

--- Constructs reactive computed value based on some computation `initF` with a list of `Ref`s in `closure`.
--- Each time when value of some ref in closure list changed, computed value also recalculated.
---@generic T
---@param closure Ref<any>[] List of references which changes are trigger recalculation of this ref
---@param initF fun(...): T Initial computation function
---@return Ref<T>
function RefC(refId, closure, initF)
    local f = initF
    local current = nil
    local hooks = {}
    local self = {
        isRef = true
    }

    local function collect()
        local args = {}
        for i, ref in ipairs(closure) do
            args[i] = ref:get()
        end
        return args
    end

    function self:use(id, hook, lazy)
        if lazy == nil or not lazy then
            hook(nil, current)
        end
        hooks[id] = hook
    end

    function self:free(id)
        hooks[id] = nil
    end

    function self:set(_)
    end

    function self:get()
        return current
    end

    for i, ref in ipairs(closure) do
        ref:use("$" .. i .. "-" .. refId, function(_, new)
            local args = collect()
            args[i] = new
            local value = f(unpack(args))
            for _, hook in pairs(hooks) do
                hook(current, value)
            end
            current = value
        end, true)
    end

    local args = collect()
    current = f(unpack(args))

    return self
end
