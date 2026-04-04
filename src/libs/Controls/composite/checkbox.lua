--* use ../main.lua
--* use ../ref.lua
--* use ../basic/icon.lua
--* use ../basic/label.lua

---@class Checkbox : Control
---@field state Ref<boolean>
---@field text Ref<string>
---@field betweenSpace Ref<integer>

---@param id string
---@param parent Element
---@param args {
---    anchors: Ref<AnchorSetting[]>?,
---    hidden: Ref<boolean>?,
---    height: Ref<integer?>?,
---    mouseEnabled: Ref<boolean>?,
---    width: Ref<integer?>?,
---    state: Ref<boolean>?,
---    text: Ref<string>?,
---    betweenSpace: Ref<integer>?,
---}
---@return Checkbox
function Controls.checkbox(id, parent, args)
    local e = WINDOW_MANAGER:CreateControl(id, parent.element, CT_CONTROL)
    local result = Controls.setupControl(id, e, args) --[[@as Checkbox]]

    if args.state == nil then
        args.state = Ref(false)
    end
    result.state = args.state

    if args.text == nil then
        args.text = Ref("")
    end
    result.text = args.text

    if args.betweenSpace == nil then
        args.betweenSpace = Ref(8)
    end
    result.betweenSpace = args.betweenSpace

    local icon = Controls.texture(id .. "-icon", { element = e }, {
        hidden = args.hidden,
        height = Ref(32),
        width = Ref(32),
        mouseEnabled = Ref(true),
        anchors = Ref({
            { point = LEFT, target = e, relativePoint = LEFT, offsetX = 0, offsetY = 0 },
        })
    })

    args.state:use(id .. "-state", function(_, v)
        if v then
            icon.texture:set(Textures.icons.checkbox.checked)
        else
            icon.texture:set(Textures.icons.checkbox.unchecked)
        end
    end)
    icon.handlers.onMouseDown:set(function(self, button, ctrl, alt, shift, command)
        args.state:set(not args.state:get())
    end)

    local label = Controls.label(id .. "-label", { element = e }, {
        hidden = args.hidden,
        text = args.text,
    })

    args.betweenSpace:use(id .. "-betweenSpace", function(_, v)
        label.anchors:set({
            { point = TOPLEFT,     target = icon.element, relativePoint = TOPRIGHT,    offsetX = v, offsetY = 0 },
        })
        label.width:set(e:GetWidth())
    end)

    return result
end
