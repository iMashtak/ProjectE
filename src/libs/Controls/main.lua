Controls = {
    Dsl = {}
}

---@class Element
---@field element any

---@type {[string]: Element}
ControlsRegistry = {}

---@alias AnchorSetting {point: any, target: any, relativePoint: any, offsetX: integer, offsetY: integer}
---@alias ColorSetting {r: number, g: number, b: number, a: number}

---@alias OnMouseDownFun fun(self, button, ctrl, alt, shift, command)
---@alias OnMouseUpFun fun(self, button, upInside, ctrl, alt, shift, command)

---@alias Events<T> {[string]: {f: Ref<T>, order: any?, target: string?}}

---@generic T : function
---@class Handlers<T>
---@field get fun(self: Handlers<T>, name: string?): Ref<T>
---@field add fun(self: Handlers<T>, name: string, g: Ref<T>, order: any?, target: string?)

---@generic T : function
---@param events Events<T>
---@param hook fun(f: T, name: string?, order: any?, target: string?)
---@return Handlers<T>
function UseEvents(events, hook)
    local self = {
        isHandlers = true
    }

    function self:get(name)
        if name == nil then
            name = "_"
        end
        if events[name] == nil then
            return nil
        end
        return events[name].f
    end

    local function use(name, g, order, target)
        if name == "_" then
            g:use("EVENT", function(_, v)
                hook(v, nil, nil, nil)
            end)
        else
            g:use("EVENT-" .. name, function(_, v)
                hook(v, name, order, target)
            end)
        end
    end

    ---@param name string
    ---@param g Ref<function>
    ---@param order any?
    ---@param target string?
    function self:add(name, g, order, target)
        if events[name] ~= nil then
            assert(false, "handler with name '" .. name .. "' has already registered")
        end
        use(name, g, order, target)
        events[name] = { f = g, order = order, target = target }
    end

    for name, event in pairs(events) do
        use(name, event.f, event.order, event.target)
    end

    return self
end

---@generic T : function
---@param f Ref<T>
---@param hook fun(f: T, name: string?, order: any?, target: string?)
---@return Handlers<T>
function UseEvent(f, hook)
    local events = {}
    events["_"] = { f = f }
    return UseEvents(events, hook)
end

---@generic T: function
---@param event Ref<T>|Events<T>|nil
---@param hook fun(f: T, name: string?, order: any?, target: string?)
---@return Handlers<T>
function MakeHandlers(event, hook)
    if event == nil then
        local ref = Ref(nil)
        return UseEvent(ref, hook)
    else
        if event.isRef == true then
            return UseEvent(event, hook)
        else
            return UseEvents(event, hook)
        end
    end
end

Fonts = {
    game = "ZoFontGame",
}

Textures = {
    icons = {
        missing = "/esoui/art/icons/icon_missing.dds",
        checkbox = {
            checked = "/esoui/art/cadwell/checkboxicon_checked.dds",
            unchecked = "/esoui/art/cadwell/checkboxicon_unchecked.dds",
        }
    },
    bg = {
        chatCenter = "/esoui/art/chatwindow/chat_bg_center.dds",
        chatEdge = "/esoui/art/chatwindow/chat_bg_edge.dds"
    },
    effects = {
        crux = "/art/fx/texture/arcanist_trianglerune_01.dds"
    },
    plus = {
        pointplus = "/esoui/art/tutorial/pointsplus_up.dds",
        zoomplus = "/esoui/art/tutorial/minimap_zoomplus_up.dds"
    },
    minus = {
        pointminus = "/esoui/art/tutorial/pointsminus_up.dds",
        zoomminus = "/esoui/art/tutorial/minimap_zoomminus_up.dds"
    }
}

---@type {[string]: ColorSetting}
Colors = {
    ["black"] = { r = 0, g = 0, b = 0, a = 1 },
    ["crux"] = { r = 0.6445, g = 1, b = 0.4219, a = 1 },
}
