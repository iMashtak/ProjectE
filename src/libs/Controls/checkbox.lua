--* use ./main.lua
--* use ./ref.lua
--* use ./icon.lua
--* use ./label.lua

---@class Checkbox : Element
---@field hidden Ref<boolean>
---@field state Ref<boolean>
---@field text Ref<string>
---@field betweenSpace Ref<integer>
---@field anchors Ref<AnchorSetting[]>

---@param id string
---@param parent Element
---@param args {hidden: Ref<boolean>?, state: Ref<boolean>?, text: Ref<string>?, betweenSpace: Ref<integer>?, anchors: Ref<AnchorSetting[]>?}
---@return Checkbox
function Controls.checkbox(id, parent, args)
    local e = WINDOW_MANAGER:CreateControl(id, parent.element, CT_CONTROL)

    if args.hidden == nil then
        args.hidden = Ref(true)
    end
    args.hidden:use(id .. "-hidden", function(_, v)
        e:SetHidden(v)
    end)

    if args.anchors == nil then
        args.anchors = Ref({})
    end
    args.anchors:use(id .. "-anchors", function(_, v)
        e:ClearAnchors()
        for _, anchor in ipairs(v) do
            e:SetAnchor(anchor.point, anchor.target, anchor.relativePoint, anchor.offsetX, anchor.offsetY)
        end
    end)

    if args.state == nil then
        args.state = Ref(false)
    end

    if args.text == nil then
        args.text = Ref("")
    end

    if args.betweenSpace == nil then
        args.betweenSpace = Ref(-16)
    end

    local icon = Controls.icon(id .. "-icon", { element = e }, {
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
            icon.texture:set("/esoui/art/cadwell/checkboxicon_checked.dds")
        else
            icon.texture:set("/esoui/art/cadwell/checkboxicon_unchecked.dds")
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
            { point = LEFT,        target = icon.element, relativePoint = RIGHT,       offsetX = v, offsetY = 0 },
            { point = BOTTOMRIGHT, target = e,            relativePoint = BOTTOMRIGHT, offsetX = 0, offsetY = 0 },
        })
    end)

    return {
        element = e,
        hidden = args.hidden,
        state = args.state,
        text = args.text,
        betweenSpace = args.betweenSpace,
        anchors = args.anchors,
    }
end
