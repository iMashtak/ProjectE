---@class Ref<T>
---@field use fun(self: Ref<T>, id: string, hook: fun(old: T, new: T), lazy: boolean?)
---@field set fun(self: Ref<T>, v: T)
---@field get fun(self: Ref<T>): T
---@field free fun(self: Ref<T>, id: string)

---@generic T
---@param init T
---@return Ref<T>
function Ref(init)
    local value = init
    local hooks = {}
    local self = {}

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
