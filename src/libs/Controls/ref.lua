---@class Ref<T>
---@field use fun(self: Ref<T>, id: string, hook: fun(old: T, new: T))
---@field set fun(self: Ref<T>, v: T)

---@generic T
---@param init T
---@return Ref<T>
function Ref(init)
    local value = init
    local hooks = {}
    local self = {}

    function self:use(id, hook)
        hook(nil, value)
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

    return self
end
