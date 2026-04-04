--* use ../main.lua
--* use ../ref.lua
--* use ../basic/texture.lua

---@class Button : Control
---@field state Ref<boolean>

---@param id string
---@param parent Element
---@param args {
---    anchors: Ref<AnchorSetting[]>?,
---    hidden: Ref<boolean>?,
---    height: Ref<integer?>?,
---    width: Ref<integer?>?,
---    mouseEnabled: Ref<boolean>?,
---    state: Ref<boolean>?,
---}
---@return Button
function Controls.button(id, parent, args)
    local e = WINDOW_MANAGER:CreateControl(id, parent.element, CT_CONTROL)
    local result = Controls.setupControl(id, e, args) --[[@as Button]]

    if args.state == nil then
        args.state = Ref(false)
    end
    result.state = args.state

    local icon = Controls.texture(id .. "-icon", { element = e }, {
        hidden = args.hidden,
        height = Ref(64),
        width = Ref(64),
        mouseEnabled = Ref(true),
        anchors = Ref({
            { point = LEFT, target = e, relativePoint = LEFT, offsetX = 0, offsetY = 0 },
        })
    })

    args.state:use(id .. "-state", function(_, v)
        if v then
            icon.texture:set(Textures.plus.pointplus)
        else
            icon.texture:set(Textures.plus.zoomplus)
        end
    end)
    icon.handlers.onMouseDown:set(function(self, button, ctrl, alt, shift, command)
        args.state:set(not args.state:get())
    end)
    icon.handlers.onMouseUp:set(function(self, button, upInside, ctrl, alt, shift, command)
        args.state:set(not args.state:get())
    end)

    return result
end
